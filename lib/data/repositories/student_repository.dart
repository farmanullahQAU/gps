import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/student_dao.dart';
import '../../core/database/daos/sync_dao.dart';
import '../../core/services/cloud_storage_service.dart';
import '../../core/utils/idempotency.dart';
import '../../core/utils/kpk_register_helper.dart';
import 'sync_repository.dart';

class StudentRepository {
  final AppDatabase db;
  final SyncRepository? syncRepository;
  late final StudentDao studentDao;
  late final SyncDao syncDao;

  StudentRepository(this.db, {this.syncRepository}) {
    studentDao = db.studentDao;
    syncDao = db.syncDao;
  }

  /// Write-through trigger: Dispatches to reactive SyncController pipeline (or direct push in tests)
  void _triggerLiveSync() {
    syncRepository?.triggerMutation();
  }

  // Get all classes for school
  Future<List<ClassesData>> getClasses(String schoolId) {
    return (db.select(db.classes)
          ..where((t) => t.schoolId.equals(schoolId))
          ..orderBy([(t) => OrderingTerm(expression: t.numericLevel)]))
        .get();
  }

  // Get sections for class
  Future<List<Section>> getSections(String classId, {String? schoolId}) {
    var q = db.select(db.sections)..where((t) => t.classId.equals(classId));
    if (schoolId != null) {
      q = q..where((t) => t.schoolId.equals(schoolId));
    }
    return (q..orderBy([(t) => OrderingTerm(expression: t.name)])).get();
  }

  // Get all sections for a school
  Future<List<Section>> getAllSectionsForSchool(String schoolId) {
    return (db.select(db.sections)
          ..where((t) => t.schoolId.equals(schoolId))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  /// Helper: Natural numeric sorting by student roll number (e.g. 1, 2, ..., 9, 10 instead of 1, 10, 2)
  static List<Student> sortByRollNumber(List<Student> list) {
    final sorted = List<Student>.from(list);
    sorted.sort((a, b) {
      final rA = int.tryParse((a.rollNumber ?? '').trim());
      final rB = int.tryParse((b.rollNumber ?? '').trim());
      if (rA != null && rB != null) {
        final cmp = rA.compareTo(rB);
        if (cmp != 0) return cmp;
      } else if (rA != null) {
        return -1;
      } else if (rB != null) {
        return 1;
      } else {
        final cmp = (a.rollNumber ?? '').compareTo(b.rollNumber ?? '');
        if (cmp != 0) return cmp;
      }
      return a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
    });
    return sorted;
  }

  // Get students in section (ordered by numeric roll number)
  Future<List<Student>> getStudentsForSection({
    required String classId,
    required String sectionId,
    String? schoolId,
    bool includeInactive = false,
  }) async {
    final list = await studentDao.getStudentsForSection(
      classId: classId,
      sectionId: sectionId,
      schoolId: schoolId,
      includeInactive: includeInactive,
    );
    return sortByRollNumber(list);
  }

  // Get all students across school (ordered by class level, then numeric roll number)
  Future<List<Student>> getAllStudentsForSchool(String schoolId, {bool activeOnly = true}) async {
    final list = await studentDao.getAllStudentsForSchool(schoolId, activeOnly: activeOnly);
    return sortByRollNumber(list);
  }

  // Search students (ordered by numeric roll number)
  Future<List<Student>> searchStudents({
    required String schoolId,
    String? query,
    String? classId,
    String? sectionId,
    String? statusFilter,
  }) async {
    final list = await studentDao.searchStudents(
      schoolId: schoolId,
      query: query,
      classId: classId,
      sectionId: sectionId,
      statusFilter: statusFilter,
    );
    return sortByRollNumber(list);
  }

  // Lookup by QR token
  Future<Student?> getStudentByQrToken(String token) {
    return studentDao.getStudentByQrToken(token);
  }

  // Check if token is a revoked QR token
  Future<Student?> findStudentByRevokedQrToken(String token) {
    return studentDao.findStudentByRevokedQrToken(token);
  }

  // Get parent details
  Future<ParentContact?> getParentContact(String studentId) {
    return studentDao.getParentContact(studentId);
  }

  // Get extended KPK student info
  Future<StudentExtendedInfoModel> getExtendedInfo(String studentId) {
    return studentDao.getExtendedInfo(studentId);
  }

  // Get holidays in date range
  Future<List<SchoolCalendarHoliday>> getHolidays({
    required String schoolId,
    required String startDate,
    required String endDate,
  }) {
    return studentDao.getHolidays(
      schoolId: schoolId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Check duplicate admission number within school scope
  Future<bool> isDuplicateAdmissionNumber({
    required String schoolId,
    required String admissionNumber,
    String? excludeStudentId,
  }) async {
    final existing = await (db.select(db.students)
          ..where((t) =>
              t.schoolId.equals(schoolId) &
              t.admissionNumber.equals(admissionNumber.trim()) &
              t.isDeleted.equals(false)))
        .get();
    if (excludeStudentId != null) {
      return existing.any((s) => s.id != excludeStudentId);
    }
    return existing.isNotEmpty;
  }

  // Add new student atomically with SyncQueue outbox and KPK extended fields
  Future<Student> createStudent({
    required String schoolId,
    required String classId,
    required String sectionId,
    required String admissionNumber,
    String? rollNumber,
    required String fullName,
    required String fatherOrGuardianName,
    required String gender,
    String? dateOfBirth,
    required String admissionDate,
    required String parentPhone,
    String? studentCnic,
    String? studentBForm,
    String? fatherCnic,
    bool isVaccinated = false,
    String? vaccineFirstDoseDate,
    String? vaccineSecondDoseDate,
    String? photoUrl,
    String? domicileDistrict,
    String? customQrToken,
    bool freeBooksIssued = true,
  }) async {
    final isDup = await isDuplicateAdmissionNumber(
      schoolId: schoolId,
      admissionNumber: admissionNumber,
    );
    if (isDup) {
      throw Exception('Admission Number "$admissionNumber" already exists in this school.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final studentId = 'std_${DateTime.now().microsecondsSinceEpoch}';
    final qrToken = (customQrToken != null && customQrToken.trim().isNotEmpty)
        ? customQrToken.trim()
        : IdempotencyUtil.generateOpaqueQrToken();

    final resolvedCnic = studentCnic ?? studentBForm;
    final persistedPhoto = await CloudStorageService.instance.persistAndUploadPhoto(
      category: 'students',
      entityId: studentId,
      sourcePath: photoUrl,
    );

    final student = await db.transaction(() async {
      final student = Student(
        id: studentId,
        schoolId: schoolId,
        classId: classId,
        sectionId: sectionId,
        admissionNumber: admissionNumber.trim(),
        rollNumber: rollNumber?.trim(),
        fullName: fullName.trim(),
        fatherOrGuardianName: fatherOrGuardianName.trim(),
        gender: gender,
        dateOfBirth: dateOfBirth,
        admissionDate: admissionDate,
        status: 'active',
        qrToken: qrToken,
        photoUrl: persistedPhoto?.trim(),
        studentCnic: resolvedCnic?.trim(),
        fatherCnic: fatherCnic?.trim(),
        isVaccinated: isVaccinated,
        vaccineFirstDoseDate: vaccineFirstDoseDate?.trim(),
        vaccineSecondDoseDate: vaccineSecondDoseDate?.trim(),
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
        revision: 1,
      );

      await db.into(db.students).insert(student);

      final extInfo = StudentExtendedInfoModel(
        studentId: studentId,
        studentBForm: resolvedCnic?.trim(),
        fatherCnic: fatherCnic?.trim(),
        isVaccinated: isVaccinated,
        vaccineFirstDoseDate: vaccineFirstDoseDate?.trim(),
        vaccineSecondDoseDate: vaccineSecondDoseDate?.trim(),
        domicileDistrict: domicileDistrict ?? 'Peshawar',
        freeBooksIssued: freeBooksIssued,
        revision: 1,
      );
      await studentDao.upsertExtendedInfo(extInfo);

      final parentId = 'par_$studentId';
      await db.into(db.parentContacts).insert(
            ParentContactsCompanion.insert(
              id: parentId,
              studentId: studentId,
              relation: 'father',
              phoneNumber: parentPhone.trim(),
              whatsappEnabled: const Value(true),
              notifyAbsent: const Value(true),
              notifyLate: const Value(true),
              notifyLeave: const Value(true),
              createdAt: now,
              updatedAt: now,
              revision: const Value(1),
            ),
          );

      await syncDao.enqueue(
        targetTable: 'students',
        recordId: student.id,
        operation: 'INSERT',
        payloadJson: jsonEncode({
          'id': student.id,
          'school_id': schoolId,
          'class_id': classId,
          'section_id': sectionId,
          'admission_number': student.admissionNumber,
          'roll_number': student.rollNumber,
          'full_name': student.fullName,
          'father_or_guardian_name': student.fatherOrGuardianName,
          'gender': student.gender,
          'date_of_birth': student.dateOfBirth,
          'admission_date': student.admissionDate,
          'status': student.status,
          'qr_token': student.qrToken,
          'photo_url': student.photoUrl,
          'parent_phone': parentPhone.trim(),
          'student_b_form': resolvedCnic?.trim(),
          'student_cnic': resolvedCnic?.trim(),
          'father_cnic': fatherCnic?.trim(),
          'is_vaccinated': isVaccinated ? 1 : 0,
          'vaccine_first_dose_date': vaccineFirstDoseDate?.trim(),
          'vaccine_second_dose_date': vaccineSecondDoseDate?.trim(),
          'created_at': now,
          'updated_at': now,
          'revision': 1,
        }),
        idempotencyKey: IdempotencyUtil.forStudent(student.id, 1),
        clientRevision: 1,
      );

      // Enqueue 3NF child entities for Cloudflare D1 Sync
      await syncDao.enqueue(
        targetTable: 'parent_contacts',
        recordId: parentId,
        operation: 'INSERT',
        payloadJson: jsonEncode({
          'id': parentId,
          'student_id': studentId,
          'relation': 'father',
          'phone_number': parentPhone.trim(),
          'whatsapp_enabled': 1,
          'notify_absent': 1,
          'notify_late': 1,
          'notify_leave': 1,
          'created_at': now,
          'updated_at': now,
          'revision': 1,
        }),
        idempotencyKey: 'par_${studentId}_v1',
        clientRevision: 1,
      );

      await syncDao.enqueue(
        targetTable: 'student_extended_info',
        recordId: studentId,
        operation: 'INSERT',
        payloadJson: jsonEncode({
          'student_id': studentId,
          'student_b_form': studentBForm,
          'father_cnic': fatherCnic,
          'domicile_district': domicileDistrict ?? 'Peshawar',
          'free_books_issued': freeBooksIssued ? 1 : 0,
          'previous_qr_tokens_json': [],
          'updated_at': now,
          'revision': 1,
        }),
        idempotencyKey: 'ext_${studentId}_v1',
        clientRevision: 1,
      );

      return student;
    });

    _triggerLiveSync();
    return student;
  }

  // Edit / Transfer / Update Student Status (Preserves all historical attendance)
  Future<Student> updateStudent({
    required Student existing,
    required String classId,
    required String sectionId,
    required String admissionNumber,
    String? rollNumber,
    required String fullName,
    required String fatherOrGuardianName,
    required String gender,
    String? dateOfBirth,
    required String status, // 'active' | 'transferred' | 'graduated' | 'inactive'
    String? parentPhone,
    String? studentCnic,
    String? studentBForm,
    String? fatherCnic,
    String? photoUrl,
    bool? isVaccinated,
    String? vaccineFirstDoseDate,
    String? vaccineSecondDoseDate,
    String? leavingDate,
    String? slcNumber,
  }) async {
    final isDup = await isDuplicateAdmissionNumber(
      schoolId: existing.schoolId,
      admissionNumber: admissionNumber,
      excludeStudentId: existing.id,
    );
    if (isDup) {
      throw Exception('Admission Number "$admissionNumber" is already assigned to another student.');
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final nextRev = existing.revision + 1;
    final resolvedCnic = studentCnic ?? studentBForm;
    final persistedPhoto = photoUrl != null
        ? await CloudStorageService.instance.persistAndUploadPhoto(
            category: 'students',
            entityId: existing.id,
            sourcePath: photoUrl,
          )
        : existing.photoUrl;

    final updated = await db.transaction(() async {
      final updated = existing.copyWith(
        classId: classId,
        sectionId: sectionId,
        admissionNumber: admissionNumber.trim(),
        rollNumber: Value(rollNumber?.trim()),
        fullName: fullName.trim(),
        fatherOrGuardianName: fatherOrGuardianName.trim(),
        gender: gender,
        dateOfBirth: Value(dateOfBirth),
        photoUrl: Value(persistedPhoto?.trim()),
        studentCnic: Value(resolvedCnic?.trim() ?? existing.studentCnic),
        fatherCnic: Value(fatherCnic?.trim() ?? existing.fatherCnic),
        isVaccinated: isVaccinated ?? existing.isVaccinated,
        vaccineFirstDoseDate: Value(vaccineFirstDoseDate?.trim() ?? existing.vaccineFirstDoseDate),
        vaccineSecondDoseDate: Value(vaccineSecondDoseDate?.trim() ?? existing.vaccineSecondDoseDate),
        status: status,
        updatedAt: now,
        revision: nextRev,
      );

      await db.update(db.students).replace(updated);

      final ext = await studentDao.getExtendedInfo(existing.id);
      final nextExtRev = ext.revision + 1;
      final updatedExt = StudentExtendedInfoModel(
        studentId: existing.id,
        studentBForm: resolvedCnic?.trim() ?? ext.studentBForm,
        fatherCnic: fatherCnic?.trim() ?? ext.fatherCnic,
        isVaccinated: isVaccinated ?? ext.isVaccinated,
        vaccineFirstDoseDate: vaccineFirstDoseDate?.trim() ?? ext.vaccineFirstDoseDate,
        vaccineSecondDoseDate: vaccineSecondDoseDate?.trim() ?? ext.vaccineSecondDoseDate,
        domicileDistrict: ext.domicileDistrict,
        leavingDate: leavingDate ?? (status != 'active' ? DateTime.now().toIso8601String().substring(0, 10) : ext.leavingDate),
        slcNumber: slcNumber ?? ext.slcNumber,
        freeBooksIssued: ext.freeBooksIssued,
        revokedQrTokens: ext.revokedQrTokens,
        revision: nextExtRev,
      );
      await studentDao.upsertExtendedInfo(updatedExt);

      await syncDao.enqueue(
        targetTable: 'student_extended_info',
        recordId: existing.id,
        operation: 'UPDATE',
        payloadJson: jsonEncode({
          'student_id': existing.id,
          'student_b_form': updatedExt.studentBForm,
          'father_cnic': updatedExt.fatherCnic,
          'is_vaccinated': updatedExt.isVaccinated ? 1 : 0,
          'vaccine_first_dose_date': updatedExt.vaccineFirstDoseDate,
          'vaccine_second_dose_date': updatedExt.vaccineSecondDoseDate,
          'domicile_district': updatedExt.domicileDistrict,
          'leaving_date': updatedExt.leavingDate,
          'leaving_reason': updatedExt.leavingReason,
          'slc_number': updatedExt.slcNumber,
          'free_books_issued': updatedExt.freeBooksIssued ? 1 : 0,
          'previous_qr_tokens_json': updatedExt.revokedQrTokens,
          'updated_at': now,
          'revision': nextExtRev,
        }),
        idempotencyKey: 'ext_${existing.id}_v$nextExtRev',
        clientRevision: nextExtRev,
      );

      if (parentPhone != null && parentPhone.trim().isNotEmpty) {
        final parent = await studentDao.getParentContact(existing.id);
        if (parent != null) {
          final nextParRev = parent.revision + 1;
          await (db.update(db.parentContacts)..where((t) => t.id.equals(parent.id))).write(
            ParentContactsCompanion(
              phoneNumber: Value(parentPhone.trim()),
              updatedAt: Value(now),
              revision: Value(nextParRev),
            ),
          );

          await syncDao.enqueue(
            targetTable: 'parent_contacts',
            recordId: parent.id,
            operation: 'UPDATE',
            payloadJson: jsonEncode({
              'id': parent.id,
              'student_id': existing.id,
              'relation': parent.relation,
              'phone_number': parentPhone.trim(),
              'whatsapp_enabled': parent.whatsappEnabled ? 1 : 0,
              'notify_absent': parent.notifyAbsent ? 1 : 0,
              'notify_late': parent.notifyLate ? 1 : 0,
              'notify_leave': parent.notifyLeave ? 1 : 0,
              'updated_at': now,
              'revision': nextParRev,
            }),
            idempotencyKey: 'par_${parent.id}_v$nextParRev',
            clientRevision: nextParRev,
          );
        }
      }

      await syncDao.enqueue(
        targetTable: 'students',
        recordId: updated.id,
        operation: 'UPDATE',
        payloadJson: jsonEncode({
          'id': updated.id,
          'school_id': updated.schoolId,
          'class_id': updated.classId,
          'section_id': updated.sectionId,
          'admission_number': updated.admissionNumber,
          'roll_number': updated.rollNumber,
          'full_name': updated.fullName,
          'father_or_guardian_name': updated.fatherOrGuardianName,
          'gender': updated.gender,
          'status': updated.status,
          'qr_token': updated.qrToken,
          'photo_url': updated.photoUrl,
          'student_cnic': updated.studentCnic,
          'father_cnic': updated.fatherCnic,
          'is_vaccinated': updated.isVaccinated ? 1 : 0,
          'vaccine_first_dose_date': updated.vaccineFirstDoseDate,
          'vaccine_second_dose_date': updated.vaccineSecondDoseDate,
          'leaving_date': leavingDate,
          'slc_number': slcNumber,
          'updated_at': now,
          'revision': nextRev,
        }),
        idempotencyKey: IdempotencyUtil.forStudent(updated.id, nextRev),
        clientRevision: nextRev,
      );

      return updated;
    });

    _triggerLiveSync();
    return updated;
  }

  // Rotate / Replace Student QR Credential (Revokes old token & generates new opaque token)
  Future<Student> rotateStudentQrToken(Student student) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final newQrToken = IdempotencyUtil.generateOpaqueQrToken();
    final nextRev = student.revision + 1;

    final updated = await db.transaction(() async {
      final ext = await studentDao.getExtendedInfo(student.id);
      final updatedRevoked = <String>{...ext.revokedQrTokens, student.qrToken}.toList();
      final nextExtRev = ext.revision + 1;

      await studentDao.upsertExtendedInfo(
        StudentExtendedInfoModel(
          studentId: student.id,
          studentBForm: ext.studentBForm,
          fatherCnic: ext.fatherCnic,
          motherName: ext.motherName,
          domicileDistrict: ext.domicileDistrict,
          leavingDate: ext.leavingDate,
          leavingReason: ext.leavingReason,
          slcNumber: ext.slcNumber,
          freeBooksIssued: ext.freeBooksIssued,
          revokedQrTokens: updatedRevoked,
          revision: nextExtRev,
        ),
      );

      final updated = student.copyWith(
        qrToken: newQrToken,
        updatedAt: now,
        revision: nextRev,
      );
      await db.update(db.students).replace(updated);

      await syncDao.enqueue(
        targetTable: 'students',
        recordId: updated.id,
        operation: 'UPDATE',
        payloadJson: jsonEncode({
          'id': updated.id,
          'school_id': updated.schoolId,
          'qr_token': newQrToken,
          'revoked_qr_token': student.qrToken,
          'updated_at': now,
          'revision': nextRev,
        }),
        idempotencyKey: 'qr_rot_${updated.id}_v$nextRev',
        clientRevision: nextRev,
      );

      await syncDao.enqueue(
        targetTable: 'student_extended_info',
        recordId: student.id,
        operation: 'UPDATE',
        payloadJson: jsonEncode({
          'student_id': student.id,
          'previous_qr_tokens_json': updatedRevoked,
          'updated_at': now,
          'revision': nextExtRev,
        }),
        idempotencyKey: 'ext_qr_${student.id}_v$nextExtRev',
        clientRevision: nextExtRev,
      );

      return updated;
    });

    _triggerLiveSync();
    return updated;
  }

  // Bulk import students from CSV lines
  // Supported formats:
  // 1) Dynamic Header Mapped: ADM_NO, ADM_DATE, STD_NAME, STD_FNAME, DOB, GENDER, CNIC, VACCINATED, FIRST_DOSE, SECOND_DOSE, F_CNIC, CLS_ROLL_NO
  // 2) Standard: AdmissionNo, RollNo, FullName, FatherName, Gender, ParentPhone, BForm
  // 3) Multi-Class: ClassName, SectionName, AdmissionNo, RollNo, FullName, FatherName, Gender, ParentPhone, BForm
  Future<int> bulkImportCsv({
    required String schoolId,
    String? classId,
    String? sectionId,
    required String csvContent,
  }) async {
    final lines = const LineSplitter()
        .convert(csvContent)
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) return 0;

    int importedCount = 0;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final schoolClasses = await getClasses(schoolId);
    final schoolSections = await getAllSectionsForSchool(schoolId);

    final firstLine = lines.first;
    final delimiter = firstLine.contains('\t') ? '\t' : ',';
    final rawHeaderParts = firstLine.split(delimiter).map((p) => p.trim()).toList();
    final headerParts = rawHeaderParts.map((p) => p.toUpperCase().replaceAll(' ', '_')).toList();

    final isHeader = headerParts.any((h) =>
        h.contains('ADM') ||
        h.contains('NAME') ||
        h.contains('ROLL') ||
        h.contains('CNIC') ||
        h == 'DOB' ||
        h == 'GENDER');

    final admNoIdx = headerParts.indexWhere((h) => h == 'ADM_NO' || h == 'ADM' || h == 'ADMISSION_NO' || h == 'ADMISSION_NUMBER');
    final admDateIdx = headerParts.indexWhere((h) => h == 'ADM_DATE' || h == 'ADMISSION_DATE');
    final nameIdx = headerParts.indexWhere((h) => h == 'STD_NAME' || h == 'STUDENT_NAME' || h == 'FULL_NAME' || h == 'NAME');
    final fnameIdx = headerParts.indexWhere((h) => h == 'STD_FNAME' || h == 'FATHER_NAME' || h == 'FNAME' || h == 'FATHER_OR_GUARDIAN_NAME');
    final dobIdx = headerParts.indexWhere((h) => h == 'DOB' || h == 'DATE_OF_BIRTH' || h == 'BIRTH_DATE');
    final genderIdx = headerParts.indexWhere((h) => h == 'GENDER' || h == 'SEX');
    final cnicIdx = headerParts.indexWhere((h) => h == 'CNIC' || h == 'B_FORM' || h == 'BFORM' || h == 'STUDENT_CNIC');
    final fCnicIdx = headerParts.indexWhere((h) => h == 'F_CNIC' || h == 'FATHER_CNIC' || h == 'FCNIC');
    final rollIdx = headerParts.indexWhere((h) => h == 'CLS_ROLL_NO' || h == 'ROLL_NO' || h == 'ROLL' || h == 'ROLL_NUMBER');
    final vacIdx = headerParts.indexWhere((h) => h == 'VACCINATED' || h == 'IS_VACCINATED' || h == 'VACCINE');
    final firstDoseIdx = headerParts.indexWhere((h) => h == 'FIRST_DOSE' || h == 'DOSE_1' || h == 'VACCINE_FIRST_DOSE_DATE');
    final secondDoseIdx = headerParts.indexWhere((h) => h == 'SECOND_DOSE' || h == 'DOSE_2' || h == 'VACCINE_SECOND_DOSE_DATE');
    final phoneIdx = headerParts.indexWhere((h) => h == 'PHONE' || h == 'MOBILE' || h == 'PARENT_PHONE' || h == 'CONTACT');
    final classIdx = headerParts.indexWhere((h) => h == 'CLASS' || h == 'CLASS_NAME' || h == 'GRADE');
    final secIdx = headerParts.indexWhere((h) => h == 'SECTION' || h == 'SECTION_NAME' || h == 'SEC');

    final bool isMappedHeader = isHeader && (admNoIdx != -1 || nameIdx != -1);

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (i == 0 && isHeader) continue;

      final parts = line.split(delimiter).map((p) => p.trim()).toList();
      if (parts.length < 2) continue;

      String targetClassId = classId ?? '';
      String targetSectionId = sectionId ?? '';
      String admNo;
      String? rollNo;
      String fullName;
      String fatherName;
      String gender = 'male';
      String phone = '+923330000000';
      String? studentCnic;
      String? fatherCnic;
      String? dob;
      String admDate = todayStr;
      bool isVaccinated = false;
      String? firstDoseDate;
      String? secondDoseDate;
      String? customQrToken;

      if (isMappedHeader) {
        admNo = admNoIdx != -1 && admNoIdx < parts.length ? parts[admNoIdx] : '';
        fullName = nameIdx != -1 && nameIdx < parts.length ? parts[nameIdx] : '';
        fatherName = fnameIdx != -1 && fnameIdx < parts.length ? parts[fnameIdx] : '';
        if (admDateIdx != -1 && admDateIdx < parts.length && parts[admDateIdx].isNotEmpty) {
          admDate = parts[admDateIdx];
        }
        if (dobIdx != -1 && dobIdx < parts.length && parts[dobIdx].isNotEmpty) {
          dob = parts[dobIdx];
        }
        if (rollIdx != -1 && rollIdx < parts.length && parts[rollIdx].isNotEmpty) {
          rollNo = parts[rollIdx];
        }
        if (genderIdx != -1 && genderIdx < parts.length && parts[genderIdx].isNotEmpty) {
          gender = parts[genderIdx].toLowerCase();
        }
        if (cnicIdx != -1 && cnicIdx < parts.length && parts[cnicIdx].isNotEmpty) {
          studentCnic = parts[cnicIdx];
        }
        if (fCnicIdx != -1 && fCnicIdx < parts.length && parts[fCnicIdx].isNotEmpty) {
          fatherCnic = parts[fCnicIdx];
        }
        if (vacIdx != -1 && vacIdx < parts.length && parts[vacIdx].isNotEmpty) {
          final vLower = parts[vacIdx].toLowerCase();
          isVaccinated = vLower == '1' || vLower == 'true' || vLower.contains('y');
        }
        if (firstDoseIdx != -1 && firstDoseIdx < parts.length && parts[firstDoseIdx].isNotEmpty) {
          firstDoseDate = parts[firstDoseIdx];
        }
        if (secondDoseIdx != -1 && secondDoseIdx < parts.length && parts[secondDoseIdx].isNotEmpty) {
          secondDoseDate = parts[secondDoseIdx];
        }
        if (phoneIdx != -1 && phoneIdx < parts.length && parts[phoneIdx].isNotEmpty) {
          phone = parts[phoneIdx];
        }

        // Optional class/section match from row
        if (classIdx != -1 && classIdx < parts.length && parts[classIdx].isNotEmpty) {
          final cQuery = parts[classIdx].toLowerCase();
          final matched = schoolClasses.firstWhereOrNull((c) =>
              c.id == parts[classIdx] ||
              c.name.toLowerCase() == cQuery ||
              c.name.toLowerCase().contains(cQuery));
          if (matched != null) {
            targetClassId = matched.id;
            if (secIdx != -1 && secIdx < parts.length && parts[secIdx].isNotEmpty) {
              final sQuery = parts[secIdx].toLowerCase();
              final secMatched = schoolSections.firstWhereOrNull((s) =>
                  s.classId == matched.id &&
                  (s.name.toLowerCase() == sQuery || s.name.toLowerCase().contains(sQuery)));
              targetSectionId = secMatched?.id ?? '';
            } else {
              targetSectionId = schoolSections.firstWhereOrNull((s) => s.classId == matched.id)?.id ?? '';
            }
          }
        }
      } else {
        // Positional formats
        final firstLower = parts[0].toLowerCase();
        final isMultiClassRow = firstLower.contains('class') || firstLower.contains('kachi') || firstLower.contains('pakki') || firstLower.startsWith('cls_');

        if (isMultiClassRow && parts.length >= 6) {
          final classNameQuery = parts[0].trim();
          final sectionNameQuery = parts[1].trim();

          final matchedClass = schoolClasses.firstWhereOrNull((c) {
            final cName = c.name.toLowerCase();
            final qName = classNameQuery.toLowerCase();
            if (c.id == classNameQuery || cName == qName || cName.contains(qName) || qName.contains(cName)) {
              return true;
            }
            final qDigits = RegExp(r'\d+').firstMatch(qName)?.group(0);
            if (qDigits != null && c.numericLevel.toString() == qDigits) {
              return true;
            }
            if ((qName.contains('kachi') || qName.contains('prep') || qName.contains('kg')) && c.numericLevel == 0) {
              return true;
            }
            return false;
          });

          if (matchedClass != null) {
            targetClassId = matchedClass.id;
            final secQuery = sectionNameQuery.toLowerCase();
            final matchedSec = schoolSections.firstWhereOrNull((s) =>
                s.classId == matchedClass.id &&
                (s.name.toLowerCase() == secQuery ||
                 s.name.toLowerCase().contains(secQuery) ||
                 secQuery.contains(s.name.toLowerCase())));
            targetSectionId = matchedSec?.id ?? (schoolSections.where((s) => s.classId == matchedClass.id).firstOrNull?.id ?? '');
          } else {
            continue;
          }

          admNo = parts[2];
          rollNo = parts[3];
          fullName = parts[4];
          fatherName = parts[5];
          if (parts.length > 6 && parts[6].isNotEmpty) gender = parts[6].toLowerCase();
          if (parts.length > 7 && parts[7].isNotEmpty) phone = parts[7];
          if (parts.length > 8 && parts[8].isNotEmpty) studentCnic = parts[8];
          if (parts.length > 9 && parts[9].isNotEmpty) customQrToken = parts[9];
        } else {
          // Standard format without class prefix
          admNo = parts[0];
          rollNo = parts.length > 1 ? parts[1] : '';
          fullName = parts.length > 2 ? parts[2] : '';
          fatherName = parts.length > 3 ? parts[3] : '';
          if (parts.length > 4 && parts[4].isNotEmpty) gender = parts[4].toLowerCase();
          if (parts.length > 5 && parts[5].isNotEmpty) phone = parts[5];
          if (parts.length > 6 && parts[6].isNotEmpty) studentCnic = parts[6];
          if (parts.length > 7 && parts[7].isNotEmpty) customQrToken = parts[7];
        }
      }

      if (targetClassId.isEmpty || targetSectionId.isEmpty) continue;
      if (admNo.isEmpty || fullName.isEmpty) continue;
      if (await isDuplicateAdmissionNumber(schoolId: schoolId, admissionNumber: admNo)) {
        continue;
      }

      await createStudent(
        schoolId: schoolId,
        classId: targetClassId,
        sectionId: targetSectionId,
        admissionNumber: admNo,
        rollNumber: rollNo,
        fullName: fullName,
        fatherOrGuardianName: fatherName,
        gender: (gender == 'female' || gender == 'other') ? gender : 'male',
        dateOfBirth: dob,
        admissionDate: admDate,
        parentPhone: phone,
        studentCnic: studentCnic,
        fatherCnic: fatherCnic,
        isVaccinated: isVaccinated,
        vaccineFirstDoseDate: firstDoseDate,
        vaccineSecondDoseDate: secondDoseDate,
        customQrToken: customQrToken,
      );
      importedCount++;
    }

    return importedCount;
  }

  /// Populates a comprehensive 30-student sample roster for Classes 1 to 5 (6 students per class)
  Future<int> populateSampleRosterForSchool(String schoolId) async {
    final schoolClasses = await getClasses(schoolId);
    final schoolSections = await getAllSectionsForSchool(schoolId);

    if (schoolClasses.isEmpty) return 0;

    // KPK Sample Students: 6 students per class across Class 1 to 5 (total 30 students)
    final sampleData = <Map<String, String>>[
      // --- CLASS 1 ---
      {'cls': 'Class 1', 'sec': 'A', 'adm': 'ADM-C1-001', 'roll': '1', 'name': 'Muhammad Ali', 'father': 'Tariq Mehmood', 'gender': 'male', 'phone': '+923001234561'},
      {'cls': 'Class 1', 'sec': 'A', 'adm': 'ADM-C1-002', 'roll': '2', 'name': 'Fatima Bibi', 'father': 'Abdul Rasheed', 'gender': 'female', 'phone': '+923001234562'},
      {'cls': 'Class 1', 'sec': 'A', 'adm': 'ADM-C1-003', 'roll': '3', 'name': 'Ahmad Khan', 'father': 'Gul Zaman', 'gender': 'male', 'phone': '+923001234563'},
      {'cls': 'Class 1', 'sec': 'A', 'adm': 'ADM-C1-004', 'roll': '4', 'name': 'Zainab Noor', 'father': 'Muhammad Iqbal', 'gender': 'female', 'phone': '+923001234564'},
      {'cls': 'Class 1', 'sec': 'A', 'adm': 'ADM-C1-005', 'roll': '5', 'name': 'Bilal Farooq', 'father': 'Farooq Shah', 'gender': 'male', 'phone': '+923001234565'},
      {'cls': 'Class 1', 'sec': 'A', 'adm': 'ADM-C1-006', 'roll': '6', 'name': 'Ayesha Tariq', 'father': 'Tariq Jamil', 'gender': 'female', 'phone': '+923001234566'},

      // --- CLASS 2 ---
      {'cls': 'Class 2', 'sec': 'A', 'adm': 'ADM-C2-001', 'roll': '1', 'name': 'Hamza Jan', 'father': 'Said Jan', 'gender': 'male', 'phone': '+923001234567'},
      {'cls': 'Class 2', 'sec': 'A', 'adm': 'ADM-C2-002', 'roll': '2', 'name': 'Maryam Gul', 'father': 'Zahir Shah', 'gender': 'female', 'phone': '+923001234568'},
      {'cls': 'Class 2', 'sec': 'A', 'adm': 'ADM-C2-003', 'roll': '3', 'name': 'Usman Ghani', 'father': 'Sher Alam', 'gender': 'male', 'phone': '+923001234569'},
      {'cls': 'Class 2', 'sec': 'A', 'adm': 'ADM-C2-004', 'roll': '4', 'name': 'Hafsa Bibi', 'father': 'Naseer Khan', 'gender': 'female', 'phone': '+923001234570'},
      {'cls': 'Class 2', 'sec': 'A', 'adm': 'ADM-C2-005', 'roll': '5', 'name': 'Zubair Ahmad', 'father': 'Mushtaq Ahmad', 'gender': 'male', 'phone': '+923001234571'},
      {'cls': 'Class 2', 'sec': 'A', 'adm': 'ADM-C2-006', 'roll': '6', 'name': 'Khadija Rehman', 'father': 'Abdur Rehman', 'gender': 'female', 'phone': '+923001234572'},

      // --- CLASS 3 ---
      {'cls': 'Class 3', 'sec': 'A', 'adm': 'ADM-C3-001', 'roll': '1', 'name': 'Daniyal Khan', 'father': 'Javed Iqbal', 'gender': 'male', 'phone': '+923001234573'},
      {'cls': 'Class 3', 'sec': 'A', 'adm': 'ADM-C3-002', 'roll': '2', 'name': 'Laiba Noor', 'father': 'Khalid Usman', 'gender': 'female', 'phone': '+923001234574'},
      {'cls': 'Class 3', 'sec': 'A', 'adm': 'ADM-C3-003', 'roll': '3', 'name': 'Shahzeb Alam', 'father': 'Alamgir Khan', 'gender': 'male', 'phone': '+923001234575'},
      {'cls': 'Class 3', 'sec': 'A', 'adm': 'ADM-C3-004', 'roll': '4', 'name': 'Hoorain Fatima', 'father': 'Amjad Ali', 'gender': 'female', 'phone': '+923001234576'},
      {'cls': 'Class 3', 'sec': 'A', 'adm': 'ADM-C3-005', 'roll': '5', 'name': 'Talha Mehmood', 'father': 'Arshad Mehmood', 'gender': 'male', 'phone': '+923001234577'},
      {'cls': 'Class 3', 'sec': 'A', 'adm': 'ADM-C3-006', 'roll': '6', 'name': 'Sana Gul', 'father': 'Gulzar Ahmad', 'gender': 'female', 'phone': '+923001234578'},

      // --- CLASS 4 ---
      {'cls': 'Class 4', 'sec': 'A', 'adm': 'ADM-C4-001', 'roll': '1', 'name': 'Saad Abdullah', 'father': 'Abdullah Shah', 'gender': 'male', 'phone': '+923001234579'},
      {'cls': 'Class 4', 'sec': 'A', 'adm': 'ADM-C4-002', 'roll': '2', 'name': 'Eman Zahra', 'father': 'Syed Akhtar', 'gender': 'female', 'phone': '+923001234580'},
      {'cls': 'Class 4', 'sec': 'A', 'adm': 'ADM-C4-003', 'roll': '3', 'name': 'Ibrahim Khalil', 'father': 'Khalil Ur Rehman', 'gender': 'male', 'phone': '+923001234581'},
      {'cls': 'Class 4', 'sec': 'A', 'adm': 'ADM-C4-004', 'roll': '4', 'name': 'Manahil Khan', 'father': 'Nadir Khan', 'gender': 'female', 'phone': '+923001234582'},
      {'cls': 'Class 4', 'sec': 'A', 'adm': 'ADM-C4-005', 'roll': '5', 'name': 'Farhan Ullah', 'father': 'Inam Ullah', 'gender': 'male', 'phone': '+923001234583'},
      {'cls': 'Class 4', 'sec': 'A', 'adm': 'ADM-C4-006', 'roll': '6', 'name': 'Anum Naz', 'father': 'Nazir Hussain', 'gender': 'female', 'phone': '+923001234584'},

      // --- CLASS 5 ---
      {'cls': 'Class 5', 'sec': 'A', 'adm': 'ADM-C5-001', 'roll': '1', 'name': 'Muhammad Huzaifa', 'father': 'Noor Muhammad', 'gender': 'male', 'phone': '+923001234585'},
      {'cls': 'Class 5', 'sec': 'A', 'adm': 'ADM-C5-002', 'roll': '2', 'name': 'Bushra Bibi', 'father': 'Subhan Ullah', 'gender': 'female', 'phone': '+923001234586'},
      {'cls': 'Class 5', 'sec': 'A', 'adm': 'ADM-C5-003', 'roll': '3', 'name': 'Waleed Afridi', 'father': 'Mirza Afridi', 'gender': 'male', 'phone': '+923001234587'},
      {'cls': 'Class 5', 'sec': 'A', 'adm': 'ADM-C5-004', 'roll': '4', 'name': 'Mahnoor Tariq', 'father': 'Tariq Naveed', 'gender': 'female', 'phone': '+923001234588'},
      {'cls': 'Class 5', 'sec': 'A', 'adm': 'ADM-C5-005', 'roll': '5', 'name': 'Sufiyan Khattak', 'father': 'Ayub Khattak', 'gender': 'male', 'phone': '+923001234589'},
      {'cls': 'Class 5', 'sec': 'A', 'adm': 'ADM-C5-006', 'roll': '6', 'name': 'Khadija Bibi', 'father': 'Sardar Khan', 'gender': 'female', 'phone': '+923001234590'},
    ];

    int created = 0;
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);

    for (final item in sampleData) {
      final clsQuery = item['cls']!;
      final matchedClass = schoolClasses.firstWhereOrNull((c) =>
          c.name.toLowerCase() == clsQuery.toLowerCase() ||
          c.name.toLowerCase().contains(clsQuery.toLowerCase()) ||
          c.numericLevel.toString() == clsQuery.replaceAll(RegExp(r'[^0-9]'), ''));

      if (matchedClass == null) continue;

      final matchedSec = schoolSections.firstWhereOrNull((s) => s.classId == matchedClass.id);
      if (matchedSec == null) continue;

      final admNo = item['adm']!;
      if (await isDuplicateAdmissionNumber(schoolId: schoolId, admissionNumber: admNo)) {
        continue;
      }

      await createStudent(
        schoolId: schoolId,
        classId: matchedClass.id,
        sectionId: matchedSec.id,
        admissionNumber: admNo,
        rollNumber: item['roll']!,
        fullName: item['name']!,
        fatherOrGuardianName: item['father']!,
        gender: item['gender']!,
        admissionDate: todayStr,
        parentPhone: item['phone'] ?? '+923001234567',
      );
      created++;
    }

    return created;
  }

  // School Profile & KPK Configuration Management
  Future<School?> getSchool(String schoolId) {
    return (db.select(db.schools)..where((t) => t.id.equals(schoolId))).getSingleOrNull();
  }

  Future<SchoolSettingsModel> getSchoolSettings(String schoolId) {
    return studentDao.getSchoolSettings(schoolId);
  }

  Future<void> updateSchoolAndSettings({
    required String schoolId,
    required String name,
    required String code,
    required String address,
    required String phone,
    required String academicYearStart,
    required String academicYearEnd,
    required SchoolSettingsModel settings,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      final existingSchool = await (db.select(db.schools)..where((t) => t.id.equals(schoolId))).getSingleOrNull();
      final nextSchoolRev = (existingSchool?.revision ?? 0) + 1;

      await (db.update(db.schools)..where((t) => t.id.equals(schoolId))).write(
        SchoolsCompanion(
          name: Value(name.trim()),
          code: Value(code.trim()),
          address: Value(address.trim()),
          phone: Value(phone.trim()),
          academicYearStart: Value(academicYearStart),
          academicYearEnd: Value(academicYearEnd),
          updatedAt: Value(now),
          revision: Value(nextSchoolRev),
        ),
      );

      final nextSettingsRev = settings.revision + 1;
      final updatedSettings = SchoolSettingsModel(
        schoolId: settings.schoolId,
        schoolType: settings.schoolType,
        district: settings.district,
        tehsil: settings.tehsil,
        circleOffice: settings.circleOffice,
        unionCouncil: settings.unionCouncil,
        climateZone: settings.climateZone,
        openingTime: settings.openingTime,
        closingTime: settings.closingTime,
        lateCutoffTime: settings.lateCutoffTime,
        headTeacherName: settings.headTeacherName,
        deoName: settings.deoName,
        workingDaysCsv: settings.workingDaysCsv,
        updatedAt: now,
        revision: nextSettingsRev,
      );
      await studentDao.upsertSchoolSettings(updatedSettings);

      await syncDao.enqueue(
        targetTable: 'schools',
        recordId: schoolId,
        operation: 'UPDATE',
        payloadJson: jsonEncode({
          'id': schoolId,
          'name': name.trim(),
          'code': code.trim(),
          'address': address.trim(),
          'phone': phone.trim(),
          'academic_year_start': academicYearStart,
          'academic_year_end': academicYearEnd,
          'updated_at': now,
          'revision': nextSchoolRev,
        }),
        idempotencyKey: 'school_${schoolId}_v$nextSchoolRev',
        clientRevision: nextSchoolRev,
      );

      await syncDao.enqueue(
        targetTable: 'school_settings',
        recordId: schoolId,
        operation: 'UPDATE',
        payloadJson: jsonEncode({
          ...updatedSettings.toJson(),
          'updated_at': now,
          'revision': nextSettingsRev,
        }),
        idempotencyKey: 'settings_${schoolId}_v$nextSettingsRev',
        clientRevision: nextSettingsRev,
      );
    });

    _triggerLiveSync();
  }

  // Holiday Management
  Future<List<SchoolCalendarHoliday>> getAllHolidaysForSchool(String schoolId) {
    return (db.select(db.schoolCalendarHolidays)
          ..where((t) => t.schoolId.equals(schoolId))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
  }

  Future<void> addHoliday({
    required String schoolId,
    required String date,
    required String description,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'hol_${schoolId}_$date';
    await db.transaction(() async {
      await db.into(db.schoolCalendarHolidays).insertOnConflictUpdate(
            SchoolCalendarHolidaysCompanion.insert(
              id: id,
              schoolId: schoolId,
              date: date,
              description: description.trim(),
              isInstructionalDay: const Value(false),
              createdAt: now,
              updatedAt: now,
              revision: const Value(1),
            ),
          );

      await syncDao.enqueue(
        targetTable: 'school_calendar_holidays',
        recordId: id,
        operation: 'INSERT',
        payloadJson: jsonEncode({
          'id': id,
          'school_id': schoolId,
          'date': date,
          'description': description.trim(),
          'is_instructional_day': 0,
          'created_at': now,
          'updated_at': now,
          'revision': 1,
        }),
        idempotencyKey: 'hol_ins_$id',
        clientRevision: 1,
      );
    });

    _triggerLiveSync();
  }

  Future<void> deleteHoliday(String id) async {
    final holiday = await (db.select(db.schoolCalendarHolidays)..where((t) => t.id.equals(id))).getSingleOrNull();
    await db.transaction(() async {
      await (db.delete(db.schoolCalendarHolidays)..where((t) => t.id.equals(id))).go();
      if (holiday != null) {
        await syncDao.enqueue(
          targetTable: 'school_calendar_holidays',
          recordId: id,
          operation: 'DELETE',
          payloadJson: jsonEncode({
            'id': id,
            'school_id': holiday.schoolId,
          }),
          idempotencyKey: 'hol_del_$id',
          clientRevision: 1,
        );
      }
    });

    _triggerLiveSync();
  }

  Future<int> addHolidaysBatch({
    required String schoolId,
    required List<({String date, String description})> entries,
    bool enqueueForCloudSync = true,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    int count = 0;
    await db.transaction(() async {
      for (final entry in entries) {
        final id = 'hol_${schoolId}_${entry.date}';
        await db.into(db.schoolCalendarHolidays).insertOnConflictUpdate(
              SchoolCalendarHolidaysCompanion.insert(
                id: id,
                schoolId: schoolId,
                date: entry.date,
                description: entry.description.trim(),
                isInstructionalDay: const Value(false),
                createdAt: now,
                updatedAt: now,
                revision: const Value(1),
              ),
            );

        if (enqueueForCloudSync) {
          await syncDao.enqueue(
            targetTable: 'school_calendar_holidays',
            recordId: id,
            operation: 'INSERT',
            payloadJson: jsonEncode({
              'id': id,
              'school_id': schoolId,
              'date': entry.date,
              'description': entry.description.trim(),
              'is_instructional_day': 0,
              'created_at': now,
              'updated_at': now,
              'revision': 1,
            }),
            idempotencyKey: 'hol_ins_$id',
            clientRevision: 1,
          );
        }
        count++;
      }
    });

    if (enqueueForCloudSync) {
      _triggerLiveSync();
    }
    return count;
  }

  /// Ensures legacy 5-item seed holidays are upgraded to the full 15-date official
  /// 2026 KP E&SED Gazetted Holidays list locally without spamming Cloudflare D1.
  Future<void> ensureOfficialKpkHolidays(String schoolId) async {
    final existing = await getAllHolidaysForSchool(schoolId);
    final hasLegacySeed = existing.any((h) => h.id.startsWith('hol_') && h.id.length <= 6);
    if (existing.isEmpty || hasLegacySeed) {
      await db.transaction(() async {
        if (hasLegacySeed) {
          for (final h in existing) {
            if (h.id.startsWith('hol_') && h.id.length <= 6) {
              await (db.delete(db.schoolCalendarHolidays)..where((t) => t.id.equals(h.id))).go();
            }
          }
        }
        await addHolidaysBatch(
          schoolId: schoolId,
          entries: KpkGazettedHolidays.official2026Holidays,
          enqueueForCloudSync: false,
        );
      });
    }
  }

  // Classes & Sections Management
  Future<void> createClassWithSection({
    required String schoolId,
    required String className,
    required int numericLevel,
    required String sectionName,
    String? teacherId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final classId = 'cls_${schoolId}_${DateTime.now().microsecondsSinceEpoch}';
    final sectionId = 'sec_${schoolId}_${DateTime.now().microsecondsSinceEpoch}';

    await db.transaction(() async {
      await db.into(db.classes).insert(
            ClassesCompanion.insert(
              id: classId,
              schoolId: schoolId,
              name: className.trim(),
              numericLevel: Value(numericLevel),
              createdAt: now,
              updatedAt: now,
              revision: const Value(1),
            ),
          );

      await db.into(db.sections).insert(
            SectionsCompanion.insert(
              id: sectionId,
              schoolId: schoolId,
              classId: classId,
              name: sectionName.trim(),
              teacherId: Value(teacherId),
              createdAt: now,
              updatedAt: now,
              revision: const Value(1),
            ),
          );

      await syncDao.enqueue(
        targetTable: 'classes',
        recordId: classId,
        operation: 'INSERT',
        payloadJson: jsonEncode({
          'id': classId,
          'school_id': schoolId,
          'name': className.trim(),
          'numeric_level': numericLevel,
          'created_at': now,
          'updated_at': now,
          'revision': 1,
        }),
        idempotencyKey: 'cls_ins_${classId}_$now',
        clientRevision: 1,
      );

      await syncDao.enqueue(
        targetTable: 'sections',
        recordId: sectionId,
        operation: 'INSERT',
        payloadJson: jsonEncode({
          'id': sectionId,
          'school_id': schoolId,
          'class_id': classId,
          'name': sectionName.trim(),
          'teacher_id': teacherId,
          'created_at': now,
          'updated_at': now,
          'revision': 1,
        }),
        idempotencyKey: 'sec_ins_${sectionId}_$now',
        clientRevision: 1,
      );
    });

    _triggerLiveSync();
  }

  // Assign or update the Form Master (Class Teacher) for a class's section(s)
  Future<void> assignFormMaster({
    required String classId,
    String? sectionId,
    required String? teacherId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.transaction(() async {
      final List<Section> targetSections;
      if (sectionId != null) {
        targetSections = await (db.select(db.sections)..where((t) => t.id.equals(sectionId))).get();
      } else {
        targetSections = await (db.select(db.sections)..where((t) => t.classId.equals(classId))).get();
      }

      for (final sec in targetSections) {
        final nextRev = sec.revision + 1;
        await (db.update(db.sections)..where((t) => t.id.equals(sec.id))).write(
          SectionsCompanion(
            teacherId: Value(teacherId),
            updatedAt: Value(now),
            revision: Value(nextRev),
          ),
        );

        await syncDao.enqueue(
          targetTable: 'sections',
          recordId: sec.id,
          operation: 'UPDATE',
          payloadJson: jsonEncode({
            'id': sec.id,
            'school_id': sec.schoolId,
            'class_id': sec.classId,
            'name': sec.name,
            'teacher_id': teacherId,
            'updated_at': now,
            'revision': nextRev,
          }),
          idempotencyKey: 'sec_fm_${sec.id}_v$nextRev',
          clientRevision: nextRev,
        );
      }
    });

    _triggerLiveSync();
  }

  // Teachers (PST / SPST) Management
  Future<List<User>> getTeachers(String schoolId) {
    return (db.select(db.users)
          ..where((t) => t.schoolId.equals(schoolId))
          ..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .get();
  }

  Future<User?> getTeacherById(String teacherId) {
    return (db.select(db.users)..where((t) => t.id.equals(teacherId))).getSingleOrNull();
  }

  Future<User> createTeacher({
    required String schoolId,
    required String name,
    required String email,
    required String phone,
    required String role, // 'teacher' | 'admin'
    required String pinCode,
    String? password,
    String? avatarUrl,
    String? cnic,
    String? designation,
    String? assignedClassId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = 'usr_${DateTime.now().microsecondsSinceEpoch}';
    final persistedAvatar = await CloudStorageService.instance.persistAndUploadPhoto(
      category: 'staff',
      entityId: id,
      sourcePath: avatarUrl,
    );

    final userCompanion = UsersCompanion.insert(
      id: id,
      schoolId: schoolId,
      name: name.trim(),
      email: Value(email.trim().toLowerCase()),
      phone: Value(phone.trim()),
      role: role,
      pinCodeHash: Value(pinCode.trim()),
      avatarUrl: Value(persistedAvatar),
      cnic: Value(cnic?.trim()),
      designation: Value(designation?.trim() ?? 'Primary School Teacher (PST)'),
      isActive: const Value(true),
      createdAt: now,
      updatedAt: now,
    );

    await db.into(db.users).insert(userCompanion);

    // If Form Master class assigned, link to sections
    if (assignedClassId != null && assignedClassId.isNotEmpty) {
      await assignFormMaster(classId: assignedClassId, teacherId: id);
    }

    // Enqueue mutation for Cloudflare D1 Sync
    await syncDao.enqueue(
      targetTable: 'users',
      recordId: id,
      operation: 'INSERT',
      payloadJson: jsonEncode({
        'id': id,
        'school_id': schoolId,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'role': role,
        'password_hash': (password != null && password.trim().isNotEmpty) ? password.trim() : 'Teacher@123',
        'pin_code_hash': pinCode.trim(),
        'avatar_url': persistedAvatar,
        'cnic': cnic?.trim(),
        'designation': designation?.trim() ?? 'Primary School Teacher (PST)',
        'is_active': 1,
        'created_at': now,
        'updated_at': now,
        'revision': 1,
      }),
      idempotencyKey: 'user_ins_${id}_$now',
    );

    final createdUser = await (db.select(db.users)..where((t) => t.id.equals(id))).getSingle();
    _triggerLiveSync();
    return createdUser;
  }

  Future<void> updateTeacher({
    required String teacherId,
    required String schoolId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? pinCode,
    String? avatarUrl,
    String? cnic,
    String? designation,
    bool? isActive,
    String? assignedClassId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final user = await (db.select(db.users)..where((t) => t.id.equals(teacherId))).getSingleOrNull();
    if (user == null) return;

    final persistedAvatar = avatarUrl != null
        ? await CloudStorageService.instance.persistAndUploadPhoto(
            category: 'staff',
            entityId: teacherId,
            sourcePath: avatarUrl,
          )
        : null;

    await (db.update(db.users)..where((t) => t.id.equals(teacherId))).write(
      UsersCompanion(
        name: name != null ? Value(name.trim()) : const Value.absent(),
        email: email != null ? Value(email.trim().toLowerCase()) : const Value.absent(),
        phone: phone != null ? Value(phone.trim()) : const Value.absent(),
        role: role != null ? Value(role) : const Value.absent(),
        pinCodeHash: pinCode != null ? Value(pinCode.trim()) : const Value.absent(),
        avatarUrl: persistedAvatar != null ? Value(persistedAvatar) : const Value.absent(),
        cnic: cnic != null ? Value(cnic.trim()) : const Value.absent(),
        designation: designation != null ? Value(designation.trim()) : const Value.absent(),
        isActive: isActive != null ? Value(isActive) : const Value.absent(),
        updatedAt: Value(now),
        revision: Value(user.revision + 1),
      ),
    );

    if (assignedClassId != null) {
      await assignFormMaster(classId: assignedClassId, teacherId: teacherId);
    }

    // Enqueue update into SyncQueue
    await syncDao.enqueue(
      targetTable: 'users',
      recordId: teacherId,
      operation: 'UPDATE',
      payloadJson: jsonEncode({
        'id': teacherId,
        'school_id': schoolId,
        'name': name?.trim() ?? user.name,
        'email': email?.trim().toLowerCase() ?? user.email,
        'phone': phone?.trim() ?? user.phone,
        'role': role ?? user.role,
        'pin_code_hash': pinCode?.trim() ?? user.pinCodeHash,
        'avatar_url': persistedAvatar ?? user.avatarUrl,
        'cnic': cnic?.trim() ?? user.cnic,
        'designation': designation?.trim() ?? user.designation,
        'is_active': (isActive ?? user.isActive) ? 1 : 0,
        'updated_at': now,
        'revision': user.revision + 1,
      }),
      idempotencyKey: 'user_upd_${teacherId}_$now',
    );

    _triggerLiveSync();
  }

  Future<void> updateTeacherAvatar({
    required String teacherId,
    required String schoolId,
    required String avatarUrl,
  }) async {
    await updateTeacher(
      teacherId: teacherId,
      schoolId: schoolId,
      avatarUrl: avatarUrl,
    );
  }
}
