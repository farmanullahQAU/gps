import 'dart:convert';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'student_dao.g.dart';

@DriftAccessor(tables: [
  Students,
  ParentContacts,
  Classes,
  Sections,
  SchoolCalendarHolidays,
  SchoolSettings,
  StudentExtendedInfo,
  TeacherGoshwaraProfiles,
])
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
    final entry = await (select(studentExtendedInfo)..where((t) => t.studentId.equals(studentId))).getSingleOrNull();
    if (entry == null) {
      return StudentExtendedInfoModel(studentId: studentId);
    }
    List<String> parsedTokens = [];
    try {
      parsedTokens = (jsonDecode(entry.previousQrTokensJson) as List).map((e) => e.toString()).toList();
    } catch (_) {}

    return StudentExtendedInfoModel(
      studentId: entry.studentId,
      studentBForm: entry.studentBForm,
      fatherCnic: entry.fatherCnic,
      motherName: entry.motherName,
      domicileDistrict: entry.domicileDistrict,
      leavingDate: entry.leavingDate,
      leavingReason: entry.leavingReason,
      slcNumber: entry.slcNumber,
      freeBooksIssued: entry.freeBooksIssued == 1,
      isVaccinated: entry.isVaccinated == 1,
      vaccineFirstDoseDate: entry.vaccineFirstDoseDate,
      vaccineSecondDoseDate: entry.vaccineSecondDoseDate,
      revokedQrTokens: parsedTokens,
      updatedAt: entry.updatedAt,
      revision: entry.revision,
    );
  }

  // Upsert KPK extended info for a student
  Future<void> upsertExtendedInfo(StudentExtendedInfoModel info) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(studentExtendedInfo).insertOnConflictUpdate(
      StudentExtendedInfoCompanion.insert(
        studentId: info.studentId,
        studentBForm: Value(info.studentBForm),
        fatherCnic: Value(info.fatherCnic),
        motherName: Value(info.motherName),
        domicileDistrict: Value(info.domicileDistrict),
        leavingDate: Value(info.leavingDate),
        leavingReason: Value(info.leavingReason),
        slcNumber: Value(info.slcNumber),
        freeBooksIssued: Value(info.freeBooksIssued ? 1 : 0),
        isVaccinated: Value(info.isVaccinated ? 1 : 0),
        vaccineFirstDoseDate: Value(info.vaccineFirstDoseDate),
        vaccineSecondDoseDate: Value(info.vaccineSecondDoseDate),
        previousQrTokensJson: Value(jsonEncode(info.revokedQrTokens)),
        updatedAt: Value(now),
        revision: Value(info.revision),
      ),
    );
  }

  // Get KPK school settings
  Future<SchoolSettingsModel> getSchoolSettings(String schoolId) async {
    final entry = await (select(schoolSettings)..where((t) => t.schoolId.equals(schoolId))).getSingleOrNull();
    if (entry == null) {
      return SchoolSettingsModel(schoolId: schoolId);
    }
    return SchoolSettingsModel(
      schoolId: entry.schoolId,
      schoolType: entry.schoolType,
      district: entry.district,
      tehsil: entry.tehsil,
      circleOffice: entry.circleOffice,
      unionCouncil: entry.unionCouncil,
      climateZone: entry.climateZone,
      openingTime: entry.openingTime,
      closingTime: entry.closingTime,
      lateCutoffTime: entry.lateCutoffTime,
      headTeacherName: entry.headTeacherName,
      deoName: entry.deoName,
      circleSdeoName: entry.circleSdeoName,
      centerInchargeName: entry.centerInchargeName,
      goshwaraNo: entry.goshwaraNo,
      naConstituency: entry.naConstituency,
      pkConstituency: entry.pkConstituency,
      ltrcCenter: entry.ltrcCenter,
      sanctionedPostsPsht: entry.sanctionedPostsPsht,
      sanctionedPostsSpst: entry.sanctionedPostsSpst,
      sanctionedPostsPst: entry.sanctionedPostsPst,
      vacantPostsPst: entry.vacantPostsPst,
      vacantPostsChowkidar: entry.vacantPostsChowkidar,
      classroomsInstructional: entry.classroomsInstructional,
      classroomsNonInstructional: entry.classroomsNonInstructional,
      establishmentYear: entry.establishmentYear,
      constructionYear: entry.constructionYear,
      facilityElectricity: entry.facilityElectricity == 1,
      facilityWaterPipe: entry.facilityWaterPipe == 1,
      facilityWaterWell: entry.facilityWaterWell == 1,
      facilitySolar: entry.facilitySolar == 1,
      facilityBoundaryWall: entry.facilityBoundaryWall == 1,
      facilityPlayArea: entry.facilityPlayArea == 1,
      facilityOffice: entry.facilityOffice == 1,
      facilityToiletCount: entry.facilityToiletCount,
      ptcChairmanName: entry.ptcChairmanName,
      ptcBankName: entry.ptcBankName,
      ptcAccountNo: entry.ptcAccountNo,
      ptcSanctionDate: entry.ptcSanctionDate,
      fundTotalBudget: entry.fundTotalBudget,
      fundTotalSpent: entry.fundTotalSpent,
      workingDaysCsv: entry.workingDaysCsv,
      updatedAt: entry.updatedAt,
      revision: entry.revision,
    );
  }

  // Upsert KPK school settings
  Future<void> upsertSchoolSettings(SchoolSettingsModel settings) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(schoolSettings).insertOnConflictUpdate(
      SchoolSettingsCompanion.insert(
        schoolId: settings.schoolId,
        schoolType: Value(settings.schoolType),
        district: Value(settings.district),
        tehsil: Value(settings.tehsil),
        circleOffice: Value(settings.circleOffice),
        unionCouncil: Value(settings.unionCouncil),
        climateZone: Value(settings.climateZone),
        openingTime: Value(settings.openingTime),
        closingTime: Value(settings.closingTime),
        lateCutoffTime: Value(settings.lateCutoffTime),
        headTeacherName: Value(settings.headTeacherName),
        deoName: Value(settings.deoName),
        circleSdeoName: Value(settings.circleSdeoName),
        centerInchargeName: Value(settings.centerInchargeName),
        goshwaraNo: Value(settings.goshwaraNo),
        naConstituency: Value(settings.naConstituency),
        pkConstituency: Value(settings.pkConstituency),
        ltrcCenter: Value(settings.ltrcCenter),
        sanctionedPostsPsht: Value(settings.sanctionedPostsPsht),
        sanctionedPostsSpst: Value(settings.sanctionedPostsSpst),
        sanctionedPostsPst: Value(settings.sanctionedPostsPst),
        vacantPostsPst: Value(settings.vacantPostsPst),
        vacantPostsChowkidar: Value(settings.vacantPostsChowkidar),
        classroomsInstructional: Value(settings.classroomsInstructional),
        classroomsNonInstructional: Value(settings.classroomsNonInstructional),
        establishmentYear: Value(settings.establishmentYear),
        constructionYear: Value(settings.constructionYear),
        facilityElectricity: Value(settings.facilityElectricity ? 1 : 0),
        facilityWaterPipe: Value(settings.facilityWaterPipe ? 1 : 0),
        facilityWaterWell: Value(settings.facilityWaterWell ? 1 : 0),
        facilitySolar: Value(settings.facilitySolar ? 1 : 0),
        facilityBoundaryWall: Value(settings.facilityBoundaryWall ? 1 : 0),
        facilityPlayArea: Value(settings.facilityPlayArea ? 1 : 0),
        facilityOffice: Value(settings.facilityOffice ? 1 : 0),
        facilityToiletCount: Value(settings.facilityToiletCount),
        ptcChairmanName: Value(settings.ptcChairmanName),
        ptcBankName: Value(settings.ptcBankName),
        ptcAccountNo: Value(settings.ptcAccountNo),
        ptcSanctionDate: Value(settings.ptcSanctionDate),
        fundTotalBudget: Value(settings.fundTotalBudget),
        fundTotalSpent: Value(settings.fundTotalSpent),
        workingDaysCsv: Value(settings.workingDaysCsv),
        updatedAt: Value(now),
        revision: Value(settings.revision),
      ),
    );
  }

  // Get Teacher Goshwara Profile
  Future<TeacherGoshwaraProfile> getTeacherGoshwaraProfile(String userId) async {
    final entry = await (select(teacherGoshwaraProfiles)..where((t) => t.userId.equals(userId))).getSingleOrNull();
    if (entry == null) {
      return TeacherGoshwaraProfile(userId: userId);
    }
    return TeacherGoshwaraProfile(
      userId: entry.userId,
      fatherName: entry.fatherName,
      personalNo: entry.personalNo,
      dob: entry.dob,
      academicQualification: entry.academicQualification,
      professionalQualification: entry.professionalQualification,
      appointmentDate: entry.appointmentDate,
      transferInDate: entry.transferInDate,
      currentBps: entry.currentBps,
      bpsAwardDate: entry.bpsAwardDate,
      basicPay: entry.basicPay,
      village: entry.village,
      unionCouncil: entry.unionCouncil,
      district: entry.district,
      employmentType: entry.employmentType,
      updatedAt: entry.updatedAt,
      revision: entry.revision,
    );
  }

  // Upsert Teacher Goshwara Profile
  Future<void> upsertTeacherGoshwaraProfile(TeacherGoshwaraProfile profile) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await into(teacherGoshwaraProfiles).insertOnConflictUpdate(
      TeacherGoshwaraProfilesCompanion.insert(
        userId: profile.userId,
        fatherName: Value(profile.fatherName),
        personalNo: Value(profile.personalNo),
        dob: Value(profile.dob),
        academicQualification: Value(profile.academicQualification),
        professionalQualification: Value(profile.professionalQualification),
        appointmentDate: Value(profile.appointmentDate),
        transferInDate: Value(profile.transferInDate),
        currentBps: Value(profile.currentBps),
        bpsAwardDate: Value(profile.bpsAwardDate),
        basicPay: Value(profile.basicPay),
        village: Value(profile.village),
        unionCouncil: Value(profile.unionCouncil),
        district: Value(profile.district),
        employmentType: Value(profile.employmentType),
        updatedAt: Value(now),
        revision: Value(profile.revision),
      ),
    );
  }
}
