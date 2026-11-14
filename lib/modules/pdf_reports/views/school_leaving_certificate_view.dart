import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../../../core/widgets/student_avatar.dart';
import '../../attendance/attendance_controller.dart';
import '../../auth/auth_controller.dart';
import '../pdf_generator_service.dart';
import '../pdf_reports_controller.dart';

/// KPK School Leaving & Character Certificate
/// (سرٹیفکیٹ داخل خارج و چال چلن — محکمہ ابتدائی و ثانوی تعلیم خیبر پختونخوا)
///
/// One scrolling page, top to bottom:
///   1. Student (with register data, previous / next)
///   2. Original or Duplicate
///   3. Certificate details
///   4. Academic standing & reason
///   5. Conduct
///   6. Live preview (collapsible)
/// Bottom bar: Save · Preview PDF · Issue SLC (both auto-save first).
class SchoolLeavingCertificateView extends StatefulWidget {
  final Student? initialStudent;

  const SchoolLeavingCertificateView({super.key, this.initialStudent});

  @override
  State<SchoolLeavingCertificateView> createState() => _SchoolLeavingCertificateViewState();
}

class _SchoolLeavingCertificateViewState extends State<SchoolLeavingCertificateView> {
  static const _green = Color(0xFF0F5132);
  static const _greenSoft = Color(0xFFF0FDF4);
  static const _amber = Color(0xFFB45309);
  static const _slate50 = Color(0xFFF8FAFC);
  static const _slate100 = Color(0xFFF1F5F9);

  static const _dateFmt = 'dd-MM-yyyy';

  final PdfReportsController _reportCtrl = Get.find<PdfReportsController>();
  final AttendanceController _attCtrl = Get.find<AttendanceController>();
  final AuthController _authCtrl = Get.find<AuthController>();

  final TextEditingController _fileNoCtrl = TextEditingController(text: '01');
  final TextEditingController _certNoCtrl = TextEditingController();
  final TextEditingController _leavingDateCtrl = TextEditingController();
  final TextEditingController _leavingReasonCtrl = TextEditingController();
  final TextEditingController _domicileCtrl = TextEditingController(); // stored as domicileDistrict / customNationality
  final TextEditingController _promotedStatusCtrl = TextEditingController();

  DateTime _selectedDob = DateTime(2019, 3, 15);
  String _activeBForm = '';
  String _selectedConduct = 'EXCELLENT / GOOD';
  bool _isDuplicate = false;
  bool _isSaving = false;
  bool _dirty = false;
  bool _previewOpen = false;
  List<Student> _classStudents = [];
  Student? _activeStudent;
  School? _school;

  // ───────────────────────── lifecycle ─────────────────────────

  @override
  void initState() {
    super.initState();
    _reportCtrl.selectedReportType.value = ReportType.schoolLeavingCertificate;
    _loadSchool();
    _loadStudentsForCurrentClass(initial: widget.initialStudent);
  }

  @override
  void dispose() {
    _fileNoCtrl.dispose();
    _certNoCtrl.dispose();
    _leavingDateCtrl.dispose();
    _leavingReasonCtrl.dispose();
    _domicileCtrl.dispose();
    _promotedStatusCtrl.dispose();
    super.dispose();
  }

  // ───────────────────────── data ─────────────────────────

  Future<void> _loadSchool() async {
    final sId = _authCtrl.currentUser.value?.schoolId;
    if (sId != null && sId.isNotEmpty) {
      final s = await _reportCtrl.studentRepository.getSchool(sId);
      if (mounted) setState(() => _school = s);
    }
  }

  String get _dobFiguresStr => DateFormat(_dateFmt).format(_selectedDob);
  String get _dobWordsStr => PdfGeneratorService.dobToWords(_selectedDob);

  int get _activeIndex =>
      _activeStudent == null ? -1 : _classStudents.indexWhere((s) => s.id == _activeStudent!.id);

  Future<void> _loadStudentsForCurrentClass({Student? initial}) async {
    // Ensure classes and active class are loaded if opened directly from Home
    if (_attCtrl.classesList.isEmpty || _attCtrl.selectedClass.value == null) {
      await _attCtrl.loadClasses();
    }

    if (_attCtrl.selectedClass.value == null && _attCtrl.classesList.isNotEmpty) {
      // Prioritize Class 5 for SLC (statutory primary school graduation)
      final cls5 = _attCtrl.classesList.firstWhereOrNull((c) => c.numericLevel == 5) ?? _attCtrl.classesList.first;
      await _attCtrl.selectClass(cls5);
    }

    final cls = _attCtrl.selectedClass.value;
    final sec = _attCtrl.selectedSection.value;
    if (cls == null || sec == null) {
      if (mounted) setState(() => _activeStudent = null);
      return;
    }

    final rawStudents = await _reportCtrl.studentRepository.getStudentsForSection(
      classId: cls.id,
      sectionId: sec.id,
      includeInactive: true,
    );

    // Make sure every student has a valid dateOfBirth in the database.
    final allStudents = <Student>[];
    for (final s in rawStudents) {
      if (s.dateOfBirth == null || s.dateOfBirth!.trim().isEmpty) {
        final resolved = PdfGeneratorService.resolveStudentDob(s);
        final isoDob = DateFormat('yyyy-MM-dd').format(resolved);
        await _reportCtrl.studentRepository.patchStudentDob(studentId: s.id, dobIso: isoDob);
        allStudents.add(s.copyWith(
          dateOfBirth: Value(isoDob),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ));
      } else {
        allStudents.add(s);
      }
    }

    if (!mounted) return;
    setState(() => _classStudents = allStudents);

    final target = initial ??
        _reportCtrl.selectedStudent.value ??
        allStudents.firstOrNull;

    if (target != null) {
      final match = allStudents.firstWhereOrNull((s) => s.id == target.id);
      if (match != null) {
        await _selectStudent(match, saveCurrent: false);
      } else if (allStudents.isNotEmpty) {
        await _selectStudent(allStudents.first, saveCurrent: false);
      } else {
        if (mounted) setState(() => _activeStudent = null);
      }
    } else if (allStudents.isNotEmpty) {
      await _selectStudent(allStudents.first, saveCurrent: false);
    } else {
      if (mounted) setState(() => _activeStudent = null);
    }
  }

  Future<void> _selectStudent(Student student, {bool saveCurrent = true}) async {
    // Don't lose edits when moving to another student.
    if (saveCurrent && _dirty && _activeStudent != null) {
      await _saveSlcMetadata(showToast: false);
    }

    _reportCtrl.selectedStudent.value = student;
    final ext = await _reportCtrl.studentRepository.getExtendedInfo(student.id);
    if (!mounted) return;

    String clean(String? v) => (v ?? '').trim();

    setState(() {
      _activeStudent = student;
      _selectedDob = PdfGeneratorService.resolveStudentDob(student);
      _activeBForm = clean(ext.studentBForm).isNotEmpty ? clean(ext.studentBForm) : clean(student.studentCnic);
      _certNoCtrl.text = clean(ext.slcNumber).isNotEmpty
          ? ext.slcNumber!
          : 'SLC-${student.admissionNumber}-${DateTime.now().year}';
      _leavingDateCtrl.text =
          clean(ext.leavingDate).isNotEmpty ? ext.leavingDate! : DateFormat(_dateFmt).format(DateTime.now());
      _leavingReasonCtrl.text = clean(ext.leavingReason);
      _domicileCtrl.text = clean(ext.domicileDistrict);
      _promotedStatusCtrl.text = student.status == 'graduated'
          ? 'Graduated (Class 5 Pass)'
          : (student.status == 'transferred' ? 'Transferred (SLC Issued)' : 'Promoted / Studying');
      _selectedConduct = 'EXCELLENT / GOOD';
      _isDuplicate = false;
      _dirty = false;
    });
    _syncOverridesToController();
  }

  void _syncOverridesToController() {
    _reportCtrl.customFileNumber.value = _fileNoCtrl.text.trim();
    _reportCtrl.customSlcNumber.value = _certNoCtrl.text.trim();
    _reportCtrl.customDob.value = _dobFiguresStr;
    _reportCtrl.customLeavingDate.value = _leavingDateCtrl.text.trim();
    _reportCtrl.customLeavingReason.value = _leavingReasonCtrl.text.trim();
    _reportCtrl.customNationality.value = _domicileCtrl.text.trim();
    _reportCtrl.customPromotedStatus.value = _promotedStatusCtrl.text.trim();
    _reportCtrl.customConduct.value = _selectedConduct;
    _reportCtrl.isDuplicateSlc.value = _isDuplicate;
  }

  /// Every edit goes through here: sync to controller, mark unsaved, refresh preview.
  void _touch() {
    _syncOverridesToController();
    setState(() => _dirty = true);
  }

  Future<void> _saveSlcMetadata({bool showToast = true}) async {
    final s = _activeStudent;
    if (s == null) return;
    setState(() => _isSaving = true);
    try {
      _syncOverridesToController();

      final existing = await _reportCtrl.studentRepository.getExtendedInfo(s.id);
      final updated = StudentExtendedInfoModel(
        studentId: s.id,
        studentBForm: existing.studentBForm,
        fatherCnic: existing.fatherCnic,
        motherName: existing.motherName,
        domicileDistrict:
            _domicileCtrl.text.trim().isNotEmpty ? _domicileCtrl.text.trim() : existing.domicileDistrict,
        leavingDate: _leavingDateCtrl.text.trim(),
        leavingReason: _leavingReasonCtrl.text.trim(),
        slcNumber: _certNoCtrl.text.trim(),
        freeBooksIssued: existing.freeBooksIssued,
        isVaccinated: existing.isVaccinated,
        vaccineFirstDoseDate: existing.vaccineFirstDoseDate,
        vaccineSecondDoseDate: existing.vaccineSecondDoseDate,
        revokedQrTokens: existing.revokedQrTokens,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        revision: existing.revision,
      );
      await _reportCtrl.saveStudentLeavingCertificate(updated);
      if (mounted) setState(() => _dirty = false);
      if (showToast && mounted) {
        Get.snackbar(
          'Saved',
          'Details saved for ${s.fullName}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF166534),
        );
      }
    } catch (e) {
      if (showToast && mounted) {
        Get.snackbar('Could not save', 'Please try again. ($e)', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Certificate number and leaving date are printed on the document, so they must exist.
  bool _validateBeforePrint() {
    final missing = <String>[
      if (_certNoCtrl.text.trim().isEmpty) 'Certificate No',
      if (_leavingDateCtrl.text.trim().isEmpty) 'Leaving Date',
    ];
    if (missing.isEmpty) return true;
    Get.snackbar(
      'Missing details',
      'Please fill in: ${missing.join(', ')}.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFEF3C7),
      colorText: const Color(0xFF92400E),
    );
    return false;
  }

  Future<void> _preview() async {
    if (!_validateBeforePrint()) return;
    await _saveSlcMetadata(showToast: false);
    _reportCtrl.selectedReportType.value = ReportType.schoolLeavingCertificate;
    await _reportCtrl.previewPdf();
  }

  Future<void> _issue() async {
    if (!_validateBeforePrint()) return;
    await _saveSlcMetadata(showToast: false);
    _reportCtrl.selectedReportType.value = ReportType.schoolLeavingCertificate;
    await _reportCtrl.exportPdf();
  }

  void _applyClass5Preset() {
    _promotedStatusCtrl.text = 'Graduated (Class 5 Pass)';
    _leavingReasonCtrl.text = 'Passed Primary School Examination (Class 5)';
    _selectedConduct = 'EXCELLENT / GOOD';
    _leavingDateCtrl.text = DateFormat(_dateFmt).format(DateTime.now());
    _touch();
  }

  Future<void> _pickLeavingDate() async {
    DateTime? current;
    try {
      current = DateFormat(_dateFmt).parseStrict(_leavingDateCtrl.text.trim());
    } catch (_) {}
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _leavingDateCtrl.text = DateFormat(_dateFmt).format(picked);
      _touch();
    }
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _selectedDob.isAfter(now) ? now : _selectedDob;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: now,
      helpText: 'Date of birth for this certificate',
    );
    if (picked != null) {
      _selectedDob = picked;
      _touch();
    }
  }

  Future<void> _changeClass() async {
    await showClassPickerSheet(context, _attCtrl);
    await _loadStudentsForCurrentClass();
  }

  void _step(int delta) {
    final i = _activeIndex;
    final next = i + delta;
    if (i < 0 || next < 0 || next >= _classStudents.length) return;
    _selectStudent(_classStudents[next]);
  }

  // ───────────────────────── build ─────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _slate50,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('School Leaving Certificate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            Text('سرٹیفکیٹ داخل خارج و چال چلن',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFA7F3D0))),
          ],
        ),
      ),
      bottomNavigationBar: _activeStudent == null ? null : _buildBottomBar(),
      body: _activeStudent == null ? _buildEmptyState() : _buildForm(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(color: _slate100, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.person_search_rounded, size: 34, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            const Text('No students in this class',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text(
              'Choose a class that has enrolled students to issue a certificate.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.school_rounded, size: 16),
              label: const Text('Choose class', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
              onPressed: _changeClass,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    final s = _activeStudent!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
      children: [
        _buildStudentCard(s),
        const SizedBox(height: 12),
        _buildIssueTypeToggle(),
        const SizedBox(height: 12),
        _buildDetailsSection(),
        const SizedBox(height: 12),
        _buildAcademicSection(),
        const SizedBox(height: 12),
        _buildConductSection(),
        const SizedBox(height: 12),
        _buildPreviewSection(s),
      ],
    );
  }

  // ───────────────────────── 1. student ─────────────────────────

  Widget _buildStudentCard(Student s) {
    final i = _activeIndex;
    final total = _classStudents.length;
    final isFemale = s.gender.toLowerCase() == 'female';
    final admDt = PdfGeneratorService.parseFlexibleDate(s.admissionDate);
    final admitted = admDt != null ? DateFormat(_dateFmt).format(admDt) : s.admissionDate;
    final roll = (s.rollNumber ?? '').trim();

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // class + position + prev / next
          Row(
            children: [
              Obx(() {
                final cls = _attCtrl.selectedClass.value?.name ?? 'Class';
                return InkWell(
                  onTap: _changeClass,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: _greenSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, size: 14, color: Color(0xFF166534)),
                        const SizedBox(width: 5),
                        Text(cls,
                            style: const TextStyle(
                                fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF14532D))),
                        const Icon(Icons.arrow_drop_down_rounded, size: 16, color: Color(0xFF166534)),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              IconButton(
                tooltip: 'Previous student',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: i > 0 ? () => _step(-1) : null,
              ),
              Text('${i + 1} / $total',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              IconButton(
                tooltip: 'Next student',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: i >= 0 && i < total - 1 ? () => _step(1) : null,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // identity (tap to search)
          InkWell(
            onTap: () => _showStudentSearchSheet(context),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                StudentAvatar(
                  name: s.fullName,
                  photoUrl: s.photoUrl,
                  gender: s.gender,
                  radius: 24,
                  badgeText: s.rollNumber,
                  badgeColor: AppColors.primaryDark,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text('S/O ${s.fatherOrGuardianName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryDark),
              ],
            ),
          ),
          const Divider(height: 20, color: _slate100),

          // register data — shown once, here
          Row(
            children: [
              _infoTile('Admission No', s.admissionNumber),
              const SizedBox(width: 8),
              _infoTile('Admitted', admitted),
              const SizedBox(width: 8),
              _infoTile('Gender', isFemale ? 'Female' : 'Male'),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickDob,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
              decoration: BoxDecoration(
                color: _slate50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date of birth  •  $_dobFiguresStr',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const SizedBox(height: 2),
                        Text(_dobWordsStr,
                            style: const TextStyle(
                                fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        if (_activeBForm.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('Form-B: $_activeBForm',
                              style: const TextStyle(
                                  fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.primaryDark),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          if (roll.isNotEmpty)
            const SizedBox.shrink(), // roll number already appears on the avatar badge
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: _slate50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                maxLines: 1,
                style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
            const SizedBox(height: 1),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── 2. original / duplicate ─────────────────────────

  Widget _buildIssueTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(3.5),
      decoration: BoxDecoration(
        color: _slate100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _togglePill(
            icon: Icons.verified_outlined,
            title: 'Original  (اصلی)',
            selected: !_isDuplicate,
            color: _green,
            onTap: () {
              _isDuplicate = false;
              _touch();
            },
          ),
          _togglePill(
            icon: Icons.content_copy_rounded,
            title: 'Duplicate  (مثنیٰ)',
            selected: _isDuplicate,
            color: _amber,
            onTap: () {
              _isDuplicate = true;
              _touch();
            },
          ),
        ],
      ),
    );
  }

  Widget _togglePill({
    required IconData icon,
    required String title,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? Icons.check_circle_rounded : icon,
                  size: 16, color: selected ? color : AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(title,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      color: selected ? color : AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── 3–5. form sections ─────────────────────────

  Widget _buildDetailsSection() {
    return _section(
      title: 'Certificate details',
      urdu: 'حوالہ و تواریخ',
      icon: Icons.tag_rounded,
      color: const Color(0xFF1D4ED8),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _field(label: 'File / Book No', controller: _fileNoCtrl, onChanged: (_) => _touch()),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: _field(
                  label: 'Certificate No', controller: _certNoCtrl, required: true, onChanged: (_) => _touch()),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _field(
                label: 'Leaving date',
                controller: _leavingDateCtrl,
                required: true,
                suffixIcon: IconButton(
                  tooltip: 'Pick date',
                  icon: const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primaryDark),
                  onPressed: _pickLeavingDate,
                ),
                onChanged: (_) => _touch(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _field(
                label: 'Domicile / district',
                controller: _domicileCtrl,
                hint: 'Optional',
                onChanged: (_) => _touch(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAcademicSection() {
    return _section(
      title: 'Academic standing & reason',
      urdu: 'تعلیمی کیفیت و وجہ خارج',
      icon: Icons.history_edu_rounded,
      color: const Color(0xFF047857),
      trailing: TextButton.icon(
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          foregroundColor: AppColors.primaryDark,
        ),
        icon: const Icon(Icons.auto_fix_high_rounded, size: 15),
        label: const Text('Class 5 pass', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
        onPressed: _applyClass5Preset,
      ),
      children: [
        _field(
          label: 'Academic standing',
          controller: _promotedStatusCtrl,
          hint: 'e.g. Graduated (Class 5 Pass)',
          onChanged: (_) => _touch(),
        ),
        _chips(
          const ['Graduated (Class 5 Pass)', 'Promoted to Class 6', 'Studying / Incomplete Session'],
          _promotedStatusCtrl,
        ),
        const SizedBox(height: 12),
        _field(
          label: 'Reason for leaving',
          controller: _leavingReasonCtrl,
          hint: 'Type, or pick one below (optional)',
          onChanged: (_) => _touch(),
        ),
        _chips(
          const [
            'Passed Primary School Examination (Class 5)',
            'Parents / Guardian Relocation (تبادلہ)',
            'Admitted to Another School',
            'Domestic / Personal Reasons',
          ],
          _leavingReasonCtrl,
        ),
      ],
    );
  }

  Widget _buildConductSection() {
    return _section(
      title: 'Character & conduct',
      urdu: 'چال چلن و اخلاق',
      icon: Icons.verified_user_rounded,
      color: _amber,
      children: [
        Row(
          children: [
            _conductCard('EXCELLENT / GOOD', 'Excellent / Good', 'بہترین و اچھا', recommended: true),
            const SizedBox(width: 8),
            _conductCard('EXCELLENT', 'Excellent', 'بہترین'),
            const SizedBox(width: 8),
            _conductCard('GOOD', 'Good', 'اچھا'),
          ],
        ),
      ],
    );
  }

  Widget _conductCard(String code, String title, String urdu, {bool recommended = false}) {
    final selected = _selectedConduct == code;
    return Expanded(
      child: InkWell(
        onTap: () {
          _selectedConduct = code;
          _touch();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? _greenSoft : _slate50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? const Color(0xFF16A34A) : AppColors.border, width: selected ? 1.5 : 1.0),
          ),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: selected ? const Color(0xFF14532D) : AppColors.textPrimary)),
              ),
              const SizedBox(height: 2),
              Text(urdu,
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: selected ? const Color(0xFF166534) : AppColors.textSecondary)),
              if (recommended) ...[
                const SizedBox(height: 2),
                const Text('Standard', style: TextStyle(fontSize: 9, color: AppColors.textMuted)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────── 6. live preview ─────────────────────────

  Widget _buildPreviewSection(Student s) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _previewOpen,
          onExpansionChanged: (v) => setState(() => _previewOpen = v),
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: _green, size: 16),
          ),
          title: const Text('Live preview',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          subtitle: const Text('See the certificate as you type',
              style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
          children: [_buildCertificateCard(s)],
        ),
      ),
    );
  }

  Widget _buildCertificateCard(Student s) {
    final schoolName = _school?.name ?? 'Government Primary School';
    final emisCode = _school?.code ?? '27289';
    final clsName = _attCtrl.selectedClass.value?.name ?? 'Class 5';
    String orDash(String v) => v.trim().isEmpty ? '—' : v.trim();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _green, width: 2.5),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _refBox('Book: ${orDash(_fileNoCtrl.text)}'),
              Text(
                _isDuplicate ? 'DUPLICATE (مثنیٰ)' : 'ORIGINAL (اصلی)',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: _isDuplicate ? _amber : _green),
              ),
              _refBox('No: ${orDash(_certNoCtrl.text)}'),
            ],
          ),
          const SizedBox(height: 10),
          const Text('GOVERNMENT OF KHYBER PAKHTUNKHWA',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: _green)),
          const Text('ELEMENTARY & SECONDARY EDUCATION DEPARTMENT',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          Text(schoolName.toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          Text('EMIS $emisCode  |  $clsName',
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(6)),
            child: const Text('SCHOOL LEAVING & CHARACTER CERTIFICATE',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: Colors.white)),
          ),
          const Divider(height: 20, thickness: 1.2, color: _green),
          Text(
            'Certified that ${s.fullName} son/daughter of ${s.fatherOrGuardianName}'
            '${_domicileCtrl.text.trim().isEmpty ? '' : ', resident of ${_domicileCtrl.text.trim()}'}, '
            'was admitted to this institution under Admission No. ${s.admissionNumber} '
            'and left the school on ${orDash(_leavingDateCtrl.text)}.',
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 11.5, height: 1.45, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: Column(
              children: [
                _certRow('Date of birth', '$_dobFiguresStr\n$_dobWordsStr'),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _certRow('Form-B No', orDash(_activeBForm)),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _certRow('Academic standing', orDash(_promotedStatusCtrl.text)),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _certRow('Reason for leaving', orDash(_leavingReasonCtrl.text)),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                _certRow('Character & conduct', _selectedConduct),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SignatureLine(label: 'Class Teacher', width: 100, color: Color(0xFF475569)),
              _SignatureLine(label: 'Head Teacher / Seal', width: 120, color: _green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _refBox(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _slate100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(label,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── shared widgets ─────────────────────────

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  Widget _section({
    required String title,
    required String urdu,
    required IconData icon,
    required Color color,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(width: 6),
                    Text(urdu, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool required = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    final empty = required && controller.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: label,
            children: [
              if (required)
                const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w900)),
            ],
          ),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            filled: true,
            fillColor: _slate50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(color: empty ? const Color(0xFFFCA5A5) : AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide(color: empty ? const Color(0xFFFCA5A5) : AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _chips(List<String> suggestions, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: suggestions.map((text) {
          final current = ctrl.text.trim() == text.trim();
          return InkWell(
            onTap: () {
              ctrl.text = text;
              _touch();
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: current ? const Color(0xFFDCFCE7) : _slate100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: current ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0)),
              ),
              child: Text(text,
                  style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: current ? FontWeight.w800 : FontWeight.w600,
                      color: current ? const Color(0xFF166534) : const Color(0xFF475569))),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ───────────────────────── student search sheet ─────────────────────────

  void _showStudentSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final q = query.toLowerCase();
            final filtered = _classStudents.where((s) {
              if (q.isEmpty) return true;
              return s.fullName.toLowerCase().contains(q) ||
                  s.fatherOrGuardianName.toLowerCase().contains(q) ||
                  (s.rollNumber?.toLowerCase() ?? '').contains(q) ||
                  s.admissionNumber.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollController) {
                return Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Select student',
                              style: TextStyle(
                                  fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: _greenSoft, borderRadius: BorderRadius.circular(6)),
                            child: Text('${filtered.length} students',
                                style: const TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search by name, father, roll or admission no',
                          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryDark),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: _slate50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                        onChanged: (val) => setModalState(() => query = val),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text('No students match your search.',
                                  style: TextStyle(color: AppColors.textSecondary)),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: _slate100),
                              itemBuilder: (context, i) {
                                final st = filtered[i];
                                final isSelected = st.id == _activeStudent?.id;
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  leading: StudentAvatar(
                                    name: st.fullName,
                                    photoUrl: st.photoUrl,
                                    gender: st.gender,
                                    radius: 18,
                                    badgeText: st.rollNumber,
                                  ),
                                  title: Text(st.fullName,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                          color: isSelected ? const Color(0xFF166534) : AppColors.textPrimary)),
                                  subtitle: Text('S/O ${st.fatherOrGuardianName} • Adm #${st.admissionNumber}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF166534), size: 20)
                                      : null,
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _selectStudent(st);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ───────────────────────── bottom bar ─────────────────────────

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
          ],
        ),
        child: Obx(() {
          final isGenerating = _reportCtrl.isGenerating.value;
          final busy = isGenerating || _isSaving;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    _dirty ? Icons.edit_note_rounded : Icons.check_circle_outline_rounded,
                    size: 14,
                    color: _dirty ? _amber : const Color(0xFF16A34A),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _dirty ? 'Unsaved changes' : 'All changes saved',
                    style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: _dirty ? _amber : const Color(0xFF166534)),
                  ),
                  const Spacer(),
                  const Text('Preview and Issue save automatically',
                      style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    height: 46,
                    width: 46,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        foregroundColor: AppColors.primaryDark,
                        side: const BorderSide(color: AppColors.border, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                      ),
                      onPressed: busy || !_dirty ? null : () => _saveSlcMetadata(),
                      child: _isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.save_outlined, size: 20),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 4,
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          side: const BorderSide(color: AppColors.primaryDark, width: 1.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('Preview PDF', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        onPressed: busy ? null : _preview,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        ),
                        icon: isGenerating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.print_rounded, size: 18),
                        label: Text(isGenerating ? 'Generating…' : 'Issue SLC',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        onPressed: busy ? null : _issue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _SignatureLine extends StatelessWidget {
  final String label;
  final double width;
  final Color color;

  const _SignatureLine({required this.label, required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: width, height: 1, color: color),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }
}
