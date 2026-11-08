import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/auth_controller.dart';
import '../pdf_generator_service.dart';
import '../pdf_reports_controller.dart';

/// Professional, comprehensive KPK School Performance Report & Monthly Goshwara View
/// (ماہانہ گوشوارہ - محکمہ ابتدائی و ثانوی تعلیم حکومت خیبر پختونخوا)
class MonthlyGoshwaraView extends StatefulWidget {
  const MonthlyGoshwaraView({super.key});

  @override
  State<MonthlyGoshwaraView> createState() => _MonthlyGoshwaraViewState();
}

class _MonthlyGoshwaraViewState extends State<MonthlyGoshwaraView> with SingleTickerProviderStateMixin {
  final PdfReportsController _reportCtrl = Get.find<PdfReportsController>();
  final AuthController _authCtrl = Get.find<AuthController>();

  late TabController _tabCtrl;
  bool _isLoading = true;
  bool _isSaving = false;

  // Header & Administrative Controllers
  final TextEditingController _goshwaraNoCtrl = TextEditingController(text: '01');
  final TextEditingController _naCtrl = TextEditingController(text: 'NA-5');
  final TextEditingController _pkCtrl = TextEditingController(text: 'PK-12');
  final TextEditingController _ltrcCtrl = TextEditingController(text: 'Akhagram');
  final TextEditingController _headTeacherCtrl = TextEditingController();
  final TextEditingController _centerInchargeCtrl = TextEditingController();
  final TextEditingController _circleSdeoCtrl = TextEditingController();

  // Building & Facilities Controllers
  final TextEditingController _estYearCtrl = TextEditingController(text: '1976');
  final TextEditingController _constYearCtrl = TextEditingController(text: '1987');
  final TextEditingController _classroomsCtrl = TextEditingController(text: '3');
  final TextEditingController _nonClassroomsCtrl = TextEditingController(text: '0');
  final TextEditingController _toiletsCtrl = TextEditingController(text: '2');

  // Facilities Checkboxes
  bool _facElectricity = true;
  bool _facWaterPipe = true;
  bool _facWaterWell = false;
  bool _facSolar = true;
  bool _facBoundaryWall = true;
  bool _facPlayArea = false;
  bool _facOffice = true;

  // Staff Posts
  final TextEditingController _pshtPostsCtrl = TextEditingController(text: '1');
  final TextEditingController _spstPostsCtrl = TextEditingController(text: '4');
  final TextEditingController _pstPostsCtrl = TextEditingController(text: '4');
  final TextEditingController _vacantPstCtrl = TextEditingController(text: '0');
  final TextEditingController _vacantChowkidarCtrl = TextEditingController(text: '0');

  // PTC Information
  final TextEditingController _ptcChairmanCtrl = TextEditingController();
  final TextEditingController _ptcBankCtrl = TextEditingController(text: 'HBL Akhagram');
  final TextEditingController _ptcAccountCtrl = TextEditingController(text: '559-3');
  final TextEditingController _ptcSanctionCtrl = TextEditingController(text: '20-11-2018');
  final TextEditingController _fundBudgetCtrl = TextEditingController(text: '356000');
  final TextEditingController _fundSpentCtrl = TextEditingController(text: '353000');

  SchoolSettingsModel _currentSettings = const SchoolSettingsModel(schoolId: '');
  List<User> _teachers = [];
  Map<String, TeacherGoshwaraProfile> _teacherProfiles = {};

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _reportCtrl.selectedReportType.value = ReportType.monthlyGoshwara;
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _goshwaraNoCtrl.dispose();
    _naCtrl.dispose();
    _pkCtrl.dispose();
    _ltrcCtrl.dispose();
    _headTeacherCtrl.dispose();
    _centerInchargeCtrl.dispose();
    _circleSdeoCtrl.dispose();
    _estYearCtrl.dispose();
    _constYearCtrl.dispose();
    _classroomsCtrl.dispose();
    _nonClassroomsCtrl.dispose();
    _toiletsCtrl.dispose();
    _pshtPostsCtrl.dispose();
    _spstPostsCtrl.dispose();
    _pstPostsCtrl.dispose();
    _vacantPstCtrl.dispose();
    _vacantChowkidarCtrl.dispose();
    _ptcChairmanCtrl.dispose();
    _ptcBankCtrl.dispose();
    _ptcAccountCtrl.dispose();
    _ptcSanctionCtrl.dispose();
    _fundBudgetCtrl.dispose();
    _fundSpentCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final schoolId = _authCtrl.currentUser.value?.schoolId ?? '';
    if (schoolId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final s = await _reportCtrl.studentRepository.getSchoolSettings(schoolId);
      final tList = await _reportCtrl.studentRepository.getTeachers(schoolId);
      final profiles = <String, TeacherGoshwaraProfile>{};
      for (final t in tList) {
        profiles[t.id] = await _reportCtrl.studentRepository.getTeacherGoshwaraProfile(t.id);
      }

      setState(() {
        _currentSettings = s;
        _teachers = tList;
        _teacherProfiles = profiles;

        _goshwaraNoCtrl.text = s.goshwaraNo.isNotEmpty ? s.goshwaraNo : '01';
        _naCtrl.text = s.naConstituency.isNotEmpty ? s.naConstituency : 'NA-5';
        _pkCtrl.text = s.pkConstituency.isNotEmpty ? s.pkConstituency : 'PK-12';
        _ltrcCtrl.text = s.ltrcCenter.isNotEmpty ? s.ltrcCenter : 'Akhagram';
        _headTeacherCtrl.text = s.headTeacherName.isNotEmpty ? s.headTeacherName : 'Head Teacher';
        _centerInchargeCtrl.text = s.centerInchargeName;
        _circleSdeoCtrl.text = s.circleSdeoName;

        _estYearCtrl.text = s.establishmentYear.isNotEmpty ? s.establishmentYear : '1976';
        _constYearCtrl.text = s.constructionYear.isNotEmpty ? s.constructionYear : '1987';
        _classroomsCtrl.text = '${s.classroomsInstructional}';
        _nonClassroomsCtrl.text = '${s.classroomsNonInstructional}';
        _toiletsCtrl.text = '${s.facilityToiletCount}';

        _facElectricity = s.facilityElectricity;
        _facWaterPipe = s.facilityWaterPipe;
        _facWaterWell = s.facilityWaterWell;
        _facSolar = s.facilitySolar;
        _facBoundaryWall = s.facilityBoundaryWall;
        _facPlayArea = s.facilityPlayArea;
        _facOffice = s.facilityOffice;

        _pshtPostsCtrl.text = '${s.sanctionedPostsPsht}';
        _spstPostsCtrl.text = '${s.sanctionedPostsSpst}';
        _pstPostsCtrl.text = '${s.sanctionedPostsPst}';
        _vacantPstCtrl.text = '${s.vacantPostsPst}';
        _vacantChowkidarCtrl.text = '${s.vacantPostsChowkidar}';

        _ptcChairmanCtrl.text = s.ptcChairmanName;
        _ptcBankCtrl.text = s.ptcBankName.isNotEmpty ? s.ptcBankName : 'HBL Akhagram';
        _ptcAccountCtrl.text = s.ptcAccountNo.isNotEmpty ? s.ptcAccountNo : '559-3';
        _ptcSanctionCtrl.text = s.ptcSanctionDate.isNotEmpty ? s.ptcSanctionDate : '20-11-2018';
        _fundBudgetCtrl.text = s.fundTotalBudget > 0 ? s.fundTotalBudget.toInt().toString() : '356000';
        _fundSpentCtrl.text = s.fundTotalSpent > 0 ? s.fundTotalSpent.toInt().toString() : '353000';
      });
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings({bool showToast = true}) async {
    final schoolId = _authCtrl.currentUser.value?.schoolId ?? '';
    if (schoolId.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      final updated = _currentSettings.copyWith(
        schoolId: schoolId,
        goshwaraNo: _goshwaraNoCtrl.text.trim(),
        naConstituency: _naCtrl.text.trim(),
        pkConstituency: _pkCtrl.text.trim(),
        ltrcCenter: _ltrcCtrl.text.trim(),
        headTeacherName: _headTeacherCtrl.text.trim(),
        centerInchargeName: _centerInchargeCtrl.text.trim(),
        circleSdeoName: _circleSdeoCtrl.text.trim(),
        establishmentYear: _estYearCtrl.text.trim(),
        constructionYear: _constYearCtrl.text.trim(),
        classroomsInstructional: int.tryParse(_classroomsCtrl.text.trim()) ?? 3,
        classroomsNonInstructional: int.tryParse(_nonClassroomsCtrl.text.trim()) ?? 0,
        facilityToiletCount: int.tryParse(_toiletsCtrl.text.trim()) ?? 2,
        facilityElectricity: _facElectricity,
        facilityWaterPipe: _facWaterPipe,
        facilityWaterWell: _facWaterWell,
        facilitySolar: _facSolar,
        facilityBoundaryWall: _facBoundaryWall,
        facilityPlayArea: _facPlayArea,
        facilityOffice: _facOffice,
        sanctionedPostsPsht: int.tryParse(_pshtPostsCtrl.text.trim()) ?? 1,
        sanctionedPostsSpst: int.tryParse(_spstPostsCtrl.text.trim()) ?? 4,
        sanctionedPostsPst: int.tryParse(_pstPostsCtrl.text.trim()) ?? 4,
        vacantPostsPst: int.tryParse(_vacantPstCtrl.text.trim()) ?? 0,
        vacantPostsChowkidar: int.tryParse(_vacantChowkidarCtrl.text.trim()) ?? 0,
        ptcChairmanName: _ptcChairmanCtrl.text.trim(),
        ptcBankName: _ptcBankCtrl.text.trim(),
        ptcAccountNo: _ptcAccountCtrl.text.trim(),
        ptcSanctionDate: _ptcSanctionCtrl.text.trim(),
        fundTotalBudget: double.tryParse(_fundBudgetCtrl.text.trim()) ?? 0.0,
        fundTotalSpent: double.tryParse(_fundSpentCtrl.text.trim()) ?? 0.0,
      );

      await _reportCtrl.saveSchoolSettings(updated);
      _currentSettings = updated;

      if (showToast && mounted) {
        Get.snackbar(
          'Saved',
          'Monthly Goshwara specifications saved successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFDCFCE7),
          colorText: const Color(0xFF166534),
        );
      }
    } catch (e) {
      if (showToast && mounted) {
        Get.snackbar('Save Error', 'Failed to save Goshwara specifications: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _editTeacherProfile(User teacher) {
    final currentProf = _teacherProfiles[teacher.id] ?? TeacherGoshwaraProfile(userId: teacher.id);

    final fatherCtrl = TextEditingController(text: currentProf.fatherName);
    final personalNoCtrl = TextEditingController(text: currentProf.personalNo);
    final dobCtrl = TextEditingController(text: currentProf.dob);
    final acadCtrl = TextEditingController(text: currentProf.academicQualification);
    final profCtrl = TextEditingController(text: currentProf.professionalQualification);
    final apptCtrl = TextEditingController(text: currentProf.appointmentDate);
    final transferCtrl = TextEditingController(text: currentProf.transferInDate);
    final bpsCtrl = TextEditingController(text: currentProf.currentBps);
    final bpsDateCtrl = TextEditingController(text: currentProf.bpsAwardDate);
    final payCtrl = TextEditingController(text: currentProf.basicPay > 0 ? currentProf.basicPay.toInt().toString() : '');
    final villageCtrl = TextEditingController(text: currentProf.village);
    String empType = currentProf.employmentType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.88,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Modal Handle & Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border(bottom: BorderSide(color: AppColors.border)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.badge_outlined, size: 20, color: AppColors.primaryDark),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.name,
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              'Goshwara Staff Particulars (کوائف ملازم)',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),

                // Form Fields List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _shortFieldRow(
                        label1: "Father's Name (ولدیت)",
                        ctrl1: fatherCtrl,
                        label2: 'Personal # (پرسنل نمبر)',
                        ctrl2: personalNoCtrl,
                      ),
                      const SizedBox(height: 10),
                      _shortFieldRow(
                        label1: 'DOB (تاریخ پیدائش)',
                        ctrl1: dobCtrl,
                        label2: 'Academic (تعلیمی قابلیت)',
                        ctrl2: acadCtrl,
                      ),
                      const SizedBox(height: 10),
                      _shortFieldRow(
                        label1: 'Prof. Qual (پیشہ ورانہ)',
                        ctrl1: profCtrl,
                        label2: 'Appt Date (آغاز ملازمت)',
                        ctrl2: apptCtrl,
                      ),
                      const SizedBox(height: 10),
                      _shortFieldRow(
                        label1: 'School Date (تاریخ ہذا اسکول)',
                        ctrl1: transferCtrl,
                        label2: 'BPS (موجودہ اسکیل)',
                        ctrl2: bpsCtrl,
                      ),
                      const SizedBox(height: 10),
                      _shortFieldRow(
                        label1: 'Scale Date (تاریخ اسکیل)',
                        ctrl1: bpsDateCtrl,
                        label2: 'Basic Pay (تنخواہ PKR)',
                        ctrl2: payCtrl,
                      ),
                      const SizedBox(height: 10),
                      _shortFieldRow(
                        label1: 'Village / Address (گاؤں)',
                        ctrl1: villageCtrl,
                        label2: 'Employment Type',
                        customWidget2: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: empType,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(value: 'permanent', child: Text('Permanent (مستقل)', style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: 'fixed', child: Text('Fixed Pay (عارضی)', style: TextStyle(fontSize: 12))),
                              ],
                              onChanged: (val) {
                                if (val != null) setModalState(() => empType = val);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Save Modal Button
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Save Staff Particulars', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        onPressed: () async {
                          final updated = currentProf.copyWith(
                            fatherName: fatherCtrl.text.trim(),
                            personalNo: personalNoCtrl.text.trim(),
                            dob: dobCtrl.text.trim(),
                            academicQualification: acadCtrl.text.trim(),
                            professionalQualification: profCtrl.text.trim(),
                            appointmentDate: apptCtrl.text.trim(),
                            transferInDate: transferCtrl.text.trim(),
                            currentBps: bpsCtrl.text.trim(),
                            bpsAwardDate: bpsDateCtrl.text.trim(),
                            basicPay: double.tryParse(payCtrl.text.trim()) ?? 0.0,
                            village: villageCtrl.text.trim(),
                            employmentType: empType,
                          );

                          await _reportCtrl.saveTeacherGoshwaraProfile(updated);
                          if (!mounted) return;
                          setState(() {
                            _teacherProfiles[teacher.id] = updated;
                          });
                          Get.back();
                          Get.snackbar(
                            'Saved',
                            'Staff particulars updated for ${teacher.name}',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFFDCFCE7),
                            colorText: const Color(0xFF166534),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat('MMMM yyyy').format(_reportCtrl.startDate.value);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Performance Goshwara',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            Text(
              'ماہانہ گوشوارہ و کارکردگی رپورٹ • $monthName',
              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFFA7F3D0)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            tooltip: 'Save Specifications',
            onPressed: _isSaving ? null : () => _saveSettings(),
          ),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: const Color(0xFF86EFAC),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          tabs: const [
            Tab(text: 'Staff (اسٹاف)'),
            Tab(text: 'Facilities (وسائل)'),
            Tab(text: 'Posts & PTC'),
            Tab(text: 'Admin (حلقہ)'),
          ],
        ),
      ),
      bottomNavigationBar: _buildStickyBottomBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabCtrl,
              children: [
                _buildStaffTab(),
                _buildFacilitiesTab(),
                _buildPostsAndPtcTab(),
                _buildAdminTab(),
              ],
            ),
    );
  }

  Widget _buildStaffTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF166534)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap any staff member below to update Goshwara particulars (Father name, Personal #, DOB, Qualifications, Scale & Pay).',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_teachers.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Center(
              child: Text(
                'No staff members found in school directory.\nRegister teaching and non-teaching staff in Faculty & Staff tab.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ..._teachers.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final t = entry.value;
            final prof = _teacherProfiles[t.id];
            final post = (t.designation != null && t.designation!.isNotEmpty)
                ? (t.designation!.contains('(') ? t.designation!.split('(').last.replaceAll(')', '').trim() : t.designation!)
                : 'PST';
            final payStr = (prof != null && prof.basicPay > 0)
                ? 'PKR ${NumberFormat('#,##0').format(prof.basicPay)}'
                : 'Pay not set';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListTile(
                onTap: () => _editTeacherProfile(t),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryDark.withValues(alpha: 0.1),
                  child: Text(
                    '$idx',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                  ),
                ),
                title: Text(
                  t.name,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  'S/O ${prof?.fatherName.isNotEmpty == true ? prof!.fatherName : "___"} • $post • BPS ${prof?.currentBps ?? "14"} • $payStr',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                trailing: const Icon(Icons.edit_note_rounded, size: 22, color: AppColors.primaryDark),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildFacilitiesTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        _formSectionCard(
          title: 'Building & Classrooms (اسکول عمارت و کمرے)',
          children: [
            _shortFieldRow(
              label1: 'Est. Year (سالِ اجراء)',
              ctrl1: _estYearCtrl,
              label2: 'Const. Year (سالِ تعمیر)',
              ctrl2: _constYearCtrl,
            ),
            const SizedBox(height: 10),
            _shortFieldRow(
              label1: 'Instructional Rooms (تدریسی)',
              ctrl1: _classroomsCtrl,
              label2: 'Non-Instructional (غیر تدریسی)',
              ctrl2: _nonClassroomsCtrl,
            ),
            const SizedBox(height: 10),
            _labeledInput('Toilet Blocks Count (تعداد گروپ لیٹرین)', _toiletsCtrl),
          ],
        ),
        const SizedBox(height: 14),
        _formSectionCard(
          title: 'Utilities & Infrastructure (سہولیات)',
          children: [
            _switchTile('Electricity (بجلی)', _facElectricity, (v) => setState(() => _facElectricity = v)),
            _switchTile('Water Pipe / Tap (پانی نلکا / پائپ)', _facWaterPipe, (v) => setState(() => _facWaterPipe = v)),
            _switchTile('Water Well / Spring (پانی کنواں / چشمہ)', _facWaterWell, (v) => setState(() => _facWaterWell = v)),
            _switchTile('Solar Plant (سولر پلانٹ)', _facSolar, (v) => setState(() => _facSolar = v)),
            _switchTile('Boundary Wall (چاردیواری)', _facBoundaryWall, (v) => setState(() => _facBoundaryWall = v)),
            _switchTile('Play Area (پلے ایریا)', _facPlayArea, (v) => setState(() => _facPlayArea = v)),
            _switchTile('Staff / Head Office (دفتر)', _facOffice, (v) => setState(() => _facOffice = v)),
          ],
        ),
      ],
    );
  }

  Widget _buildPostsAndPtcTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        _formSectionCard(
          title: 'Staff Posts & Vacancies (اسکول اسامیاں)',
          children: [
            _shortFieldRow(
              label1: 'Sanctioned PSHT (ہیڈ ٹیچر)',
              ctrl1: _pshtPostsCtrl,
              label2: 'Sanctioned SPST (سینئر استاد)',
              ctrl2: _spstPostsCtrl,
            ),
            const SizedBox(height: 10),
            _shortFieldRow(
              label1: 'Sanctioned PST (پرائمری ٹیچر)',
              ctrl1: _pstPostsCtrl,
              label2: 'Vacant PST (خالی اسامیاں PST)',
              ctrl2: _vacantPstCtrl,
            ),
            const SizedBox(height: 10),
            _labeledInput('Vacant Chowkidar (خالی چوکیدار)', _vacantChowkidarCtrl),
          ],
        ),
        const SizedBox(height: 14),
        _formSectionCard(
          title: 'PTC Information & Construction Fund (پیرنٹ ٹیچر کونسل)',
          children: [
            _shortFieldRow(
              label1: 'PTC Chairman (چیئرمین کا نام)',
              ctrl1: _ptcChairmanCtrl,
              label2: 'Bank Name (بینک کا نام)',
              ctrl2: _ptcBankCtrl,
            ),
            const SizedBox(height: 10),
            _shortFieldRow(
              label1: 'Account No (اکاؤنٹ نمبر)',
              ctrl1: _ptcAccountCtrl,
              label2: 'Sanction Date (تاریخ اجراء)',
              ctrl2: _ptcSanctionCtrl,
            ),
            const SizedBox(height: 10),
            _shortFieldRow(
              label1: 'Total Fund / Budget (کل رقم)',
              ctrl1: _fundBudgetCtrl,
              label2: 'Total Spent (خرچ شدہ رقم)',
              ctrl2: _fundSpentCtrl,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
      children: [
        _formSectionCard(
          title: 'Constituency & Center (حلقہ و سنٹر)',
          children: [
            _shortFieldRow(
              label1: 'Goshwara No (گوشوارہ نمبر)',
              ctrl1: _goshwaraNoCtrl,
              label2: 'LTRC / Center (سنٹر)',
              ctrl2: _ltrcCtrl,
            ),
            const SizedBox(height: 10),
            _shortFieldRow(
              label1: 'Provincial Assembly (صوبائی)',
              ctrl1: _pkCtrl,
              label2: 'National Assembly (قومی)',
              ctrl2: _naCtrl,
            ),
          ],
        ),
        const SizedBox(height: 14),
        _formSectionCard(
          title: 'Administration & Signatories (دستخط کنندگان)',
          children: [
            _labeledInput('Head Teacher Name (نام ہیڈ ٹیچر)', _headTeacherCtrl),
            const SizedBox(height: 10),
            _labeledInput('Center Incharge (نام سنٹر انچارج)', _centerInchargeCtrl),
            const SizedBox(height: 10),
            _labeledInput('Circle SDEO (نام سرکل SDEO)', _circleSdeoCtrl),
          ],
        ),
      ],
    );
  }

  Widget _formSectionCard({required String title, required List<Widget> children}) {
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
          Text(
            title,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _shortFieldRow({
    required String label1,
    TextEditingController? ctrl1,
    Widget? customWidget1,
    required String label2,
    TextEditingController? ctrl2,
    Widget? customWidget2,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              customWidget1 ??
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: ctrl1,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      decoration: _inputDeco(),
                    ),
                  ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              customWidget2 ??
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: ctrl2,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      decoration: _inputDeco(),
                    ),
                  ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _labeledInput(String label, TextEditingController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 40,
          child: TextField(
            controller: ctrl,
            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            decoration: _inputDeco(),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
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
    );
  }

  Widget _switchTile(String title, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Switch(
            value: value,
            activeThumbColor: AppColors.primaryDark,
            onChanged: onChanged,
          ),
        ],
      ),
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
                      'Preview Goshwara',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    onPressed: isGenerating
                        ? null
                        : () async {
                            await _saveSettings(showToast: false);
                            _reportCtrl.selectedReportType.value = ReportType.monthlyGoshwara;
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
                      isGenerating ? 'Generating...' : 'Print / Export',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    onPressed: isGenerating
                        ? null
                        : () async {
                            await _saveSettings(showToast: false);
                            _reportCtrl.selectedReportType.value = ReportType.monthlyGoshwara;
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
