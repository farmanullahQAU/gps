import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/kpk_register_helper.dart';
import '../../../core/widgets/student_avatar.dart';
import '../../students/views/enroll_student_view.dart';
import '../../students/views/student_id_card_view.dart';
import '../../students/views/whatsapp_parent_alert_view.dart';

/// Period statistics for an individual student
class StudentPeriodStats {
  final Student student;
  final String? parentPhone;
  final int eligibleDays;
  final int eligibleSessions;
  final int sessionUnits;
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final int lateDays;
  final int halfDays;
  final int unmarkedDays;
  final double attendancePercentage;
  final int consecutiveAbsentDays;
  final List<AttendanceRecord> chronologicalRecords;

  const StudentPeriodStats({
    required this.student,
    required this.parentPhone,
    required this.eligibleDays,
    required this.eligibleSessions,
    required this.sessionUnits,
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.lateDays,
    required this.halfDays,
    required this.unmarkedDays,
    required this.attendancePercentage,
    this.consecutiveAbsentDays = 0,
    required this.chronologicalRecords,
  });
}

/// Executive Student Attendance Dossier:
/// Modern, clean, and intuitive profile & attendance history designed with KPK E&SED standards.
class StudentDossierView extends StatefulWidget {
  final StudentPeriodStats stats;
  final String className;
  final String schoolName;
  final DateTime startDate;
  final DateTime endDate;
  final VoidCallback? onPhoneUpdated;

  const StudentDossierView({
    super.key,
    required this.stats,
    required this.className,
    required this.schoolName,
    required this.startDate,
    required this.endDate,
    this.onPhoneUpdated,
  });

  @override
  State<StudentDossierView> createState() => _StudentDossierViewState();
}

class _StudentDossierViewState extends State<StudentDossierView> {
  String _historyFilter = 'all'; // 'all' | 'absent' | 'late' | 'leave'

  StudentPeriodStats get _stats => widget.stats;
  Student get _student => _stats.student;

  List<AttendanceRecord> get _filteredHistory {
    if (_historyFilter == 'all') return _stats.chronologicalRecords;
    return _stats.chronologicalRecords.where((r) {
      if (_historyFilter == 'absent') return r.status == 'absent';
      if (_historyFilter == 'late') return r.status == 'late';
      if (_historyFilter == 'leave') {
        return r.status == 'approved_leave' || r.status == 'half_day';
      }
      return true;
    }).toList();
  }

  void _openWhatsApp(String initialType) {
    Get.to(
      () => WhatsAppParentAlertView(
        student: _student,
        className: widget.className,
        schoolName: widget.schoolName,
        initialType: initialType,
        absentDays: _stats.absentDays,
        attendancePct: _stats.attendancePercentage.toStringAsFixed(1),
        onPhoneUpdated: widget.onPhoneUpdated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pct = _stats.attendancePercentage;
    final Color statusColor = pct >= 85
        ? const Color(0xFF16A34A)
        : (pct >= 75 ? const Color(0xFFD97706) : const Color(0xFFDC2626));

    final periodRange =
        '${DateFormat('d MMM').format(widget.startDate)} – ${DateFormat('d MMM yyyy').format(widget.endDate)}';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          _student.fullName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: () => Get.to(() => EnrollStudentView(studentToEdit: _student)),
          ),
          IconButton(
            tooltip: 'QR ID Card',
            icon: const Icon(Icons.qr_code_2_rounded, size: 22),
            onPressed: () => Get.to(
              () => StudentIdCardView(
                student: _student,
                schoolName: widget.schoolName,
                className: widget.className,
                sectionName: '',
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      bottomNavigationBar: _buildStickyWhatsAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // 1. Sleek Student Identity Card
          _buildIdentityCard(statusColor),
          const SizedBox(height: 14),

          // 2. Attendance Performance Overview Card
          _buildAttendanceCard(periodRange, pct, statusColor),
          const SizedBox(height: 18),

          // 3. Chronological Daily Attendance Records
          _buildRecordsHeader(),
          const SizedBox(height: 10),
          _buildRecordsList(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Student Identity Hero Card
  // ---------------------------------------------------------------------------
  Widget _buildIdentityCard(Color statusColor) {
    final hasPhone = _stats.parentPhone != null && _stats.parentPhone!.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StudentAvatar(
                name: _student.fullName,
                photoUrl: _student.photoUrl,
                gender: _student.gender,
                radius: 28,
                badgeText: _student.rollNumber,
                badgeColor: AppColors.primaryDark,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _student.fullName,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _student.status == 'active'
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _student.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: _student.status == 'active'
                                  ? const Color(0xFF166534)
                                  : const Color(0xFF92400E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'S/O ${_student.fatherOrGuardianName}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.className} · Roll ${_student.rollNumber ?? "-"}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),

          // Key Info Grid
          Row(
            children: [
              _infoTile('Admission No', _student.admissionNumber),
              _infoTile('Admission Date', _student.admissionDate),
              _infoTile(
                'Parent Contact',
                hasPhone ? _stats.parentPhone! : 'No Mobile',
                isHighlight: !hasPhone,
              ),
            ],
          ),
          if (_student.studentCnic != null && _student.studentCnic!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _infoTile('B-Form / CNIC', _student.studentCnic!),
                if (_student.dateOfBirth != null && _student.dateOfBirth!.isNotEmpty)
                  _infoTile('Date of Birth', _student.dateOfBirth!)
                else
                  const Spacer(flex: 2),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoTile(String label, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isHighlight ? const Color(0xFFDC2626) : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Attendance Performance Overview Card
  // ---------------------------------------------------------------------------
  Widget _buildAttendanceCard(String periodRange, double pct, Color statusColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period & Progress Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Period Attendance',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    periodRange,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${pct.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (pct / 100.0).clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),

          // 4 Metric Counters
          Row(
            children: [
              _metricCounter(
                label: 'Present',
                value: '${_stats.presentDays}',
                color: const Color(0xFF16A34A),
                bgColor: const Color(0xFFDCFCE7),
              ),
              const SizedBox(width: 8),
              _metricCounter(
                label: 'Absent',
                value: '${_stats.absentDays}',
                color: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEE2E2),
                alert: _stats.absentDays > 0,
              ),
              const SizedBox(width: 8),
              _metricCounter(
                label: 'Late',
                value: '${_stats.lateDays}',
                color: const Color(0xFFD97706),
                bgColor: const Color(0xFFFEF3C7),
              ),
              const SizedBox(width: 8),
              _metricCounter(
                label: 'Leaves',
                value: '${_stats.leaveDays}',
                color: const Color(0xFF0284C7),
                bgColor: const Color(0xFFE0F2FE),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCounter({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    bool alert = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: alert ? color.withValues(alpha: 0.4) : Colors.transparent,
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Chronological Attendance History Header & List
  // ---------------------------------------------------------------------------
  Widget _buildRecordsHeader() {
    return Row(
      children: [
        const Text(
          'Daily Records',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _filterPill('all', 'All (${_stats.chronologicalRecords.length})'),
        const SizedBox(width: 4),
        if (_stats.absentDays > 0) ...[
          _filterPill('absent', 'Absent (${_stats.absentDays})', const Color(0xFFDC2626)),
          const SizedBox(width: 4),
        ],
        if (_stats.lateDays > 0) ...[
          _filterPill('late', 'Late (${_stats.lateDays})', const Color(0xFFD97706)),
          const SizedBox(width: 4),
        ],
        if (_stats.leaveDays > 0)
          _filterPill('leave', 'Leaves (${_stats.leaveDays})', const Color(0xFF0284C7)),
      ],
    );
  }

  Widget _filterPill(String key, String label, [Color? color]) {
    final isSelected = _historyFilter == key;
    final activeColor = color ?? AppColors.primaryDark;

    return GestureDetector(
      onTap: () => setState(() => _historyFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    final records = _filteredHistory;

    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          'No attendance records found for this filter.',
          style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
        ),
      );
    }

    return Column(
      children: records.map((rec) {
        final dayMark = KpkDayMark.fromRecord(rec);
        final statusLabel = switch (rec.status) {
          'present' => 'Present',
          'absent' => 'Absent',
          'late' => 'Late (${rec.arrivalTime ?? "Marked"})',
          'approved_leave' => 'Leave',
          'half_day' => 'Half Day',
          _ => rec.status.toUpperCase(),
        };

        final (statusColor, statusBg) = switch (rec.status) {
          'present' => (const Color(0xFF16A34A), const Color(0xFFDCFCE7)),
          'absent' => (const Color(0xFFDC2626), const Color(0xFFFEE2E2)),
          'late' => (const Color(0xFFD97706), const Color(0xFFFEF3C7)),
          'approved_leave' => (const Color(0xFF0284C7), const Color(0xFFE0F2FE)),
          'half_day' => (const Color(0xFF7C3AED), const Color(0xFFF3E8FF)),
          _ => (AppColors.textSecondary, const Color(0xFFF1F5F9)),
        };

        String formattedDate = rec.date;
        try {
          final dt = DateTime.parse(rec.date);
          formattedDate = DateFormat('EEE, dd MMM yyyy').format(dt);
        } catch (_) {}

        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: rec.status == 'absent'
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 14,
                color: rec.status == 'absent' ? const Color(0xFFDC2626) : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (rec.remarks != null && rec.remarks!.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        rec.remarks!,
                        style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                      ),
                    ],
                  ],
                ),
              ),
              // Session Units Indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  '1st: ${dayMark.firstTime} · 2nd: ${dayMark.secondTime}',
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Sticky Bottom WhatsApp Action Bar
  // ---------------------------------------------------------------------------
  Widget _buildStickyWhatsAppBar() {
    final recommendedType = _stats.consecutiveAbsentDays >= 3 || _stats.attendancePercentage < 75.0
        ? 'chronic'
        : (_stats.absentDays > 0 ? 'absent' : (_stats.lateDays > 0 ? 'late' : 'absent'));

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text(
                    'WhatsApp Parent Alert',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                  onPressed: () => _openWhatsApp(recommendedType),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
