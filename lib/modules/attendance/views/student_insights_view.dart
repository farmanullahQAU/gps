import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/kpk_register_helper.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../../../core/widgets/student_avatar.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/student_repository.dart';
import '../../admin/admin_controller.dart';
import '../../auth/auth_controller.dart';
import '../../pdf_reports/pdf_generator_service.dart';
import '../attendance_controller.dart';
import 'student_dossier_view.dart';

/// Professional, executive Student Attendance Intelligence & Parent WhatsApp Tracker
/// designed for Head Teachers and School Staff in Khyber Pakhtunkhwa (KPK):
///
/// Tab 1: 📊 Student Analytics
/// - Smart Period Presets: This Week (Mon–Sat), This Month, Previous Month, Full Year, Custom
/// - Executive Cockpit KPIs: Class Attendance Rate, Present Avg, Total Absences, Defaulters
/// - Essential Administrative Filters:
///   * 🚨 Most Absent (Defaulters ranked by highest absent days)
///   * ⚠️ Low Attendance (<75% KPK E&SED policy threshold)
///   * ⏰ Late Arrivals
///   * 📝 Approved Leaves
///   * ⭐ 100% Perfect Attendance
///   * 👥 All Students (By Roll No)
/// - Single-tap navigation to the comprehensive StudentDossierView
///
/// Tab 2: 💬 Parent WhatsApp Alerts
/// - Segmented by: Absentees, Chronic (<75%), Late Comers, All Parents
/// - Direct 1-tap WhatsApp parent alert with official school notification templates
class StudentInsightsView extends StatefulWidget {
  final int initialTabIndex;
  final bool embedInShell;
  const StudentInsightsView({
    super.key,
    this.initialTabIndex = 0,
    this.embedInShell = false,
  });

  @override
  State<StudentInsightsView> createState() => _StudentInsightsViewState();
}

class _StudentInsightsViewState extends State<StudentInsightsView> {
  final AttendanceController _attCtrl = Get.find<AttendanceController>();
  final AttendanceRepository _attRepo = Get.find<AttendanceRepository>();
  final StudentRepository _studentRepo = Get.find<StudentRepository>();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _activePreset = 'week'; // 'week' | 'month' | 'last_month' | 'session' | 'custom'

  // Analytics Filters: 'all' | 'streak3' | 'most_absent' | 'low_pct' | 'late' | 'leaves' | 'perfect'
  String _analyticsFilter = 'all';

  // Search filter
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  bool _isLoading = true;
  List<StudentPeriodStats> _studentStats = [];
  Worker? _classWorker;

  @override
  void initState() {
    super.initState();
    // Default to "This Week" (Monday of current week to today)
    _applyPreset('week', autoLoad: false);
    _loadAnalytics();

    _classWorker = everAll([_attCtrl.selectedClass, _attCtrl.selectedSection], (_) {
      if (mounted) _loadAnalytics();
    });
  }

  @override
  void dispose() {
    _classWorker?.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyPreset(String preset, {bool autoLoad = true}) {
    final now = DateTime.now();
    setState(() {
      _activePreset = preset;
      switch (preset) {
        case 'week':
          // Current school week starting Monday (weekday 1) to today
          final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
          _startDate = monday;
          _endDate = now;
          break;
        case 'month':
          // Current calendar month (1st of month to today)
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'last_month':
          // Previous full calendar month
          final prevMonthDate = DateTime(now.year, now.month - 1, 1);
          final lastDayOfPrevMonth = DateTime(now.year, now.month, 0);
          _startDate = prevMonthDate;
          _endDate = lastDayOfPrevMonth;
          break;
        case 'session':
          // Full academic year (starting April 1)
          _startDate = DateTime(now.month >= 4 ? now.year : now.year - 1, 4, 1);
          _endDate = now;
          break;
      }
    });

    if (autoLoad) _loadAnalytics();
  }

  Future<void> _pickCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(
        start: _startDate,
        end: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      ),
    );
    if (picked != null) {
      setState(() {
        _activePreset = 'custom';
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadAnalytics();
    }
  }

  Future<void> _loadAnalytics() async {
    final cls = _attCtrl.selectedClass.value;
    final sec = _attCtrl.selectedSection.value;
    if (cls == null || sec == null) {
      setState(() {
        _isLoading = false;
        _studentStats = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final auth = Get.find<AuthController>();
      final schoolId = auth.currentUser.value?.schoolId ?? 'sch_demo_gps_001';
      final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(_endDate);

      final students = await _studentRepo.getStudentsForSection(
        classId: cls.id,
        sectionId: sec.id,
        schoolId: schoolId,
      );
      final records = await _attRepo.getAttendanceForDateRange(
        schoolId: schoolId,
        classId: cls.id,
        sectionId: sec.id,
        startDate: startStr,
        endDate: endStr,
      );
      final allHolidays = await _studentRepo.getAllHolidaysForSchool(schoolId);
      final holidayKeys = allHolidays.map((h) => h.date).toSet();

      final recordsByStudent = <String, List<AttendanceRecord>>{};
      for (final r in records) {
        final dt = DateTime.tryParse(r.date);
        if (dt?.weekday == DateTime.sunday || holidayKeys.contains(r.date)) continue;
        recordsByStudent.putIfAbsent(r.studentId, () => []).add(r);
      }

      final statsList = <StudentPeriodStats>[];
      for (final s in students) {
        final parent = await _studentRepo.getParentContact(s.id);
        final sRecords = recordsByStudent[s.id] ?? [];
        sRecords.sort((a, b) => b.date.compareTo(a.date));

        final admittedMidPeriod =
            s.admissionDate.compareTo(startStr) > 0 && s.admissionDate.compareTo(endStr) <= 0;
        final eligibleDays = PdfGeneratorService.calculateEligibleInstructionalDays(
          startDate: _startDate,
          endDate: _endDate,
          holidayDateKeys: holidayKeys,
          studentAdmissionDate: admittedMidPeriod ? s.admissionDate : null,
        );
        final eligibleSessions = eligibleDays * 2;

        int p = 0, a = 0, lv = 0, lt = 0, hd = 0, units = 0;
        for (final r in sRecords) {
          final mark = KpkDayMark.fromRecord(r);
          units += mark.attendanceUnits;
          switch (r.status) {
            case 'present':
              p++;
              break;
            case 'absent':
              a++;
              break;
            case 'late':
              p++;
              lt++;
              break;
            case 'approved_leave':
              lv++;
              break;
            case 'half_day':
              hd++;
              break;
          }
        }

        // Calculate consecutive absent days from the most recent session backward
        int streakAbsences = 0;
        for (final r in sRecords) {
          if (r.status == 'absent') {
            streakAbsences++;
          } else {
            break;
          }
        }

        final markedDays = p + a + lv + hd;
        final unmarked = (eligibleDays - markedDays).clamp(0, eligibleDays);
        final denom = eligibleDays > 0 ? eligibleDays : 1;
        final effectivePresent = p + (hd * 0.5);
        final pct = eligibleDays > 0
            ? (effectivePresent / denom * 100.0).clamp(0.0, 100.0)
            : 0.0;

        statsList.add(
          StudentPeriodStats(
            student: s,
            parentPhone: parent?.phoneNumber,
            eligibleDays: eligibleDays,
            eligibleSessions: eligibleSessions,
            sessionUnits: units,
            presentDays: p,
            absentDays: a,
            leaveDays: lv + hd,
            lateDays: lt,
            halfDays: hd,
            unmarkedDays: unmarked,
            attendancePercentage: pct,
            consecutiveAbsentDays: streakAbsences,
            chronologicalRecords: sRecords,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _studentStats = statsList;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ---------------------------------------------------------------------------
  // Tab 1 Filtered List: Analytics
  // ---------------------------------------------------------------------------
  List<StudentPeriodStats> get _filteredAnalyticsList {
    final q = _searchQuery.trim().toLowerCase();
    final list = _studentStats.where((item) {
      if (q.isNotEmpty) {
        final s = item.student;
        final match = s.fullName.toLowerCase().contains(q) ||
            s.fatherOrGuardianName.toLowerCase().contains(q) ||
            (s.rollNumber ?? '').toLowerCase().contains(q);
        if (!match) return false;
      }

      switch (_analyticsFilter) {
        case 'streak3':
          return item.consecutiveAbsentDays >= 3;
        case 'most_absent':
          return item.absentDays > 0;
        case 'low_pct':
          return item.attendancePercentage < 75.0;
        case 'late':
          return item.lateDays > 0;
        case 'leaves':
          return item.leaveDays > 0;
        case 'perfect':
          return item.absentDays == 0 && item.attendancePercentage >= 99.0;
        case 'all':
        default:
          return true;
      }
    }).toList();

    // Natural administrative sorting
    switch (_analyticsFilter) {
      case 'streak3':
        list.sort((a, b) => b.consecutiveAbsentDays.compareTo(a.consecutiveAbsentDays));
        break;
      case 'most_absent':
        list.sort((a, b) {
          final cmp = b.absentDays.compareTo(a.absentDays);
          if (cmp != 0) return cmp;
          return a.attendancePercentage.compareTo(b.attendancePercentage);
        });
        break;
      case 'low_pct':
        list.sort((a, b) => a.attendancePercentage.compareTo(b.attendancePercentage));
        break;
      case 'late':
        list.sort((a, b) => b.lateDays.compareTo(a.lateDays));
        break;
      case 'leaves':
        list.sort((a, b) => b.leaveDays.compareTo(a.leaveDays));
        break;
      case 'perfect':
      case 'all':
      default:
        list.sort((a, b) {
          final rA = int.tryParse(a.student.rollNumber ?? '') ?? 999;
          final rB = int.tryParse(b.student.rollNumber ?? '') ?? 999;
          return rA.compareTo(rB);
        });
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final schoolName = Get.find<AdminController>().school.value?.name ??
        'GPS Gulbahar No. 1 Peshawar';
    final className = _attCtrl.selectedClass.value?.name ?? 'Class';

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !widget.embedInShell,
        title: Obx(() {
          final cls = _attCtrl.selectedClass.value?.name ?? 'Class';
          final sec = _attCtrl.selectedSection.value?.name;
          final fmName = _attCtrl.currentClassFormMaster;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'student_attendance'.tr,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              Text(
                sec == null ? '$cls · FM: $fmName' : '$cls · $sec · FM: $fmName',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFFD1FAE5)),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            tooltip: 'change_class'.tr,
            icon: const Icon(Icons.swap_horiz_rounded),
            onPressed: () => showClassPickerSheet(context, _attCtrl),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Top Bar: Period Presets + Unified Search ─────────
                _buildSharedTopBar(),
                // ── Analytics Body ──────────────────────────────────
                Expanded(
                  child: _buildAnalyticsTab(context, className, schoolName),
                ),
              ],
            ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared Top Bar: Period Selector + Search Bar (Used by both tabs)
  // ---------------------------------------------------------------------------
  Widget _buildSharedTopBar() {
    final startStr = DateFormat('d MMM').format(_startDate);
    final endStr = DateFormat('d MMM yyyy').format(_endDate);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        children: [
          // Row 1: Period Presets (Sleek Horizontal Segment Bar)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _periodPill('week', 'This Week'),
                const SizedBox(width: 6),
                _periodPill('month', 'This Month'),
                const SizedBox(width: 6),
                _periodPill('last_month', 'Last Month'),
                const SizedBox(width: 6),
                _periodPill('session', 'Full Session'),
                const SizedBox(width: 6),
                // Custom Date Picker Pill
                GestureDetector(
                  onTap: _pickCustomRange,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    height: 32,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: _activePreset == 'custom'
                          ? AppColors.primaryDark
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _activePreset == 'custom'
                            ? AppColors.primaryDark
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 13,
                          color: _activePreset == 'custom' ? Colors.white : AppColors.primaryDark,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _activePreset == 'custom' ? '$startStr–$endStr' : 'Custom Range',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _activePreset == 'custom' ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Row 2: Unified Search Input
          SizedBox(
            height: 38,
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: 'Search student by name, guardian, or roll number...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.cancel_rounded, size: 16, color: AppColors.textMuted),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: STUDENT ANALYTICS (EXECUTIVE COCKPIT + DETAILED METRICS)
  // ===========================================================================
  Widget _buildAnalyticsTab(BuildContext context, String className, String schoolName) {
    final list = _filteredAnalyticsList;
    final startStr = DateFormat('d MMM').format(_startDate);
    final endStr = DateFormat('d MMM yyyy').format(_endDate);

    final totalEnrolled = _studentStats.length;
    final streak3Count = _studentStats.where((s) => s.consecutiveAbsentDays >= 3).length;
    final mostAbsentCount = _studentStats.where((s) => s.absentDays > 0).length;
    final lowPctCount = _studentStats.where((s) => s.attendancePercentage < 75.0).length;
    final lateCount = _studentStats.where((s) => s.lateDays > 0).length;
    final leavesCount = _studentStats.where((s) => s.leaveDays > 0).length;
    final perfectCount = _studentStats.where((s) => s.absentDays == 0 && s.attendancePercentage >= 99.0).length;

    // Aggregate class performance metrics
    double avgAttendance = 0.0;
    int totalAbsencesLogged = 0;
    if (_studentStats.isNotEmpty) {
      final sumPct = _studentStats.fold<double>(0.0, (acc, s) => acc + s.attendancePercentage);
      avgAttendance = sumPct / _studentStats.length;
      totalAbsencesLogged = _studentStats.fold<int>(0, (acc, s) => acc + s.absentDays);
    }

    return Column(
      children: [
        // ── Executive Cockpit KPI Card ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Class Average Radial Indicator Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: avgAttendance >= 80
                            ? const Color(0xFFF0FDF4)
                            : (avgAttendance >= 70 ? const Color(0xFFFFFBEB) : const Color(0xFFFEF2F2)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: avgAttendance >= 80
                              ? const Color(0xFFBBF7D0)
                              : (avgAttendance >= 70 ? const Color(0xFFFDE68A) : const Color(0xFFFECACA)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${avgAttendance.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: avgAttendance >= 80
                                  ? const Color(0xFF15803D)
                                  : (avgAttendance >= 70 ? const Color(0xFFB45309) : const Color(0xFFB91C1C)),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Class Rate',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // High-Level Summary Grid
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _kpiItem('Enrolled', '$totalEnrolled', Icons.people_outline_rounded, AppColors.primaryDark),
                          _kpiDivider(),
                          _kpiItem('Absences', '$totalAbsencesLogged', Icons.person_off_outlined, const Color(0xFFDC2626)),
                          _kpiDivider(),
                          _kpiItem('Below 75%', '$lowPctCount', Icons.warning_amber_rounded, const Color(0xFFD97706)),
                          _kpiDivider(),
                          _kpiItem('100% Stars', '$perfectCount', Icons.star_border_rounded, const Color(0xFF16A34A)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // ── Filter Strip ────────────────────────────────────────────────────
        Container(
          color: AppColors.bgLight,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _filterChip(
                  id: 'all',
                  icon: Icons.groups_rounded,
                  label: 'All Enrolled',
                  count: totalEnrolled,
                  color: AppColors.primaryDark,
                ),
                if (streak3Count > 0) ...[
                  const SizedBox(width: 6),
                  _filterChip(
                    id: 'streak3',
                    icon: Icons.error_outline_rounded,
                    label: '3+ Days Streak',
                    count: streak3Count,
                    color: const Color(0xFFB91C1C),
                  ),
                ],
                const SizedBox(width: 6),
                _filterChip(
                  id: 'most_absent',
                  icon: Icons.person_off_rounded,
                  label: 'Most Absent',
                  count: mostAbsentCount,
                  color: AppColors.absent,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  id: 'low_pct',
                  icon: Icons.warning_amber_rounded,
                  label: 'Below 75%',
                  count: lowPctCount,
                  color: const Color(0xFFDC2626),
                ),
                const SizedBox(width: 6),
                _filterChip(
                  id: 'late',
                  icon: Icons.schedule_rounded,
                  label: 'Late Comers',
                  count: lateCount,
                  color: AppColors.late,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  id: 'leaves',
                  icon: Icons.event_note_rounded,
                  label: 'On Leave',
                  count: leavesCount,
                  color: AppColors.leave,
                ),
                const SizedBox(width: 6),
                _filterChip(
                  id: 'perfect',
                  icon: Icons.star_rounded,
                  label: '100% Stars',
                  count: perfectCount,
                  color: const Color(0xFF16A34A),
                ),
              ],
            ),
          ),
        ),

        // ── Student Cards List ──────────────────────────────────────────────
        Expanded(
          child: list.isEmpty
              ? _emptyState('No students match this filter for $startStr – $endStr.')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) => _buildStudentCard(context, list[i], className, schoolName),
                ),
        ),
      ],
    );
  }

  Widget _kpiItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _kpiDivider() {
    return Container(
      width: 1,
      height: 24,
      color: const Color(0xFFE2E8F0),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    StudentPeriodStats item,
    String className,
    String schoolName,
  ) {
    final s = item.student;
    final pct = item.attendancePercentage;
    final isLowPct = pct < 75.0;

    final Color statusColor = pct >= 85
        ? const Color(0xFF16A34A)
        : (pct >= 75 ? const Color(0xFFD97706) : const Color(0xFFDC2626));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLowPct ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
          width: isLowPct ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openDossier(context, item, className, schoolName),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Real Student Avatar with R2 & Local File support
                StudentAvatar(
                  name: s.fullName,
                  photoUrl: s.photoUrl,
                  gender: s.gender,
                  radius: 22,
                ),
                const SizedBox(width: 12),

                // Core Student Information (Concise, Clean)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Roll Number badge
                          if (s.rollNumber != null && s.rollNumber!.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: Text(
                                '#${s.rollNumber}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              s.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'S/O ${s.fatherOrGuardianName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Attendance Metric Pills (Present, Absent, Leave)
                      Row(
                        children: [
                          _metricPill('${item.presentDays}P', const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
                          const SizedBox(width: 5),
                          if (item.absentDays > 0) ...[
                            _metricPill('${item.absentDays}A', const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
                            const SizedBox(width: 5),
                          ],
                          if (item.lateDays > 0) ...[
                            _metricPill('${item.lateDays}L', const Color(0xFFB45309), const Color(0xFFFEF3C7)),
                            const SizedBox(width: 5),
                          ],
                          if (item.leaveDays > 0) ...[
                            _metricPill('${item.leaveDays}Lv', const Color(0xFF0369A1), const Color(0xFFE0F2FE)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Attendance Percentage Circular Badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isLowPct
                            ? const Color(0xFFFEF2F2)
                            : statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isLowPct
                              ? const Color(0xFFFCA5A5)
                              : statusColor.withValues(alpha: 0.3),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: isLowPct ? const Color(0xFFB91C1C) : statusColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metricPill(String text, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }





  void _openDossier(
    BuildContext context,
    StudentPeriodStats stats,
    String className,
    String schoolName,
  ) {
    Get.to(
      () => StudentDossierView(
        stats: stats,
        className: className,
        schoolName: schoolName,
        startDate: _startDate,
        endDate: _endDate,
        onPhoneUpdated: _loadAnalytics,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper Micro-Widgets
  // ---------------------------------------------------------------------------
  Widget _periodPill(String key, String label) {
    final selected = _activePreset == key;
    return GestureDetector(
      onTap: () => _applyPreset(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.primaryDark : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Compact, tactile filter chip for the Analytics tab
  Widget _filterChip({
    required String id,
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    final selected = _analyticsFilter == id;
    return GestureDetector(
      onTap: () => setState(() => _analyticsFilter = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? color : color.withValues(alpha: 0.28),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: selected ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: selected ? Colors.white.withValues(alpha: 0.25) : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _emptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 36, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
