import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'student_dao.g.dart';

@DriftAccessor(tables: [Students, ParentContacts, Classes, Sections, SchoolCalendarHolidays])
class StudentDao extends DatabaseAccessor<AppDatabase> with _$StudentDaoMixin {
  StudentDao(super.db);

  // List active students for a given class and section
  Future<List<Student>> getStudentsForSection({
    required String classId,
    required String sectionId,
    String? schoolId,
    bool includeInactive = false,
  }) {
    var q = select(students)
      ..where((t) =>
          t.classId.equals(classId) &
          t.sectionId.equals(sectionId) &
          t.isDeleted.equals(false));

    if (schoolId != null) {
      q = q..where((t) => t.schoolId.equals(schoolId));
    }

    if (!includeInactive) {
      q = q..where((t) => t.status.equals('active'));
    }

    return (q
          ..orderBy([
            (t) => OrderingTerm(expression: t.rollNumber),
            (t) => OrderingTerm(expression: t.fullName),
          ]))
        .get();
  }

  // Get all students across a school (for school-wide administrative reports)
  Future<List<Student>> getAllStudentsForSchool(String schoolId, {bool activeOnly = true}) {
    var q = select(students)
      ..where((t) => t.schoolId.equals(schoolId) & t.isDeleted.equals(false));
    if (activeOnly) {
      q = q..where((t) => t.status.equals('active'));
    }
    return (q
          ..orderBy([
            (t) => OrderingTerm(expression: t.classId),
            (t) => OrderingTerm(expression: t.rollNumber),
          ]))
        .get();
  }

  // Lookup student by unique QR token (used in continuous scanner)
  Future<Student?> getStudentByQrToken(String token) {
    return (select(students)
          ..where((t) => t.qrToken.equals(token) & t.isDeleted.equals(false)))
        .getSingleOrNull();
  }

  // Check if a scanned QR token belongs to a student's revoked token history
  Future<Student?> findStudentByRevokedQrToken(String token) async {
    final rows = await customSelect(
      'SELECT student_id, previous_qr_tokens_json FROM student_extended_info WHERE previous_qr_tokens_json LIKE ?',
      variables: [Variable.withString('%$token%')],
    ).get();

    for (final r in rows) {
      final raw = r.readNullable<String>('previous_qr_tokens_json') ?? '[]';
      try {
        final list = (jsonDecode(raw) as List).map((e) => e.toString()).toList();
        if (list.contains(token)) {
          final studentId = r.readNullable<String>('student_id');
          if (studentId != null) {
            return (select(students)..where((t) => t.id.equals(studentId))).getSingleOrNull();
          }
        }
      } catch (_) {}
    }
    return null;
  }

  // Search students across class/section or school
  Future<List<Student>> searchStudents({
    required String schoolId,
    String? query,
    String? classId,
    String? sectionId,
    String? statusFilter,
  }) {
    var q = select(students)
      ..where((t) => t.schoolId.equals(schoolId) & t.isDeleted.equals(false));

    if (classId != null && classId.isNotEmpty) {
      q = q..where((t) => t.classId.equals(classId));
    }
    if (sectionId != null && sectionId.isNotEmpty) {
      q = q..where((t) => t.sectionId.equals(sectionId));
    }
    if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'all') {
      q = q..where((t) => t.status.equals(statusFilter));
    }
    if (query != null && query.trim().isNotEmpty) {
      final term = '%${query.trim()}%';
      q = q..where((t) =>
          t.fullName.like(term) |
          t.admissionNumber.like(term) |
          t.rollNumber.like(term) |
          t.fatherOrGuardianName.like(term));
    }

    return (q
          ..orderBy([
            (t) => OrderingTerm(expression: t.rollNumber),
            (t) => OrderingTerm(expression: t.fullName),
          ]))
        .get();
  }

  // Get parent contact for a student
  Future<ParentContact?> getParentContact(String studentId) {
    return (select(parentContacts)
          ..where((t) => t.studentId.equals(studentId)))
        .getSingleOrNull();
  }

  // Get holidays for a date range
  Future<List<SchoolCalendarHoliday>> getHolidays({
    required String schoolId,
    required String startDate,
    required String endDate,
  }) {
    return (select(schoolCalendarHolidays)
          ..where((t) =>
              t.schoolId.equals(schoolId) &
              t.date.isBiggerOrEqualValue(startDate) &
              t.date.isSmallerOrEqualValue(endDate) &
              t.isInstructionalDay.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
  }

  // Get KPK extended info for a student
  Future<StudentExtendedInfoModel> getExtendedInfo(String studentId) async {
    final rows = await customSelect(
      'SELECT * FROM student_extended_info WHERE student_id = ? LIMIT 1',
      variables: [Variable.withString(studentId)],
    ).get();
    if (rows.isEmpty) {
      return StudentExtendedInfoModel(studentId: studentId);
    }
    return StudentExtendedInfoModel.fromRow(rows.first);
  }

  // Upsert KPK extended info for a student
  Future<void> upsertExtendedInfo(StudentExtendedInfoModel info) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await customStatement(
      '''
      INSERT INTO student_extended_info
        (student_id, student_b_form, father_cnic, mother_name, domicile_district, leaving_date, leaving_reason, slc_number, free_books_issued, is_vaccinated, vaccine_first_dose_date, vaccine_second_dose_date, previous_qr_tokens_json, updated_at, revision)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(student_id) DO UPDATE SET
        student_b_form = excluded.student_b_form,
        father_cnic = excluded.father_cnic,
        mother_name = excluded.mother_name,
        domicile_district = excluded.domicile_district,
        leaving_date = excluded.leaving_date,
        leaving_reason = excluded.leaving_reason,
        slc_number = excluded.slc_number,
        free_books_issued = excluded.free_books_issued,
        is_vaccinated = excluded.is_vaccinated,
        vaccine_first_dose_date = excluded.vaccine_first_dose_date,
        vaccine_second_dose_date = excluded.vaccine_second_dose_date,
        previous_qr_tokens_json = excluded.previous_qr_tokens_json,
        updated_at = excluded.updated_at,
        revision = excluded.revision
      ''',
      [
        info.studentId,
        info.studentBForm,
        info.fatherCnic,
        info.motherName,
        info.domicileDistrict,
        info.leavingDate,
        info.leavingReason,
        info.slcNumber,
        info.freeBooksIssued ? 1 : 0,
        info.isVaccinated ? 1 : 0,
        info.vaccineFirstDoseDate,
        info.vaccineSecondDoseDate,
        jsonEncode(info.revokedQrTokens),
        now,
        info.revision,
      ],
    );
  }

  // Get KPK school settings
  Future<SchoolSettingsModel> getSchoolSettings(String schoolId) async {
    final rows = await customSelect(
      'SELECT * FROM school_settings WHERE school_id = ? LIMIT 1',
      variables: [Variable.withString(schoolId)],
    ).get();
    if (rows.isEmpty) {
      return SchoolSettingsModel(schoolId: schoolId);
    }
    return SchoolSettingsModel.fromRow(rows.first);
  }

  // Upsert KPK school settings
  Future<void> upsertSchoolSettings(SchoolSettingsModel settings) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await customStatement(
      '''
      INSERT INTO school_settings
        (school_id, school_type, district, tehsil, circle_office, union_council, climate_zone, opening_time, closing_time, late_cutoff_time, head_teacher_name, deo_name, working_days_csv, updated_at, revision)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(school_id) DO UPDATE SET
        school_type = excluded.school_type,
        district = excluded.district,
        tehsil = excluded.tehsil,
        circle_office = excluded.circle_office,
        union_council = excluded.union_council,
        climate_zone = excluded.climate_zone,
        opening_time = excluded.opening_time,
        closing_time = excluded.closing_time,
        late_cutoff_time = excluded.late_cutoff_time,
        head_teacher_name = excluded.head_teacher_name,
        deo_name = excluded.deo_name,
        working_days_csv = excluded.working_days_csv,
        updated_at = excluded.updated_at,
        revision = excluded.revision
      ''',
      [
        settings.schoolId,
        settings.schoolType,
        settings.district,
        settings.tehsil,
        settings.circleOffice,
        settings.unionCouncil,
        settings.climateZone,
        settings.openingTime,
        settings.closingTime,
        settings.lateCutoffTime,
        settings.headTeacherName,
        settings.deoName,
        settings.workingDaysCsv,
        now,
        settings.revision,
      ],
    );
  }
}
