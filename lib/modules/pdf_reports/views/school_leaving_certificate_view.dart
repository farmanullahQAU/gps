import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Value;
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../../../core/widgets/student_avatar.dart';
import '../../attendance/attendance_controller.dart';
import '../pdf_generator_service.dart';
import '../pdf_reports_controller.dart';

/// Dedicated Interactive Page for Official KPK School Leaving & Character Certificate
/// (سرٹیفکیٹ داخل خارج و چال چلن — محکمہ ابتدائی و ثانوی تعلیم خیبر پختونخوا)
class SchoolLeavingCertificateView extends StatefulWidget {
  final Student? initialStudent;

  const SchoolLeavingCertificateView({super.key, this.initialStudent});

  @override
  State<SchoolLeavingCertificateView> createState() => _SchoolLeavingCertificateViewState();
}

class _SchoolLeavingCertificateViewState extends State<SchoolLeavingCertificateView> {
  final PdfReportsController _reportCtrl = Get.find<PdfReportsController>();
  final AttendanceController _attCtrl = Get.find<AttendanceController>();

  final TextEditingController _fileNoCtrl = TextEditingController(text: '01');
  final TextEditingController _certNoCtrl = TextEditingController();
  final TextEditingController _leavingDateCtrl = TextEditingController();
  final TextEditingController _leavingReasonCtrl = TextEditingController();
  final TextEditingController _nationalityCtrl = TextEditingController();
  final TextEditingController _promotedStatusCtrl = TextEditingController();

  DateTime _selectedDob = DateTime(2019, 3, 15);
  String _activeBForm = '';
  String _selectedConduct = 'EXCELLENT / GOOD';
  bool _isDuplicate = false;
  bool _isSaving = false;
  List<Student> _classStudents = [];
  Student? _activeStudent;

  @override
  void initState() {
    super.initState();
    _reportCtrl.selectedReportType.value = ReportType.schoolLeavingCertificate;
    _loadStudentsForCurrentClass(initial: widget.initialStudent);
  }

  @override
  void dispose() {
    _fileNoCtrl.dispose();
    _certNoCtrl.dispose();
    _leavingDateCtrl.dispose();
    _leavingReasonCtrl.dispose();
    _nationalityCtrl.dispose();
    _promotedStatusCtrl.dispose();
    super.dispose();
  }

  String get _dobFiguresStr => DateFormat('dd-MM-yyyy').format(_selectedDob);
  String get _dobWordsStr => PdfGeneratorService.dobToWords(_selectedDob);

  Future<void> _loadStudentsForCurrentClass({Student? initial}) async {
    final cls = _attCtrl.selectedClass.value;
    final sec = _attCtrl.selectedSection.value;
    if (cls == null || sec == null) return;

    final rawStudents = await _reportCtrl.studentRepository.getStudentsForSection(
      classId: cls.id,
      sectionId: sec.id,
      includeInactive: true,
    );

    // Ensure every student record has a valid dateOfBirth in the database
    final allStudents = <Student>[];
    for (final s in rawStudents) {
      if (s.dateOfBirth == null || s.dateOfBirth!.trim().isEmpty) {
        final resolved = PdfGeneratorService.resolveStudentDob(s);
        final isoDob = DateFormat('yyyy-MM-dd').format(resolved);
        final patched = s.copyWith(
          dateOfBirth: Value(isoDob),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
        await _reportCtrl.studentRepository.db
            .update(_reportCtrl.studentRepository.db.students)
            .replace(patched);
        allStudents.add(patched);
      } else {
        allStudents.add(s);
      }
    }

    if (!mounted) return;
    setState(() {
      _classStudents = allStudents;
    });

    final target = initial ??
        _reportCtrl.selectedStudent.value ??
        (allStudents.isNotEmpty ? allStudents.first : null);

    if (target != null && allStudents.any((s) => s.id == target.id)) {
      final matched = allStudents.firstWhere((s) => s.id == target.id);
      await _selectStudent(matched);
    } else if (allStudents.isNotEmpty) {
      await _selectStudent(allStudents.first);
    } else {
      setState(() => _activeStudent = null);
    }
  }

  Future<void> _selectStudent(Student student) async {
    _reportCtrl.selectedStudent.value = student;
    final ext = await _reportCtrl.studentRepository.getExtendedInfo(student.id);
    if (!mounted) return;

    final nowStr = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final resolvedDob = PdfGeneratorService.resolveStudentDob(student);

    setState(() {
      _activeStudent = student;
      _selectedDob = resolvedDob;
      _activeBForm = (ext.studentBForm != null && ext.studentBForm!.trim().isNotEmpty)
          ? ext.studentBForm!.trim()
          : (student.studentCnic?.trim() ?? '');
      _certNoCtrl.text = (ext.slcNumber != null && ext.slcNumber!.trim().isNotEmpty)
          ? ext.slcNumber!
          : 'SLC-${student.admissionNumber}-${DateTime.now().year}';
      _leavingDateCtrl.text = (ext.leavingDate != null && ext.leavingDate!.trim().isNotEmpty)
          ? ext.leavingDate!
          : nowStr;
      // Keep Reason for Leaving and Tribe/Qaum (قومیت) empty by default
      _leavingReasonCtrl.text = '';
      _nationalityCtrl.text = '';
      _promotedStatusCtrl.text = student.status == 'graduated'
          ? 'Graduated (Class 5 Pass)'
          : (student.status == 'transferred' ? 'Transferred (SLC Issued)' : 'Promoted / Studying');
    });
    _syncOverridesToController();
  }

  void _syncOverridesToController() {
    _reportCtrl.customFileNumber.value = _fileNoCtrl.text.trim();
    _reportCtrl.customSlcNumber.value = _certNoCtrl.text.trim();
    _reportCtrl.customDob.value = _dobFiguresStr;
    _reportCtrl.customLeavingDate.value = _leavingDateCtrl.text.trim();
    _reportCtrl.customLeavingReason.value = _leavingReasonCtrl.text.trim();
    _reportCtrl.customNationality.value = _nationalityCtrl.text.trim();
    _reportCtrl.customPromotedStatus.value = _promotedStatusCtrl.text.trim();
    _reportCtrl.customConduct.value = _selectedConduct;
    _reportCtrl.isDuplicateSlc.value = _isDuplicate;
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
        domicileDistrict: existing.domicileDistrict,
        leavingDate: _leavingDateCtrl.text.trim(),
        leavingReason: _leavingReasonCtrl.text.trim(),
        slcNumber: _certNoCtrl.text.trim(),
        freeBooksIssued: existing.freeBooksIssued,
        isVaccinated: existing.isVaccinated,
        vaccineFirstDoseDate: existing.vaccineFirstDoseDate,
        vaccineSecondDoseDate: existing.vaccineSecondDoseDate,
        revokedQrTokens: existing.revokedQrTokens,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        revision: existing.revision + 1,
      );
      await _reportCtrl.studentRepository.studentDao.upsertExtendedInfo(updated);
      if (showToast && mounted) {
        Get.snackbar(
          'Saved',
          'SLC details saved for ${s.fullName}.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF166534),
        );
      }
    } catch (e) {
      if (showToast && mounted) {
        Get.snackbar('Save Error', 'Failed to save SLC details: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'School Leaving Certificate (SLC)',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              'سرٹیفکیٹ داخل خارج و چال چلن • محکمہ تعلیم خیبر پختونخوا',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFFA7F3D0)),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyBottomBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
        children: [
          // 1. Class, Student & Certificate Type (Original/Duplicate Radio Switch)
          _buildStudentSelectorCard(context),
          const SizedBox(height: 14),

          if (_activeStudent != null) ...[
            // 2. Student Bio-Data & DOB (Figures + Auto-Converted Words via intl)
            _buildStudentBioSummary(_activeStudent!),
            const SizedBox(height: 14),

            // 3. Certificate Entries (Short fields in a row, longer fields full-width)
            _buildSlcFormCard(context),
          ] else
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                children: [
                  Icon(Icons.person_search_rounded, size: 42, color: AppColors.textMuted),
                  SizedBox(height: 8),
                  Text(
                    'No students found in the selected class.\nPlease select a class with enrolled students.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentSelectorCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Selection Row (Displays Class Name only, without Section)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Class & Student (انتخاب جماعت و طالب علم)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Obx(() {
                final cls = _attCtrl.selectedClass.value?.name ?? 'Select Class';
                return InkWell(
                  onTap: () async {
                    await showClassPickerSheet(context, _attCtrl);
                    await _loadStudentsForCurrentClass();
                  },
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, size: 15, color: Color(0xFF166534)),
                        const SizedBox(width: 6),
                        Text(
                          cls,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF14532D),
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_drop_down_rounded, size: 18, color: Color(0xFF166534)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 10),

          // Full-width Student Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.45), width: 1.2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<Student>(
                isExpanded: true,
                value: _classStudents.contains(_activeStudent)
                    ? _activeStudent
                    : (_classStudents.isNotEmpty ? _classStudents.first : null),
                items: _classStudents.map((s) {
                  return DropdownMenuItem<Student>(
                    value: s,
                    child: Text(
                      'Roll ${s.rollNumber ?? "-"} • ${s.fullName} S/O ${s.fatherOrGuardianName} (${s.admissionNumber})',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                    ),
                  );
                }).toList(),
                onChanged: (st) {
                  if (st != null) _selectStudent(st);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Certificate Type: Original vs Duplicate Radio Switch
          const Text(
            'Certificate Type (قسم سرٹیفکیٹ)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          RadioGroup<bool>(
            groupValue: _isDuplicate,
            onChanged: (val) {
              if (val == null) return;
              setState(() => _isDuplicate = val);
              _syncOverridesToController();
            },
            child: Row(
              children: [
                Expanded(
                  child: _radioOptionTile(
                    value: false,
                    title: 'Original (اصلی)',
                    selected: !_isDuplicate,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _radioOptionTile(
                    value: true,
                    title: 'Duplicate (مثنیٰ)',
                    selected: _isDuplicate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _radioOptionTile({
    required bool value,
    required String title,
    required bool selected,
  }) {
    return InkWell(
      onTap: () {
        setState(() => _isDuplicate = value);
        _syncOverridesToController();
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF16A34A) : AppColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 32,
              child: Radio<bool>(
                value: value,
                activeColor: const Color(0xFF166534),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: selected ? const Color(0xFF14532D) : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentBioSummary(Student s) {
    final clsName = _attCtrl.selectedClass.value?.name ?? 'Class';
    final isFemale = s.gender.toLowerCase() == 'female';
    final genderLabel = isFemale ? 'Female' : 'Male';
    final admDt = PdfGeneratorService.parseFlexibleDate(s.admissionDate);
    final formattedAdmDate = admDt != null ? DateFormat('dd-MM-yyyy').format(admDt) : s.admissionDate;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StudentAvatar(
                name: s.fullName,
                photoUrl: s.photoUrl,
                gender: s.gender,
                radius: 22,
                badgeText: s.rollNumber,
                badgeColor: AppColors.primaryDark,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.fullName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Father (ولدیت): ${s.fatherOrGuardianName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'داخل خارج نمبر',
                      style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                    ),
                    Text(
                      s.admissionNumber,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: Color(0xFF14532D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),

          // Short Bio Pills Row: Class (no section) | Real Gender (Male/Female) | Admission Date
          Row(
            children: [
              _bioMetaPill('Class (جماعت)', clsName),
              const SizedBox(width: 8),
              _bioMetaPill('Gender (جنس)', genderLabel),
              const SizedBox(width: 8),
              _bioMetaPill('Admission (داخلہ)', formattedAdmDate),
            ],
          ),
          const SizedBox(height: 8),

          // Date of Birth (Figures & Words via intl) — Official Master Record (Read-Only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.cake_outlined, size: 15, color: Color(0xFF166534)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'DOB (تاریخ پیدائش):  $_dobFiguresStr',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF14532D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_activeBForm.isNotEmpty)
                      Flexible(
                        child: Text(
                          'Form-B: $_activeBForm',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF166534),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded, size: 11, color: Color(0xFF166534)),
                            SizedBox(width: 3),
                            Text(
                              'Master Record',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'In Words (لفظوں میں):  $_dobWordsStr',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bioMetaPill(String label, String val) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 2),
            Text(
              val,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlcFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Certificate Entries (اندراجات سرٹیفکیٹ)',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryDark,
                  visualDensity: VisualDensity.compact,
                ),
                icon: _isSaving
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                onPressed: _isSaving ? null : () => _saveSlcMetadata(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Short Fields Row 1: File No & Certificate No
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _labeledField(
                  label: 'File No (فائل نمبر)',
                  controller: _fileNoCtrl,
                  onChanged: (_) => _syncOverridesToController(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _labeledField(
                  label: 'Cert No (سرٹیفکیٹ نمبر)',
                  controller: _certNoCtrl,
                  onChanged: (_) => _syncOverridesToController(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Short Fields Row 2: Leaving Date & Qaum / Tribe (قومیت)
          Row(
            children: [
              Expanded(
                child: _labeledField(
                  label: 'Leaving Date (تاریخ خارج)',
                  controller: _leavingDateCtrl,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month_rounded, size: 17, color: AppColors.primaryDark),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2018),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        _leavingDateCtrl.text = DateFormat('dd-MM-yyyy').format(picked);
                        _syncOverridesToController();
                      }
                    },
                  ),
                  onChanged: (_) => _syncOverridesToController(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _labeledField(
                  label: 'Qaum / Tribe (قومیت)',
                  controller: _nationalityCtrl,
                  hint: 'Optional',
                  onChanged: (_) => _syncOverridesToController(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Full-Width Field 1: Class / Promotion Status
          _labeledField(
            label: 'Class Status (کیفیت / ترقی)',
            controller: _promotedStatusCtrl,
            hint: 'Promoted / Studying',
            onChanged: (_) => _syncOverridesToController(),
          ),
          const SizedBox(height: 10),

          // Full-Width Field 2: Reason for Leaving School (Empty by default)
          _labeledField(
            label: 'Reason for Leaving School (وجہ خارج ہونے مدرسہ — Optional)',
            controller: _leavingReasonCtrl,
            hint: 'Left blank by default',
            onChanged: (_) => _syncOverridesToController(),
          ),
          const SizedBox(height: 12),

          // Full-Width Field 3: Character & Conduct (چال چلن و اخلاق)
          const Text(
            'Character & Conduct (چال چلن و اخلاق)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _conductOption('EXCELLENT / GOOD', 'بہترین / اچھا'),
              const SizedBox(width: 8),
              _conductOption('EXCELLENT', 'بہترین (Excellent)'),
              const SizedBox(width: 8),
              _conductOption('GOOD', 'اچھا (Good)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conductOption(String value, String label) {
    final isSelected = _selectedConduct == value;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedConduct = value);
          _syncOverridesToController();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF16A34A) : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: isSelected ? const Color(0xFF166534) : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _labeledField({
    required String label,
    required TextEditingController controller,
    String? hint,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() {
          final isGenerating = _reportCtrl.isGenerating.value;
          return Row(
            children: [
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
                    label: const Text(
                      'Preview SLC',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    onPressed: isGenerating
                        ? null
                        : () async {
                            await _saveSlcMetadata(showToast: false);
                            _reportCtrl.selectedReportType.value = ReportType.schoolLeavingCertificate;
                            await _reportCtrl.previewPdf();
                          },
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
                    label: Text(
                      isGenerating ? 'Generating...' : 'Print / Share SLC',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    onPressed: isGenerating
                        ? null
                        : () async {
                            await _saveSlcMetadata(showToast: false);
                            _reportCtrl.selectedReportType.value = ReportType.schoolLeavingCertificate;
                            await _reportCtrl.exportPdf();
                          },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
