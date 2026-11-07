import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/kpk_register_helper.dart';
import '../../../core/utils/whatsapp_helper.dart';
import '../../../core/widgets/class_picker_sheet.dart';
import '../../../core/widgets/student_avatar.dart';
import '../attendance_controller.dart';

import '../../admin/admin_controller.dart';
import '../../auth/auth_controller.dart';
import '../../qr_scanner/views/qr_scanner_view.dart';
import '../../students/views/whatsapp_parent_alert_view.dart';
import '../../sync/sync_controller.dart';
import '../../../data/repositories/student_repository.dart';

/// Clean, uncluttered KPK Primary School Daily Attendance Register:
/// - Streamlined Top Header: Class Selector + Date Stepper + Search/Insights icons,
///   1st Time / 2nd Time Session Switcher, and Quick Status Filter Pills.
/// - Spacious Student Roll-Call Rows: Roll No, Student Name (with Father Name),
///   and comfortable P / A / L / Lt tap buttons.
/// - Tapping any student opens the detailed Bottom Sheet (WhatsApp Parent Alert,
///   both sessions, arrival/departure time, and remarks).
class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> {
  String _filter = 'all';
  bool _showSearch = false;
  final TextEditingController _searchCtrl = TextEditingController();

  AttendanceController get _ctrl => Get.find<AttendanceController>();

  @override
  void initState() {
    super.initState();
    // Industry-standard write-through & background sync:
    // UI immediately renders local SQLite records in 0ms (no loading screens or delay).
    // In parallel, silently pulls fresh changes from Cloudflare D1 and updates reactive GetX stream.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ctrl.classesList.isEmpty) {
        _ctrl.loadClasses();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchCtrl.clear();
        _ctrl.searchQuery.value = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'attendance_register'.tr,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          _buildLiveSyncBadge(context),
          IconButton(
            tooltip: _showSearch ? 'Close Search' : 'Search Students',
            icon: Icon(_showSearch ? Icons.search_off_rounded : Icons.search_rounded, color: Colors.white),
            onPressed: _toggleSearch,
          ),
          IconButton(
            tooltip: 'Mark All Present',
            icon: const Icon(Icons.done_all_rounded, color: Colors.white),
            onPressed: () => _confirmMarkAll(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildUnifiedHeader(context),
          _buildBanner(),
          Expanded(child: _buildStudentList(context)),
        ],
      ),
      bottomNavigationBar: _buildStickyActionBar(context),
    );
  }

  Widget _buildLiveSyncBadge(BuildContext context) {
    if (!Get.isRegistered<SyncController>()) return const SizedBox.shrink();
    final syncCtrl = Get.find<SyncController>();

    return Obx(() {
      final isSyncing = syncCtrl.isSyncing.value;
      final pending = syncCtrl.pendingCount.value;
      final isOnline = syncCtrl.isOnlineNetwork.value;

      Color badgeBg;
      Color textColor;
      IconData icon;
      String label;

      if (isSyncing) {
        badgeBg = Colors.white.withValues(alpha: 0.18);
        textColor = const Color(0xFFBAE6FD);
        icon = Icons.sync_rounded;
        label = 'Syncing...';
      } else if (pending > 0 || !isOnline) {
        badgeBg = const Color(0xFFFEF3C7).withValues(alpha: 0.22);
        textColor = const Color(0xFFFDE68A);
        icon = Icons.cloud_queue_rounded;
        label = pending > 0 ? '$pending offline' : 'Offline';
      } else {
        badgeBg = Colors.white.withValues(alpha: 0.14);
        textColor = const Color(0xFFA7F3D0);
        icon = Icons.cloud_done_rounded;
        label = 'Synced';
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            if (pending > 0) {
              Get.snackbar(
                'Offline-Safe Storage (محفوظ)',
                '$pending change(s) safely saved in your phone\'s SQLite database. They will sync automatically as soon as internet connection is available.',
                snackPosition: SnackPosition.TOP,
                backgroundColor: const Color(0xFF1E293B),
                colorText: Colors.white,
                duration: const Duration(seconds: 4),
                mainButton: TextButton(
                  onPressed: () => syncCtrl.syncNow(),
                  child: const Text('Sync Now', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                ),
              );
            } else {
              syncCtrl.syncNow();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: textColor.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSyncing) ...[
                  SizedBox(
                    width: 11,
                    height: 11,
                    child: CircularProgressIndicator(strokeWidth: 2, color: textColor),
                  ),
                ] else ...[
                  Icon(icon, size: 13, color: textColor),
                ],
                const SizedBox(width: 4.5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // ===========================================================================
  // Streamlined Header: Class + Date + Actions → 1st/2nd Time → Filter Pills
  // ===========================================================================
  Widget _buildUnifiedHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Column(
        children: [
          // Row 1: Responsive Class selector + Date stepper
          Row(
            children: [
              Expanded(
                flex: 6,
                child: _classSelectorChip(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: _dateChip(context),
              ),
            ],
          ),

          // Collapsible Search Input (only shown when Search icon is tapped in AppBar)
          if (_showSearch) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (val) => _ctrl.searchQuery.value = val,
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search by roll no, student or father name...',
                  hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                  suffixIcon: Obx(() => _ctrl.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _searchCtrl.clear();
                            _ctrl.searchQuery.value = '';
                          },
                        )
                      : const SizedBox.shrink()),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  filled: true,
                  fillColor: AppColors.bgLight,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.3),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Row 2: Two-Time Session Switcher (Full Width - Zero Overflow)
          Obx(() {
            final activeSlot = _ctrl.selectedTimeSlot.value;
            final s1Count = _ctrl.firstTimePresentCount;
            final s2Count = _ctrl.secondTimePresentCount;
            final total = _ctrl.totalEnrolled;

            return Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  _timeSlotTab(
                    slot: 1,
                    isSelected: activeSlot == 1,
                    icon: Icons.wb_sunny_outlined,
                    title: '1st Time',
                    countText: '$s1Count/$total',
                  ),
                  const SizedBox(width: 4),
                  _timeSlotTab(
                    slot: 2,
                    isSelected: activeSlot == 2,
                    icon: Icons.wb_twilight_rounded,
                    title: '2nd Time',
                    countText: '$s2Count/$total',
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 8),

          // Row 3: Quick Status Filter Pills
          Obx(() => Row(
                children: [
                  _filterPill('all', 'All', _ctrl.totalEnrolled, AppColors.primaryDark),
                  const SizedBox(width: 5),
                  _filterPill('present', 'P', _ctrl.presentCount + _ctrl.lateCount, AppColors.present),
                  const SizedBox(width: 5),
                  _filterPill('absent', 'A', _ctrl.absentCount, AppColors.absent),
                  const SizedBox(width: 5),
                  _filterPill('leave', 'L', _ctrl.leaveCount + _ctrl.halfDayCount, AppColors.leave),
                  const SizedBox(width: 5),
                  _filterPill('late', 'Lt', _ctrl.lateCount, AppColors.late),
                  const SizedBox(width: 5),
                  _filterPill('unmarked', 'Pend', _ctrl.unmarkedCount, AppColors.unmarked),
                ],
              )),
        ],
      ),
    );
  }

  Widget _timeSlotTab({
    required int slot,
    required bool isSelected,
    required IconData icon,
    required String title,
    required String countText,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _ctrl.selectedTimeSlot.value = slot,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.18),
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
                size: 15,
                color: isSelected ? Colors.white : AppColors.primaryDark,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.16)
                      : AppColors.border.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  countText,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? const Color(0xFFA7F3D0) : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _classSelectorChip(BuildContext context) {
    return Obx(() {
      final selectedCls = _ctrl.selectedClass.value;
      final cls = selectedCls?.name ?? 'Select class';
      final sec = _ctrl.selectedSection.value?.name;

      return InkWell(
        onTap: () => showClassPickerSheet(context, _ctrl),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.bgLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  selectedCls?.numericLevel == 0
                      ? 'K'
                      : '${selectedCls?.numericLevel ?? 1}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  sec == null ? cls : '$cls · $sec',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 17, color: AppColors.textSecondary),
            ],
          ),
        ),
      );
    });
  }

  Widget _dateChip(BuildContext context) {
    return Obx(() {
      final selected = _ctrl.selectedDate.value;
      final isToday = DateUtils.isSameDay(selected, DateTime.now());

      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: isToday ? AppColors.bgLight : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isToday ? AppColors.border : AppColors.primary.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dateArrow(
              Icons.chevron_left_rounded,
              () => _ctrl.selectDate(DateTime(selected.year, selected.month, selected.day - 1)),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selected,
                    firstDate: DateTime(2025),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) _ctrl.selectDate(picked);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 12, color: AppColors.primaryDark),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _ctrl.shortFormattedDate,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!isToday)
              Tooltip(
                message: 'Jump to Today',
                child: InkWell(
                  onTap: () => _ctrl.selectDate(DateTime.now()),
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    margin: const EdgeInsets.only(right: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'T',
                      style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                    ),
                  ),
                ),
              ),
            _dateArrow(
              Icons.chevron_right_rounded,
              () => _ctrl.selectDate(DateTime(selected.year, selected.month, selected.day + 1)),
            ),
          ],
        ),
      );
    });
  }

  Widget _dateArrow(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        width: 20,
        height: 40,
        child: Icon(icon, size: 17, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _filterPill(String key, String label, int count, Color color) {
    final selected = _filter == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? color : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.25),
            ),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$label $count',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // Holiday / locked banner
  // ===========================================================================
  Widget _buildBanner() {
    return Obx(() {
      final holiday = _ctrl.activeHoliday.value;
      if (holiday != null || _ctrl.isSunday) {
        return _bannerStrip(
          icon: Icons.event_busy_rounded,
          color: const Color(0xFF6B21A8),
          bg: const Color(0xFFF3E8FF),
          text: holiday != null ? 'Holiday: ${holiday.description}' : 'Sunday — non-instructional day',
        );
      }
      if (!_ctrl.canTakeAttendanceForSelectedClass) {
        final assigned = _ctrl.teacherAssignedClass;
        return Container(
          width: double.infinity,
          color: const Color(0xFFEFF6FF),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF1D4ED8)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Read-Only Mode · Form Master: ${_ctrl.currentClassFormMaster}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF1E40AF)),
                ),
              ),
              if (assigned != null && assigned.id != _ctrl.selectedClass.value?.id) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _ctrl.selectClass(assigned),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_forward_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'My Class',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }
      if (_ctrl.isSessionFinalized) {
        return _bannerStrip(
          icon: Icons.lock_rounded,
          color: const Color(0xFF166534),
          bg: const Color(0xFFDCFCE7),
          text: 'register_locked_msg'.tr,
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _bannerStrip({required IconData icon, required Color color, required Color bg, required String text}) {
    return Container(
      width: double.infinity,
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Student list
  // ===========================================================================
  Widget _buildStudentList(BuildContext context) {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_ctrl.studentsList.isEmpty) {
        return _emptyState(Icons.people_outline_rounded, 'No students enrolled in this class');
      }

      final students = _applyFilter(_ctrl.filteredStudents);
      if (students.isEmpty) {
        return _emptyState(Icons.filter_alt_off_outlined, 'No students match this filter');
      }

      return RefreshIndicator(
        color: AppColors.primaryDark,
        onRefresh: () async {
          if (Get.isRegistered<SyncController>()) {
            await Get.find<SyncController>().syncNow(silent: true);
          }
          await _ctrl.loadStudentsAndAttendance();
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          itemCount: students.length,
          separatorBuilder: (_, _) => const SizedBox(height: 5),
          itemBuilder: (ctx, i) => _StudentRow(
            student: students[i],
            onOpenDetails: (s, r) => _showStudentSheet(context, s, r),
          ),
        ),
      );
    });
  }

  List<Student> _applyFilter(List<Student> students) {
    if (_filter == 'all') return students;
    return students.where((s) {
      final status = _ctrl.attendanceMap[s.id]?.status;
      switch (_filter) {
        case 'unmarked':
          return status == null;
        case 'present':
          return status == 'present' || status == 'late';
        case 'leave':
          return status == 'approved_leave' || status == 'half_day';
        default:
          return status == _filter;
      }
    }).toList();
  }

  Widget _emptyState(IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ===========================================================================
  // Clean single-row sticky bottom action bar
  // ===========================================================================
  Widget _buildStickyActionBar(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, -3))],
        ),
        child: Obx(() {
          final total = _ctrl.totalEnrolled;
          final remaining = _ctrl.unmarkedCount;
          final marked = total - remaining;
          final finalized = _ctrl.isSessionFinalized;
          final canTake = _ctrl.canTakeAttendanceForSelectedClass;
          final activeSlot = _ctrl.selectedTimeSlot.value;
          final holiday = _ctrl.activeHoliday.value;

          if (_ctrl.isNonInstructionalDay) {
            return _buildHolidayBar(holiday);
          }

          if (!canTake) {
            return _buildReadOnlyBar(context);
          }

          if (finalized) {
            return _buildLockedBar(context);
          }

          return _buildActiveBar(context, total, marked, remaining, activeSlot);
        }),
      ),
    );
  }

  Widget _buildHolidayBar(dynamic holiday) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.event_busy_rounded, size: 20, color: Color(0xFF7C3AED)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Non-Instructional Day', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF6B21A8))),
                Text(
                  holiday != null ? holiday.description : 'Sunday — Weekly Off',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF7C3AED)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () {
              final selected = _ctrl.selectedDate.value;
              _ctrl.selectDate(DateTime(selected.year, selected.month, selected.day + 1));
            },
            icon: const Icon(Icons.skip_next_rounded, size: 16),
            label: const Text('Next Day', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyBar(BuildContext context) {
    final assigned = _ctrl.teacherAssignedClass;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.shield_outlined, size: 20, color: Color(0xFF1D4ED8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Read-Only Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1D4ED8))),
                Text(
                  'Form Master: ${_ctrl.currentClassFormMaster}',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF3B82F6)),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (assigned != null && assigned.id != _ctrl.selectedClass.value?.id) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _ctrl.selectClass(assigned),
              child: const Text('My Class', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLockedBar(BuildContext context) {
    final isAdmin = Get.find<AuthController>().currentUser.value?.isAdmin ?? false;
    final absentStudents = _ctrl.studentsList
        .where((s) => _ctrl.attendanceMap[s.id]?.status == 'absent')
        .toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.lock_rounded, size: 20, color: Color(0xFF16A34A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Register Locked & Synced', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF166534))),
                Text(
                  absentStudents.isNotEmpty
                      ? '${absentStudents.length} absent student(s) recorded today'
                      : 'All students present / accounted for',
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF16A34A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (absentStudents.isNotEmpty) ...[
            const SizedBox(width: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showBatchWhatsAppAlertsSheet(context, absentStudents),
              icon: const Icon(Icons.chat_rounded, size: 15),
              label: Text(
                'Alert (${absentStudents.length})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
              ),
            ),
          ],
          if (isAdmin) ...[
            const SizedBox(width: 6),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF991B1B),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _confirmReopenRegister(context),
              child: const Text('Reopen', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }

  void _showBatchWhatsAppAlertsSheet(BuildContext context, List<Student> absentStudents) {
    final className = _ctrl.selectedClass.value?.name ?? 'Class';
    final schoolName = Get.isRegistered<AdminController>()
        ? (Get.find<AdminController>().school.value?.name ?? 'Govt Primary School KPK')
        : 'Govt Primary School KPK';
    final dateStr = _ctrl.shortFormattedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chat_rounded, color: Color(0xFF16A34A), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Absentee Parent Alerts ($className)',
                          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          '$dateStr • ${absentStudents.length} absent student(s)',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: absentStudents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, idx) {
                    final st = absentStudents[idx];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          StudentAvatar(
                            name: st.fullName,
                            photoUrl: st.photoUrl,
                            gender: st.gender,
                            radius: 19,
                            badgeText: st.rollNumber,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  st.fullName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                                Text(
                                  'S/D of ${st.fatherOrGuardianName} • Adm: ${st.admissionNumber}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 14),
                            label: const Text('WhatsApp', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                            onPressed: () async {
                              final repo = Get.find<StudentRepository>();
                              final contact = await repo.getParentContact(st.id);
                              final phone = contact?.phoneNumber ?? '';
                              if (phone.trim().length >= 10) {
                                final tpl = await WhatsAppHelper.getTemplate('absent');
                                final msg = WhatsAppHelper.renderTemplate(
                                  tpl,
                                  student: st,
                                  className: className,
                                  schoolName: schoolName,
                                  dateStr: dateStr,
                                );
                                await WhatsAppHelper.launchWhatsApp(phone: phone, message: msg);
                              } else {
                                Get.to(() => WhatsAppParentAlertView(
                                      student: st,
                                      className: className,
                                      schoolName: schoolName,
                                      initialType: 'absent',
                                      dateStr: dateStr,
                                    ));
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveBar(BuildContext context, int total, int marked, int remaining, int activeSlot) {
    final progress = total > 0 ? (marked / total).clamp(0.0, 1.0) : 0.0;
    final allMarked = remaining == 0 && total > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Completion & Attendance Status Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    allMarked ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                    size: 15,
                    color: allMarked ? AppColors.present : AppColors.primaryDark,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    allMarked
                        ? 'All $total Students Marked'
                        : '$marked of $total Marked',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: allMarked ? AppColors.present : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: allMarked ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  allMarked ? 'Ready to Lock ✓' : '${((total > 0 ? marked / total : 0) * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: allMarked ? const Color(0xFF166534) : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                allMarked ? AppColors.present : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Action Buttons: QR Scan (Left) + Lock Register (Right)
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 21, color: AppColors.primaryDark),
                  tooltip: 'Scan Student QR Badges',
                  onPressed: () => Get.to(() => const QrScannerView()),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: allMarked
                          ? AppColors.primaryDark
                          : const Color(0xFF475569),
                      foregroundColor: Colors.white,
                      elevation: allMarked ? 2 : 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    onPressed: total == 0
                        ? null
                        : allMarked
                            ? () => _ctrl.finalizeAndSyncCurrentSession()
                            : () => _showUnmarkedWarningDialog(context, remaining),
                    icon: Icon(
                      allMarked ? Icons.lock_rounded : Icons.lock_outline_rounded,
                      size: 17,
                    ),
                    label: Text(
                      allMarked
                          ? 'Finalize & Lock Register'
                          : 'Lock Register',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showUnmarkedWarningDialog(BuildContext context, int remaining) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFD97706)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Unmarked Students',
                style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: Text(
          'There are $remaining student(s) not yet marked for this session. '
          'To ensure audit compliance in KPK Primary School records, all students must be marked before locking.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _filter = 'unmarked');
            },
            child: const Text('Filter & Review Unmarked'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.present,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _confirmMarkAll(context);
            },
            child: const Text('Mark Remaining Present'),
          ),
        ],
      ),
    );
  }

  void _confirmReopenRegister(BuildContext context) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_open_rounded, size: 20, color: Color(0xFFB45309)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text('reopen_register'.tr, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This attendance register for ${_ctrl.selectedClass.value?.name ?? 'this class'} is finalized. '
              'Reopening allows edits to student status. Tap below to confirm.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Reason for Reopening (Audit Trail)',
                hintText: 'e.g. Roll call correction',
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _ctrl.reopenCurrentSession(reason: reasonCtrl.text.trim());
            },
            icon: const Icon(Icons.lock_open_rounded, size: 16),
            label: Text('reopen_register'.tr),
          ),
        ],
      ),
    );
  }

  void _confirmMarkAll(BuildContext context) {
    final activeSlot = _ctrl.selectedTimeSlot.value;
    final slotLabel = activeSlot == 1 ? '1st Time (Morning)' : '2nd Time (After Break)';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Mark $slotLabel?', style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
        content: Text(
          activeSlot == 1
              ? 'All ${_ctrl.totalEnrolled} students in ${_ctrl.selectedClass.value?.name ?? 'this class'} '
                  'will be marked Present for 1st Time on ${_ctrl.formattedDate}.'
              : 'All present/unmarked students in ${_ctrl.selectedClass.value?.name ?? 'this class'} '
                  'will be marked Present for 2nd Time on ${_ctrl.formattedDate}.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _ctrl.markAllPresent(slot: activeSlot);
            },
            child: Text(activeSlot == 1 ? 'Mark 1st Time' : 'Mark 2nd Time'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // Clean Student Information Sheet (Essential Read-Only Info + WhatsApp Page)
  // ===========================================================================
  void _showStudentSheet(BuildContext context, Student student, AttendanceRecord? record) {
    final mark = KpkDayMark.fromRecord(record);
    final s1 = mark.firstTime;
    final s2 = mark.secondTime;
    final isLate = mark.isLate;
    final s1Label = s1 == 'P' ? 'Present' : (s1 == 'A' ? 'Absent' : (s1 == 'L' ? 'Leave' : 'Unmarked'));
    final s2Label = s2 == 'P' ? 'Present' : (s2 == 'A' ? 'Absent' : (s2 == 'L' ? 'Leave' : 'Pending'));
    final className = _ctrl.selectedClass.value?.name ?? 'Class';
    final schoolName = Get.isRegistered<AdminController>()
        ? (Get.find<AdminController>().school.value?.name ?? 'Govt Primary School KPK')
        : 'Govt Primary School KPK';

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Identity Header
              Row(
                children: [
                  StudentAvatar(
                    name: student.fullName,
                    photoUrl: student.photoUrl,
                    gender: student.gender,
                    radius: 24,
                    badgeText: student.rollNumber ?? '-',
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Roll ${student.rollNumber ?? "-"} • $className',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Essential Student & Today Status Information Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.bgLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _infoRow('Father / Guardian', student.fatherOrGuardianName),
                    const Divider(height: 12, color: AppColors.border),
                    _infoRow('Admission No.', student.admissionNumber),
                    const Divider(height: 12, color: AppColors.border),
                    _infoRow('1st Time (Morning)', isLate && s1 == 'P' ? 'Present (Late)' : s1Label),
                    const Divider(height: 12, color: AppColors.border),
                    _infoRow('2nd Time (After Break)', s2Label),
                    if (record?.arrivalTime != null && record!.arrivalTime!.isNotEmpty) ...[
                      const Divider(height: 12, color: AppColors.border),
                      _infoRow('Recorded Arrival', record.arrivalTime!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dedicated Bottom WhatsApp Page Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF16A34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final initialType = (s1 == 'A' || s2 == 'A')
                        ? 'absent'
                        : (isLate ? 'late' : 'absent');
                    Navigator.pop(ctx);
                    Get.to(
                      () => WhatsAppParentAlertView(
                        student: student,
                        className: className,
                        schoolName: schoolName,
                        initialType: initialType,
                        dateStr: _ctrl.formattedDate,
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text(
                    'WhatsApp Parent Alert',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Clean, Uncluttered Student Roll-Call Row:
// Shows Roll No + Student Name + Father Name + Spacious P / A / L / Lt Buttons.
// Tapping the student opens the bottom sheet for full details & WhatsApp.
// =============================================================================
class _StatusOption {
  final String key;
  final String short;
  final String label;
  final Color color;
  const _StatusOption(this.key, this.short, this.label, this.color);
}

const _statusOptions = [
  _StatusOption('present', 'P', 'Present', AppColors.present),
  _StatusOption('absent', 'A', 'Absent', AppColors.absent),
  _StatusOption('late', 'Lt', 'Late', AppColors.late),
  _StatusOption('approved_leave', 'L', 'Leave', AppColors.leave),
  _StatusOption('half_day', 'HD', 'Half-day', AppColors.halfDay),
];

Color _statusColor(String? status) {
  for (final o in _statusOptions) {
    if (o.key == status) return o.color;
  }
  return AppColors.unmarked;
}

class _StudentRow extends StatelessWidget {
  final Student student;
  final void Function(Student, AttendanceRecord?) onOpenDetails;

  const _StudentRow({required this.student, required this.onOpenDetails});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AttendanceController>();

    return Obx(() {
      final record = ctrl.attendanceMap[student.id];
      final status = record?.status;
      final color = _statusColor(status);
      final dayMark = KpkDayMark.fromRecord(record);
      final activeSlot = ctrl.selectedTimeSlot.value;
      final activeSlotVal = activeSlot == 1 ? dayMark.firstTime : dayMark.secondTime;
      final isLocked = ctrl.isSessionFinalized;
      final canTake = ctrl.canTakeAttendanceForSelectedClass && !ctrl.isNonInstructionalDay;

      return Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          borderRadius: BorderRadius.circular(11),
          onTap: () => onOpenDetails(student, record),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: status != null ? color.withValues(alpha: 0.35) : AppColors.border,
              ),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left status color indicator strip
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: status != null ? color : Colors.transparent,
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Student Avatar with Photo/Initial & Roll number badge
                  StudentAvatar(
                    name: student.fullName,
                    photoUrl: student.photoUrl,
                    gender: student.gender,
                    radius: 17,
                    badgeText: student.rollNumber ?? '-',
                    badgeColor: status != null ? color : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),

                  // Student Name + Father Name + 1st/2nd Time Session Indicator
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 1.5),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'S/O ${student.fatherOrGuardianName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Tactile Slot Buttons: `P`, `A`, `L`, and `Lt`
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _slotActionBtn(
                          label: 'P',
                          selected: activeSlotVal == 'P',
                          color: AppColors.present,
                          canTake: canTake,
                          isLocked: isLocked,
                          onTap: () => ctrl.markTimeSlot(student: student, slotMark: 'P'),
                        ),
                        const SizedBox(width: 4),
                        _slotActionBtn(
                          label: 'A',
                          selected: activeSlotVal == 'A',
                          color: AppColors.absent,
                          canTake: canTake,
                          isLocked: isLocked,
                          onTap: () => ctrl.markTimeSlot(student: student, slotMark: 'A'),
                        ),
                        const SizedBox(width: 4),
                        _slotActionBtn(
                          label: 'L',
                          selected: activeSlotVal == 'L',
                          color: AppColors.leave,
                          canTake: canTake,
                          isLocked: isLocked,
                          onTap: () => ctrl.markTimeSlot(student: student, slotMark: 'L'),
                        ),
                        const SizedBox(width: 4),
                        _slotActionBtn(
                          label: 'Lt',
                          selected: dayMark.isLate,
                          color: AppColors.late,
                          canTake: canTake,
                          isLocked: isLocked,
                          onTap: () => ctrl.toggleLate(student),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _slotActionBtn({
    required String label,
    required bool selected,
    required Color color,
    required bool canTake,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (!canTake) {
          final fm = Get.find<AttendanceController>().currentClassFormMaster;
          Get.snackbar(
            'Read-Only Mode',
            'Only the assigned Form Master ($fm) or Head Teacher can record attendance for this class.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
        if (isLocked) {
          Get.snackbar(
            'Register Locked',
            'register_locked_msg'.tr,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF1E293B),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          return;
        }
        onTap();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: (canTake && !isLocked) ? 1.0 : (selected ? 0.9 : 0.35),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 35,
          height: 35,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? color : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? color : const Color(0xFFCBD5E1),
              width: selected ? 1.5 : 1.0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              color: selected ? Colors.white : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}
