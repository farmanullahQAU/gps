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

/// Professional, Industry-Standard Official KPK School Leaving & Character Certificate View
/// (سرٹیفکیٹ داخل خارج و چال چلن — محکمہ ابتدائی و ثانوی تعلیم حکومت خیبر پختونخوا)
class SchoolLeavingCertificateView extends StatefulWidget {
  final Student? initialStudent;

  const SchoolLeavingCertificateView({super.key, this.initialStudent});

  @override
  State<SchoolLeavingCertificateView> createState() => _SchoolLeavingCertificateViewState();
}

class _SchoolLeavingCertificateViewState extends State<SchoolLeavingCertificateView> {
  final PdfReportsController _reportCtrl = Get.find<PdfReportsController>();
  final AttendanceController _attCtrl = Get.find<AttendanceController>();
  final AuthController _authCtrl = Get.find<AuthController>();

  int _activeTab = 0; // 0 = Particulars & Form, 1 = Live Certificate Card

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
  School? _school;

  @override
  void initState() {
    super.initState();
    _reportCtrl.selectedReportType.value = ReportType.schoolLeavingCertificate;
    _loadSchool();
    _loadStudentsForCurrentClass(initial: widget.initialStudent);
  }

  Future<void> _loadSchool() async {
    final sId = _authCtrl.currentUser.value?.schoolId;
    if (sId != null && sId.isNotEmpty) {
      final s = await _reportCtrl.studentRepository.getSchool(sId);
      if (mounted) setState(() => _school = s);
    }
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
      _leavingReasonCtrl.text = (ext.leavingReason != null && ext.leavingReason!.trim().isNotEmpty)
          ? ext.leavingReason!
          : '';
      _nationalityCtrl.text = (ext.domicileDistrict != null && ext.domicileDistrict!.trim().isNotEmpty)
          ? ext.domicileDistrict!
          : '';
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
        domicileDistrict: _nationalityCtrl.text.trim().isNotEmpty ? _nationalityCtrl.text.trim() : existing.domicileDistrict,
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
          'Certificate particulars saved for ${s.fullName}.',
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

  void _quickFillClass5Pass() {
    setState(() {
      _promotedStatusCtrl.text = 'Graduated (Class 5 Pass)';
      _leavingReasonCtrl.text = 'Passed Primary School Examination (Class 5)';
      _selectedConduct = 'EXCELLENT / GOOD';
      _leavingDateCtrl.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    });
    _syncOverridesToController();
    Get.snackbar(
      'Graduation Presets Applied',
      'Applied Class 5 pass, statutory discharge reason & excellent conduct.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFEFF6FF),
      colorText: const Color(0xFF1E40AF),
    );
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
              'سرٹیفکیٹ داخل خارج و چال چلن • محکمہ تعلیم خیبر پختونخوا',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFFA7F3D0)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Quick Fill Class 5 Pass',
            icon: const Icon(Icons.auto_fix_high_rounded, color: Color(0xFFA7F3D0), size: 20),
            onPressed: _activeStudent == null ? null : _quickFillClass5Pass,
          ),
          IconButton(
            tooltip: 'Save Particulars',
            icon: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            onPressed: _isSaving ? null : () => _saveSlcMetadata(),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(),
      body: Column(
        children: [
          // Executive Top Mode Switcher (Particulars Form vs Live Digital Certificate)
          _buildTopModeSwitcher(),

          Expanded(
            child: _activeStudent == null
                ? _buildEmptyState()
                : _activeTab == 0
                    ? _buildParticularsFormTab()
                    : _buildLiveCertificateTab(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopModeSwitcher() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: Container(
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: _modePill(
                index: 0,
                icon: Icons.edit_note_rounded,
                title: 'Certificate Particulars',
                urdu: 'تفصیلات و اندراجات',
              ),
            ),
            Expanded(
              child: _modePill(
                index: 1,
                icon: Icons.workspace_premium_rounded,
                title: 'Official Document View',
                urdu: 'پیشگی سرٹیفکیٹ کارڈ',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modePill({
    required int index,
    required IconData icon,
    required String title,
    required String urdu,
  }) {
    final isSelected = _activeTab == index;
    return InkWell(
      onTap: () {
        if (_activeTab != index) {
          _syncOverridesToController();
          setState(() => _activeTab = index);
        }
      },
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    urdu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? const Color(0xFF047857) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person_search_rounded, size: 36, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            const Text(
              'No Student Enrolled in Selected Class',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Please select an active class with enrolled students to issue a certificate.',
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
              label: const Text('Change Class', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
              onPressed: () async {
                await showClassPickerSheet(context, _attCtrl);
                await _loadStudentsForCurrentClass();
              },
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // TAB 1: FORM PARTICULARS
  // -------------------------------------------------------------
  Widget _buildParticularsFormTab() {
    final s = _activeStudent!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
      children: [
        // 1. Executive Student Identity & Mode Header
        _buildHeroStudentHeader(s),
        const SizedBox(height: 12),

        // 2. Official Record Reference & Dispatch Dates
        _buildSectionCard(
          stepNumber: '1',
          title: 'Dispatch & Certificate References',
          urdu: 'حوالہ و تواریخ',
          icon: Icons.tag_rounded,
          accentColor: const Color(0xFF1D4ED8),
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _alignedField(
                    label: 'File / Book No (فائل نمبر)',
                    controller: _fileNoCtrl,
                    onChanged: (_) => _syncOverridesToController(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: _alignedField(
                    label: 'Certificate No (سرٹیفکیٹ نمبر)',
                    controller: _certNoCtrl,
                    onChanged: (_) => _syncOverridesToController(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _alignedField(
                    label: 'Leaving Date (تاریخ اخراج)',
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
                  child: _alignedField(
                    label: 'Tribe / Qaum (قومیت)',
                    controller: _nationalityCtrl,
                    hint: 'Optional (اختیاری)',
                    onChanged: (_) => _syncOverridesToController(),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Academic Standing & Discharge Endorsements
        _buildSectionCard(
          stepNumber: '2',
          title: 'Discharge & Academic Endorsements',
          urdu: 'تعلیمی کیفیت و وجہ خارج',
          icon: Icons.history_edu_rounded,
          accentColor: const Color(0xFF047857),
          children: [
            _alignedField(
              label: 'Academic Standing / Promotion (تعلیمی کیفیت و ترقی)',
              controller: _promotedStatusCtrl,
              hint: 'e.g. Graduated (Class 5 Pass)',
              onChanged: (_) => _syncOverridesToController(),
            ),
            _quickPills(
              [
                'Graduated (Class 5 Pass)',
                'Promoted to Class 6',
                'Studying / Incomplete Session',
              ],
              _promotedStatusCtrl,
            ),
            const SizedBox(height: 12),
            _alignedField(
              label: 'Reason for Leaving School (وجہ خارج ہونے مدرسہ)',
              controller: _leavingReasonCtrl,
              hint: 'Leave blank or pick from standard presets',
              onChanged: (_) => _syncOverridesToController(),
            ),
            _quickPills(
              [
                'Passed Primary School Examination (Class 5)',
                'Parents / Guardian Relocation (تبادلہ)',
                'Admitted to Another School',
                'Domestic / Personal Reasons',
              ],
              _leavingReasonCtrl,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 4. Character & Moral Assessment
        _buildSectionCard(
          stepNumber: '3',
          title: 'Character & Conduct Assessment',
          urdu: 'چال چلن و اخلاق',
          icon: Icons.verified_user_rounded,
          accentColor: const Color(0xFFB45309),
          children: [
            Row(
              children: [
                _conductCard(
                  code: 'EXCELLENT / GOOD',
                  title: 'Excellent / Good',
                  urdu: 'بہترین و اچھا',
                  subtitle: 'KPK Statutory Standard',
                ),
                const SizedBox(width: 8),
                _conductCard(
                  code: 'EXCELLENT',
                  title: 'Excellent',
                  urdu: 'بہترین',
                  subtitle: 'Top Merited Conduct',
                ),
                const SizedBox(width: 8),
                _conductCard(
                  code: 'GOOD',
                  title: 'Good',
                  urdu: 'اچھا',
                  subtitle: 'Satisfactory Conduct',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 5. Official Master Record Summary (Verified from DB)
        _buildMasterRecordCard(s),
      ],
    );
  }

  Widget _buildHeroStudentHeader(Student s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar: Class Badge + Switch Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() {
                final cls = _attCtrl.selectedClass.value?.name ?? 'Class';
                return InkWell(
                  onTap: () async {
                    await showClassPickerSheet(context, _attCtrl);
                    await _loadStudentsForCurrentClass();
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF86EFAC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.school_rounded, size: 14, color: Color(0xFF166534)),
                        const SizedBox(width: 5),
                        Text(
                          '$cls (${_classStudents.length})',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF14532D)),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_drop_down_rounded, size: 16, color: Color(0xFF166534)),
                      ],
                    ),
                  ),
                );
              }),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                  foregroundColor: AppColors.primaryDark,
                ),
                icon: const Icon(Icons.person_search_rounded, size: 16),
                label: const Text('Change Student', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                onPressed: () => _showStudentSearchSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Student Bio Overview Tile
          Row(
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
                    Text(
                      s.fullName,
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'S/O ${s.fatherOrGuardianName}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'داخل خارج نمبر',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                    ),
                    Text(
                      s.admissionNumber,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF14532D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFF1F5F9)),

          // Certificate Issuance Mode Segmented Buttons
          Row(
            children: [
              Expanded(
                child: _certTypeButton(
                  icon: Icons.verified_outlined,
                  title: 'Original (اصلی)',
                  subtitle: 'Official First Issue',
                  selected: !_isDuplicate,
                  activeColor: const Color(0xFF047857),
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
                  title: 'Duplicate (مثنیٰ نقل)',
                  subtitle: 'Watermarked Reissue',
                  selected: _isDuplicate,
                  activeColor: const Color(0xFFB45309),
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

  Widget _certTypeButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(11),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? activeColor.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: selected ? activeColor : AppColors.border,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle_rounded : icon,
              size: 17,
              color: selected ? activeColor : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? activeColor : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: selected ? activeColor.withValues(alpha: 0.8) : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String stepNumber,
    required String title,
    required String urdu,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        '$stepNumber. $title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      urdu,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: accentColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _conductCard({
    required String code,
    required String title,
    required String urdu,
    required String subtitle,
  }) {
    final isSelected = _selectedConduct == code;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedConduct = code);
          _syncOverridesToController();
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFF16A34A) : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? const Color(0xFF14532D) : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                urdu,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? const Color(0xFF166534) : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  subtitle,
                  style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMasterRecordCard(Student s) {
    final clsName = _attCtrl.selectedClass.value?.name ?? 'Class';
    final isFemale = s.gender.toLowerCase() == 'female';
    final genderLabel = isFemale ? 'Female (لڑکی)' : 'Male (لڑکا)';
    final admDt = PdfGeneratorService.parseFlexibleDate(s.admissionDate);
    final formattedAdmDate = admDt != null ? DateFormat('dd-MM-yyyy').format(admDt) : s.admissionDate;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_rounded, size: 16, color: Color(0xFF166534)),
                  SizedBox(width: 6),
                  Text(
                    'School Register Verified Data',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF14532D)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: const Text(
                  'KPK Master Record',
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF166534)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 3-Column Info Bar
          Row(
            children: [
              _infoTile('Class', clsName),
              const SizedBox(width: 8),
              _infoTile('Gender', genderLabel),
              const SizedBox(width: 8),
              _infoTile('Admission', formattedAdmDate),
            ],
          ),
          const SizedBox(height: 8),

          // Date of Birth & Form-B
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'DOB (تاریخ پیدائش):  $_dobFiguresStr',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF14532D)),
                    ),
                    if (_activeBForm.isNotEmpty)
                      Text(
                        'Form-B: $_activeBForm',
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'In Words: $_dobWordsStr',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFDCFCE7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _alignedField({
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _quickPills(List<String> suggestions, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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

  // -------------------------------------------------------------
  // TAB 2: LIVE DIGITAL CERTIFICATE PREVIEW
  // -------------------------------------------------------------
  Widget _buildLiveCertificateTab() {
    final s = _activeStudent!;
    final schoolName = _school?.name ?? 'Government Primary School';
    final emisCode = _school?.code ?? '27289';
    final clsName = _attCtrl.selectedClass.value?.name ?? 'Class 5';

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
      children: [
        // Realistic Official KPK Certificate Card
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8), // Ivory paper tone
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0F5132), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top Seal / Government Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text('Book: ${_fileNoCtrl.text}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                    Text(
                      _isDuplicate ? 'DUPLICATE COPY (مثنیٰ)' : 'ORIGINAL (اصلی)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: _isDuplicate ? const Color(0xFFB45309) : const Color(0xFF0F5132),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text('Cert #: ${_certNoCtrl.text}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                const Text(
                  'GOVERNMENT OF KHYBER PAKHTUNKHWA',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: Color(0xFF0F5132)),
                ),
                const Text(
                  'ELEMENTARY & SECONDARY EDUCATION DEPARTMENT',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 6),

                Text(
                  schoolName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                ),
                Text(
                  'EMIS CODE: $emisCode • CLASS: $clsName',
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5132),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'SCHOOL LEAVING & CHARACTER CERTIFICATE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'سرٹیفکیٹ داخل خارج و چال چلن',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF0F5132)),
                ),
                const Divider(height: 20, thickness: 1.2, color: Color(0xFF0F5132)),

                // Official Certificate Body Statement
                Text(
                  'Certified that ${s.fullName} son/daughter of ${s.fatherOrGuardianName}, resident of ${_nationalityCtrl.text.isEmpty ? "KPK" : _nationalityCtrl.text}, was admitted to this institution under Admission No. ${s.admissionNumber} and left the school on ${_leavingDateCtrl.text}.',
                  textAlign: TextAlign.justify,
                  style: const TextStyle(fontSize: 12, height: 1.45, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 12),

                // Official Particulars Table
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Column(
                    children: [
                      _certRow('Date of Birth (Figures)', _dobFiguresStr),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _certRow('Date of Birth (In Words)', _dobWordsStr),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _certRow('Form-B / B-Form No', _activeBForm.isEmpty ? 'Verified on Record' : _activeBForm),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _certRow('Academic Standing', _promotedStatusCtrl.text.isEmpty ? 'Class 5 Pass' : _promotedStatusCtrl.text),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _certRow('Reason for Leaving', _leavingReasonCtrl.text.isEmpty ? 'Passed Primary Examination' : _leavingReasonCtrl.text),
                      const Divider(height: 1, color: Color(0xFFE2E8F0)),
                      _certRow('Character & Conduct', _selectedConduct),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Signature Lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(width: 100, height: 1, color: const Color(0xFF475569)),
                        const SizedBox(height: 3),
                        const Text('Class Teacher', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Color(0xFF475569))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(width: 120, height: 1, color: const Color(0xFF0F5132)),
                        const SizedBox(height: 3),
                        const Text('Head Teacher / Seal', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF0F5132))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _certRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // SEARCHABLE STUDENT PICKER SHEET
  // -------------------------------------------------------------
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
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Student (طالب علم منتخب کریں)',
                            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${filtered.length} students',
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

  // -------------------------------------------------------------
  // STICKY BOTTOM BAR
  // -------------------------------------------------------------
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
                      'Preview PDF',
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
                      isGenerating ? 'Generating...' : 'Print / Issue SLC',
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
