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
        await _reportCtrl.studentRepository.patchStudentDob(
          studentId: s.id,
          dobIso: isoDob,
        );
        final patched = s.copyWith(
          dateOfBirth: Value(isoDob),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        );
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
        revision: existing.revision,
      );
      await _reportCtrl.saveStudentLeavingCertificate(updated);
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
              'School Leaving Certificate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              'سرٹیفکیٹ داخل خارج و چال چلن',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFFA7F3D0)),
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
          // Class Selection Row
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

          // Interactive Student Card with Instant Search Picker
          InkWell(
            onTap: () => _showStudentSearchSheet(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.45), width: 1.2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Icon(Icons.person_search_rounded, size: 18, color: Color(0xFF166534)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _activeStudent != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Roll ${_activeStudent!.rollNumber ?? "-"} • ${_activeStudent!.fullName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              Text(
                                'S/O ${_activeStudent!.fatherOrGuardianName} • Adm #${_activeStudent!.admissionNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          )
                        : const Text(
                            'Tap to choose student...',
                            style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          ),
                  ),
                  const Icon(Icons.unfold_more_rounded, size: 20, color: AppColors.textSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Certificate Type: Original vs Duplicate Modern Switch
          const Text(
            'Certificate Type (قسم سرٹیفکیٹ)',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _certTypeButton(
                  icon: Icons.verified_outlined,
                  title: 'Original (اصلی)',
                  selected: !_isDuplicate,
                  onTap: () {
                    setState(() => _isDuplicate = false);
                    _syncOverridesToController();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _certTypeButton(
                  icon: Icons.content_copy_rounded,
                  title: 'Duplicate (مثنیٰ)',
                  selected: _isDuplicate,
                  onTap: () {
                    setState(() => _isDuplicate = true);
                    _syncOverridesToController();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStudentSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = _classStudents.where((s) {
              if (query.isEmpty) return true;
              final q = query.toLowerCase();
              final name = s.fullName.toLowerCase();
              final father = s.fatherOrGuardianName.toLowerCase();
              final roll = s.rollNumber?.toLowerCase() ?? '';
              final adm = s.admissionNumber.toLowerCase();
              return name.contains(q) || father.contains(q) || roll.contains(q) || adm.contains(q);
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
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Student (طالب علم منتخب کریں)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${filtered.length} found',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: 'Search by Name, Roll # or Admission #...',
                          hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryDark),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
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
                              child: Text('No students match your search.', style: TextStyle(color: AppColors.textSecondary)),
                            )
                          : ListView.separated(
                              controller: scrollController,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                                  title: Text(
                                    st.fullName,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                      color: isSelected ? const Color(0xFF166534) : AppColors.textPrimary,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'S/O ${st.fatherOrGuardianName} • Adm #${st.admissionNumber}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
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

  Widget _certTypeButton({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF16A34A) : AppColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : icon,
              size: 16,
              color: selected ? const Color(0xFF166534) : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
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

          // Short Bio Pills Row: Class | Gender | Admission Date
          Row(
            children: [
              _bioMetaPill('Class', clsName),
              const SizedBox(width: 8),
              _bioMetaPill('Gender', genderLabel),
              const SizedBox(width: 8),
              _bioMetaPill('Admission', formattedAdmDate),
            ],
          ),
          const SizedBox(height: 8),

          // Date of Birth (Figures & Words) & Form-B — Official Master Record (Read-Only)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                    Row(
                      children: [
                        const Icon(Icons.cake_outlined, size: 15, color: Color(0xFF166534)),
                        const SizedBox(width: 6),
                        Text(
                          'DOB: $_dobFiguresStr',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF14532D),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                const SizedBox(height: 4),
                Text(
                  'In Words: $_dobWordsStr',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF166534),
                  ),
                ),
                if (_activeBForm.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Form-B / B-Form: $_activeBForm',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                ],
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

          // Full-Width Field 1: Class / Promotion Status with Quick Suggestion Chips
          _labeledField(
            label: 'Class Status (کیفیت / ترقی)',
            controller: _promotedStatusCtrl,
            hint: 'Promoted / Studying',
            onChanged: (_) => _syncOverridesToController(),
          ),
          _suggestionPills(
            ['Graduated (Class 5 Pass)', 'Promoted to Next Class', 'Studying'],
            _promotedStatusCtrl,
          ),
          const SizedBox(height: 10),

          // Full-Width Field 2: Reason for Leaving School with Quick Suggestion Chips
          _labeledField(
            label: 'Reason for Leaving School (وجہ خارج ہونے مدرسہ — Optional)',
            controller: _leavingReasonCtrl,
            hint: 'Left blank by default',
            onChanged: (_) => _syncOverridesToController(),
          ),
          _suggestionPills(
            ['Passed Class 5', "Parents' Request", 'Relocation / Migration'],
            _leavingReasonCtrl,
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
              _conductOption('EXCELLENT / GOOD', 'بہترین و اچھا'),
              const SizedBox(width: 8),
              _conductOption('EXCELLENT', 'بہترین'),
              const SizedBox(width: 8),
              _conductOption('GOOD', 'اچھا'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _suggestionPills(List<String> suggestions, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        children: suggestions.map((s) {
          final isCurrent = ctrl.text.trim() == s.trim();
          return InkWell(
            onTap: () {
              ctrl.text = s;
              _syncOverridesToController();
              setState(() {});
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCurrent ? const Color(0xFF86EFAC) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                s,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent ? const Color(0xFF166534) : const Color(0xFF475569),
                ),
              ),
            ),
          );
        }).toList(),
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
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF16A34A) : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? const Color(0xFF166534) : AppColors.textSecondary,
              ),
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
        SizedBox(
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary, height: 1.15),
            ),
          ),
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
