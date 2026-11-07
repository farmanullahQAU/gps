import 'package:intl/intl.dart';
import '../database/app_database.dart';

/// Represents the authentic KPK Primary School Daily Attendance Register (`رجسٹر حاضری روزانہ`)
/// two-time daily mark for a single student on a single instructional day:
/// - 1st Time (`اول وقت` - Morning Assembly): `'P'` (`/`), `'A'` (`A`), `'L'` (`L`), or `'_'` (unmarked)
/// - 2nd Time (`دوم وقت` - After Break): `'P'` (`/`), `'A'` (`A`), `'L'` (`L`), or `'_'` (unmarked)
/// - Late (`تاخیر`): Tracked as an additional flag (`isLate = true`) on a Present student,
///   because in KPK schools a late student is Present (`/` or `//`) in the attendance count.
class KpkDayMark {
  /// `'P'` = Present (`/`), `'A'` = Absent (`A`), `'L'` = Leave (`L`), `'_'` = Unmarked
  final String firstTime;

  /// `'P'` = Present (`/`), `'A'` = Absent (`A`), `'L'` = Leave (`L`), `'_'` = Unmarked
  final String secondTime;

  /// True when the student arrived late (still Present `/` or `//` for attendance count)
  final bool isLate;

  /// Optional human-readable departure time (e.g. `'11:30:00'`)
  final String? customDepartureTime;

  const KpkDayMark({
    required this.firstTime,
    required this.secondTime,
    this.isLate = false,
    this.customDepartureTime,
  });

  /// Unmarked day state
  static const KpkDayMark unmarked = KpkDayMark(
    firstTime: '_',
    secondTime: '_',
    isLate: false,
  );

  /// Parses a [KpkDayMark] from an existing [AttendanceRecord].
  /// Fully backward-compatible with records that do not have an `S1:...|S2:...` tag.
  factory KpkDayMark.fromRecord(AttendanceRecord? record) {
    if (record == null) return unmarked;

    final isLate = record.status == 'late';
    final dep = record.departureTime ?? '';

    if (dep.startsWith('S1:')) {
      // Format: S1:P|S2:P or S1:P|S2:A@11:30:00
      String slotsPart = dep;
      String? customDep;
      final atIdx = dep.indexOf('@');
      if (atIdx != -1) {
        slotsPart = dep.substring(0, atIdx);
        customDep = dep.substring(atIdx + 1).trim();
        if (customDep.isEmpty) customDep = null;
      }

      String s1 = '_';
      String s2 = '_';
      for (final part in slotsPart.split('|')) {
        if (part.startsWith('S1:') && part.length >= 4) {
          s1 = part.substring(3, 4);
        } else if (part.startsWith('S2:') && part.length >= 4) {
          s2 = part.substring(3, 4);
        }
      }
      return KpkDayMark(
        firstTime: s1,
        secondTime: s2,
        isLate: isLate,
        customDepartureTime: customDep,
      );
    }

    // Backward-compatible mapping from standard status
    switch (record.status) {
      case 'present':
      case 'late':
        return KpkDayMark(
          firstTime: 'P',
          secondTime: 'P',
          isLate: isLate,
          customDepartureTime: dep.isEmpty ? null : dep,
        );
      case 'half_day':
        return KpkDayMark(
          firstTime: 'P',
          secondTime: 'A',
          isLate: false,
          customDepartureTime: dep.isEmpty ? null : dep,
        );
      case 'approved_leave':
        return KpkDayMark(
          firstTime: 'L',
          secondTime: 'L',
          isLate: false,
          customDepartureTime: dep.isEmpty ? null : dep,
        );
      case 'absent':
        return KpkDayMark(
          firstTime: 'A',
          secondTime: 'A',
          isLate: false,
          customDepartureTime: dep.isEmpty ? null : dep,
        );
      default:
        return unmarked;
    }
  }

  /// Encodes the two-time state into the `departureTime` column string.
  String encodeDepartureTime() {
    final base = 'S1:$firstTime|S2:$secondTime';
    if (customDepartureTime != null && customDepartureTime!.trim().isNotEmpty) {
      return '$base@${customDepartureTime!.trim()}';
    }
    return base;
  }

  /// Maps the two-time mark to the canonical database `status`
  /// (`'present'`, `'absent'`, `'late'`, `'approved_leave'`, `'half_day'`)
  /// so SQLite and Cloudflare D1 constraints remain 100% satisfied.
  String toDbStatus() {
    if (isLate) return 'late';

    // Explicit half-day only when one session is Present and the other is explicitly Absent or Leave
    if ((firstTime == 'P' && (secondTime == 'A' || secondTime == 'L')) ||
        ((firstTime == 'A' || firstTime == 'L') && secondTime == 'P')) {
      return 'half_day';
    }

    // Present in 1st time (with 2nd time pending '_') or Present in both sessions ('P','P')
    if (firstTime == 'P' || secondTime == 'P') {
      return 'present';
    }

    if (firstTime == 'L' || secondTime == 'L') {
      return 'approved_leave';
    }

    if (firstTime == 'A' || secondTime == 'A') {
      return 'absent';
    }

    return 'present';
  }

  /// Number of KPK Register attendance units (`حاضریاں`) for this day:
  /// - `//` (both 1st and 2nd time present) = 2
  /// - `/` or `/A` or `/L` or `A/` (one time present) = 1
  /// - `AA` or `LL` or unmarked = 0
  int get attendanceUnits {
    int units = 0;
    if (firstTime == 'P') units++;
    if (secondTime == 'P') units++;
    return units;
  }

  /// Authentic KPK Register symbol for the daily cell:
  /// - `'//'` = Present both 1st & 2nd time
  /// - `'/'`  = Present 1st time (2nd time pending)
  /// - `'/A'` = Present 1st time, Absent 2nd time
  /// - `'/L'` = Present 1st time, Leave 2nd time
  /// - `'A/'` = Absent 1st time, Present 2nd time
  /// - `'L/'` = Leave 1st time, Present 2nd time
  /// - `'AA'` or `'A'` = Absent
  /// - `'LL'` or `'L'` = Leave
  /// - `'-'`  = Unmarked
  String get registerSymbol {
    if (firstTime == '_' && secondTime == '_') return '-';
    final s1 = _slotChar(firstTime);
    final s2 = _slotChar(secondTime);
    if (secondTime == '_') return s1;
    if (firstTime == '_') return '_$s2';
    return '$s1$s2';
  }

  static String _slotChar(String slot) {
    switch (slot) {
      case 'P':
        return '/';
      case 'A':
        return 'A';
      case 'L':
        return 'L';
      default:
        return '-';
    }
  }

  bool get isMarked => firstTime != '_' || secondTime != '_';
  bool get isFirstTimeMarked => firstTime != '_';
  bool get isSecondTimeMarked => secondTime != '_';

  KpkDayMark copyWith({
    String? firstTime,
    String? secondTime,
    bool? isLate,
    String? customDepartureTime,
  }) {
    return KpkDayMark(
      firstTime: firstTime ?? this.firstTime,
      secondTime: secondTime ?? this.secondTime,
      isLate: isLate ?? this.isLate,
      customDepartureTime: customDepartureTime ?? this.customDepartureTime,
    );
  }
}

/// Official KPK Primary School Monthly Register Summary (`گوشوارہ حاضری ماہانہ` — End-of-Month Summary)
/// Includes all 8 official register fields:
/// 1. Number of Students at the Beginning of the Month (`مہینے کے شروع میں طلباء کی تعداد`)
/// 2. Number of Students Admitted During the Current Month (`ماہ رواں میں داخل ہونے والے طلباء کی تعداد`)
/// 3. Number of Students Withdrawn During the Current Month (`ماہ رواں میں خارج ہونے والے طلباء کی تعداد`)
/// 4. Number of Students at the End of the Month (`مہینے کے آخر میں طلباء کی تعداد`)
/// 5. Total Madrasah Working Hours/Sessions During the Current Month (`ماہ رواں میں کل اوقات مدرسہ کی تعداد`)
/// 6. Cumulative Madrasah Working Hours/Sessions from Beginning of Year to End of Month (`شروع سال سے مہینے کے آخر تک اوقات مدرسہ کی تعداد`)
/// 7. Average Daily Attendance (`اوسط حاضری روزانہ`) = Total Attendances ÷ Total School Sessions
/// 8. Attendance Percentage (`فیصد حاضری`) = (Average Daily Attendance ÷ Students at End of Month) × 100
class KpkMonthlySummary {
  final int totalCalendarDays; // 28, 29, 30, or 31 days in period/month
  final int sundaysCount; // Number of Sundays in period
  final int holidaysCount; // Number of Gazetted Holidays (on non-Sundays) in period
  final int workingDays; // Instructional working days = totalCalendarDays - sundaysCount - holidaysCount
  final int studentsAtStartOfMonth; // 1. مہینے کے شروع میں طلباء کی تعداد
  final int admittedDuringMonth; // 2. ماہ رواں میں داخل ہونے والے طلباء کی تعداد
  final int withdrawnDuringMonth; // 3. ماہ رواں میں خارج ہونے والے طلباء کی تعداد
  final int studentsAtEndOfMonth; // 4. مہینے کے آخر میں طلباء کی تعداد
  final int totalSchoolSessions; // 5. ماہ رواں میں کل اوقات مدرسہ کی تعداد
  final int cumulativeSessionsFromYearStart; // 6. شروع سال سے مہینے کے آخر تک اوقات مدرسہ کی تعداد
  final int totalAttendances; // کل حاضریاں ماہ حال
  final double averageAttendance; // 7. اوسط حاضری روزانہ
  final double percentageAttendance; // 8. فیصد حاضری

  /// Alias for [studentsAtEndOfMonth] for backward compatibility
  int get totalStudents => studentsAtEndOfMonth;

  /// Returns exact number of days in any calendar month (28, 29 in leap years, 30, or 31).
  static int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  /// Returns the exact last calendar day of any month (28th, 29th, 30th, or 31st).
  static DateTime lastDayOfMonth(int year, int month) => DateTime(year, month + 1, 0);

  const KpkMonthlySummary({
    required this.totalCalendarDays,
    required this.sundaysCount,
    required this.holidaysCount,
    required this.workingDays,
    required this.studentsAtStartOfMonth,
    required this.admittedDuringMonth,
    required this.withdrawnDuringMonth,
    required this.studentsAtEndOfMonth,
    required this.totalSchoolSessions,
    required this.cumulativeSessionsFromYearStart,
    required this.totalAttendances,
    required this.averageAttendance,
    required this.percentageAttendance,
  });

  /// Computes the official KPK Monthly Register (End-of-Month Summary) metrics for a given period.
  factory KpkMonthlySummary.compute({
    required List<Student> students,
    List<Student>? allSectionStudents,
    required List<AttendanceRecord> records,
    required Set<String> holidayDateKeys,
    required DateTime startDate,
    required DateTime endDate,
    DateTime? academicYearStart,
  }) {
    final periodStart = DateTime(startDate.year, startDate.month, startDate.day);
    final periodEnd = DateTime(endDate.year, endDate.month, endDate.day);
    final startStr = DateFormat('yyyy-MM-dd').format(periodStart);
    final endStr = DateFormat('yyyy-MM-dd').format(periodEnd);

    int totalCalendarDays = 0;
    int sundaysCount = 0;
    int holidaysCount = 0;
    int workingDays = 0;
    var cur = periodStart;
    final validDates = <String>{};
    while (!cur.isAfter(periodEnd)) {
      totalCalendarDays++;
      final dateKey = DateFormat('yyyy-MM-dd').format(cur);
      final isSunday = cur.weekday == DateTime.sunday;
      final isHoliday = holidayDateKeys.contains(dateKey);
      if (isSunday) {
        sundaysCount++;
      } else if (isHoliday) {
        holidaysCount++;
      } else {
        workingDays++;
        validDates.add(dateKey);
      }
      // DST-safe calendar day increment (handles 28, 29, 30, 31 month boundaries automatically)
      cur = DateTime(cur.year, cur.month, cur.day + 1);
    }

    // 5. Total Madrasah Working Hours/Sessions During the Current Month (Working Days × 2)
    final totalSchoolSessions = workingDays * 2;

    // 6. Cumulative Madrasah Working Hours/Sessions from Beginning of Academic Year to End of Month
    DateTime resolvedYearStart;
    if (academicYearStart != null) {
      final candidate = DateTime(
        academicYearStart.year,
        academicYearStart.month,
        academicYearStart.day,
      );
      // If periodEnd is before the stored academicYearStart (e.g. Jan/Feb/Mar 2026 before Apr 1, 2026),
      // use April 1 of the preceding year for that academic session.
      resolvedYearStart = candidate.isAfter(periodEnd)
          ? DateTime(periodEnd.month >= 4 ? periodEnd.year : periodEnd.year - 1, 4, 1)
          : candidate;
    } else {
      resolvedYearStart = periodEnd.month >= 4
          ? DateTime(periodEnd.year, 4, 1)
          : DateTime(periodEnd.year - 1, 4, 1);
    }
    final cumulativeStart = resolvedYearStart.isAfter(periodStart) ? periodStart : resolvedYearStart;
    int cumulativeWorkingDays = 0;
    var yCur = cumulativeStart;
    while (!yCur.isAfter(periodEnd)) {
      final dKey = DateFormat('yyyy-MM-dd').format(yCur);
      if (yCur.weekday != DateTime.sunday && !holidayDateKeys.contains(dKey)) {
        cumulativeWorkingDays++;
      }
      yCur = DateTime(yCur.year, yCur.month, yCur.day + 1);
    }
    final cumulativeSessionsFromYearStart = cumulativeWorkingDays * 2;

    // Student movement calculations (1, 2, 3, 4)
    final roster = allSectionStudents ?? students;
    final yearStartStr = DateFormat('yyyy-MM-dd').format(cumulativeStart);
    final startEpochMs = periodStart.millisecondsSinceEpoch;
    final endEpochMs = DateTime(
      periodEnd.year,
      periodEnd.month,
      periodEnd.day,
      23,
      59,
      59,
      999,
    ).millisecondsSinceEpoch;

    int admittedCount = 0;
    int withdrawnCount = 0;
    int endActiveCount = 0;

    for (final s in roster) {
      if (s.isDeleted) continue;

      final isActiveNow = s.status == 'active';
      final enrolledByPeriodEnd = s.admissionDate.compareTo(endStr) <= 0;
      if (isActiveNow && enrolledByPeriodEnd) {
        endActiveCount++;
      }

      // Admitted during current month (if admissionDate is within [startStr, endStr]
      // and after the academic session opening date, or if newly registered during the month)
      final admittedInPeriod =
          s.admissionDate.compareTo(startStr) >= 0 && s.admissionDate.compareTo(endStr) <= 0;
      final isInitialSessionBatch =
          (s.admissionDate == yearStartStr || s.admissionDate == '2025-04-01' || s.admissionDate == '2026-04-01') &&
              (startStr == yearStartStr || startStr == '2025-04-01' || startStr == '2026-04-01');
      if (admittedInPeriod && !isInitialSessionBatch) {
        admittedCount++;
      }

      // Withdrawn (transferred / graduated / inactive) during current month
      if (!isActiveNow) {
        final updatedInPeriod = s.updatedAt >= startEpochMs && s.updatedAt <= endEpochMs;
        if (updatedInPeriod || s.updatedAt == 0) {
          withdrawnCount++;
        }
      }
    }

    // Fallback if all active students have admissionDate after endStr (e.g. viewing past month)
    if (endActiveCount == 0 && students.isNotEmpty) {
      endActiveCount = students.where((s) => s.status == 'active').length;
    }

    // 1. Students at Beginning of Month = End - Admitted + Withdrawn
    final startStudentsCount =
        (endActiveCount - admittedCount + withdrawnCount).clamp(0, 99999);

    // Total attendances in current month
    final studentIds = {for (final s in roster) s.id};
    int totalAttendances = 0;
    for (final r in records) {
      if (studentIds.contains(r.studentId) && validDates.contains(r.date)) {
        final mark = KpkDayMark.fromRecord(r);
        totalAttendances += mark.attendanceUnits;
      }
    }

    // 7. Average Daily Attendance & 8. Attendance Percentage
    final double averageAttendance =
        totalSchoolSessions > 0 ? (totalAttendances / totalSchoolSessions) : 0.0;
    final double percentageAttendance = endActiveCount > 0
        ? ((averageAttendance / endActiveCount) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    return KpkMonthlySummary(
      totalCalendarDays: totalCalendarDays,
      sundaysCount: sundaysCount,
      holidaysCount: holidaysCount,
      workingDays: workingDays,
      studentsAtStartOfMonth: startStudentsCount,
      admittedDuringMonth: admittedCount,
      withdrawnDuringMonth: withdrawnCount,
      studentsAtEndOfMonth: endActiveCount,
      totalSchoolSessions: totalSchoolSessions,
      cumulativeSessionsFromYearStart: cumulativeSessionsFromYearStart,
      totalAttendances: totalAttendances,
      averageAttendance: averageAttendance,
      percentageAttendance: percentageAttendance,
    );
  }
}

/// Official KP E&SED (Elementary & Secondary Education Department Khyber Pakhtunkhwa)
/// & Malakand Division Gazetted Holidays and Zonal Vacation Schedules.
class KpkGazettedHolidays {
  /// Official 2026 Gazetted Public Holidays notified by the Federal Cabinet Division
  /// and Administration Department, Government of Khyber Pakhtunkhwa (KP E&SED).
  static const List<({String date, String description})> official2026Holidays = [
    (
      date: '2026-02-05',
      description: 'Kashmir Solidarity Day (یوم یکجہتی کشمیر)',
    ),
    (
      date: '2026-03-21',
      description: 'Eid-ul-Fitr — Day 1 (عید الفطر تعطیل اول)',
    ),
    (
      date: '2026-03-22',
      description: 'Eid-ul-Fitr — Day 2 (عید الفطر تعطیل دوم)',
    ),
    (
      date: '2026-03-23',
      description: 'Pakistan Day & Eid-ul-Fitr — Day 3 (یوم پاکستان / عید الفطر)',
    ),
    (
      date: '2026-05-01',
      description: 'Labour Day (یوم مزدور)',
    ),
    (
      date: '2026-05-27',
      description: 'Eid-ul-Azha — Day 1 (عید الاضحیٰ تعطیل اول)',
    ),
    (
      date: '2026-05-28',
      description: 'Youm-e-Takbeer & Eid-ul-Azha — Day 2 (یوم تکبیر / عید الاضحیٰ)',
    ),
    (
      date: '2026-05-29',
      description: 'Eid-ul-Azha — Day 3 (عید الاضحیٰ تعطیل سوم)',
    ),
    (
      date: '2026-06-17',
      description: '1st Muharram — Urs Hazrat Umar Farooq RA (یکم محرم الحرام - KPK Holiday)',
    ),
    (
      date: '2026-06-24',
      description: 'Ashura — 9th Muharram (9 محرم الحرام - عاشورہ)',
    ),
    (
      date: '2026-06-25',
      description: 'Ashura — 10th Muharram (10 محرم الحرام - عاشورہ)',
    ),
    (
      date: '2026-08-14',
      description: 'Independence Day of Pakistan (یوم آزادی پاکستان)',
    ),
    (
      date: '2026-08-26',
      description: 'Eid Milad-un-Nabi (SAW) — 12th Rabi-ul-Awwal (عید میلاد النبی ﷺ)',
    ),
    (
      date: '2026-11-09',
      description: 'Allama Iqbal Day (یوم اقبال)',
    ),
    (
      date: '2026-12-25',
      description: 'Quaid-e-Azam Day (یوم قائد اعظم)',
    ),
  ];

  /// Expands a vacation or multi-day closure range [start, end] into individual
  /// non-Sunday calendar dates (`yyyy-MM-dd`) using DST-safe calendar arithmetic.
  static List<({String date, String description})> expandDateRange({
    required DateTime start,
    required DateTime end,
    required String description,
  }) {
    final result = <({String date, String description})>[];
    var cur = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cur.isAfter(last)) {
      if (cur.weekday != DateTime.sunday) {
        result.add((
          date: DateFormat('yyyy-MM-dd').format(cur),
          description: description,
        ));
      }
      cur = DateTime(cur.year, cur.month, cur.day + 1);
    }
    return result;
  }
}

