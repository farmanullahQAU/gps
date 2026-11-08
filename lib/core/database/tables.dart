import 'package:drift/drift.dart';

// 1. Schools Table
class Schools extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get academicYearStart => text()(); // YYYY-MM-DD
  TextColumn get academicYearEnd => text()();   // YYYY-MM-DD
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Users Table
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get name => text()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get role => text()(); // 'admin' | 'teacher'
  TextColumn get pinCodeHash => text().nullable()();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get cnic => text().nullable()();
  TextColumn get designation => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 3. Classes Table
class Classes extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get name => text()(); // e.g. "Class 1"
  IntColumn get numericLevel => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 4. Sections Table
class Sections extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get classId => text()();
  TextColumn get name => text()(); // e.g. "Section A"
  TextColumn get teacherId => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 5. Students Table
class Students extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get classId => text()();
  TextColumn get sectionId => text()();
  TextColumn get admissionNumber => text()();
  TextColumn get rollNumber => text().nullable()();
  TextColumn get fullName => text()();
  TextColumn get fatherOrGuardianName => text()();
  TextColumn get gender => text()(); // 'male' | 'female' | 'other'
  TextColumn get dateOfBirth => text().nullable()();
  TextColumn get admissionDate => text()(); // YYYY-MM-DD
  TextColumn get status => text().withDefault(const Constant('active'))(); // active, transferred, graduated, inactive
  TextColumn get qrToken => text()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get studentCnic => text().nullable()(); // Student CNIC / Form-B (CNIC)
  TextColumn get fatherCnic => text().nullable()(); // Father CNIC (F_CNIC)
  BoolColumn get isVaccinated => boolean().withDefault(const Constant(false))(); // VACCINATED
  TextColumn get vaccineFirstDoseDate => text().nullable()(); // FIRST_DOSE (YYYY-MM-DD)
  TextColumn get vaccineSecondDoseDate => text().nullable()(); // SECOND_DOSE (YYYY-MM-DD)
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 6. Parent Contacts Table
class ParentContacts extends Table {
  TextColumn get id => text()();
  TextColumn get studentId => text()();
  TextColumn get relation => text()(); // 'father' | 'mother' | 'guardian'
  TextColumn get phoneNumber => text()();
  BoolColumn get whatsappEnabled => boolean().withDefault(const Constant(true))();
  BoolColumn get notifyAbsent => boolean().withDefault(const Constant(true))();
  BoolColumn get notifyLate => boolean().withDefault(const Constant(true))();
  BoolColumn get notifyLeave => boolean().withDefault(const Constant(true))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 7. School Calendar Holidays Table
class SchoolCalendarHolidays extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get description => text()();
  BoolColumn get isInstructionalDay => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 8. Attendance Records Table
class AttendanceRecords extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get studentId => text()();
  TextColumn get classId => text()();
  TextColumn get sectionId => text()();
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get status => text()(); // 'present' | 'absent' | 'late' | 'approved_leave' | 'half_day'
  TextColumn get arrivalTime => text().nullable()(); // HH:MM:SS
  TextColumn get departureTime => text().nullable()(); // HH:MM:SS
  TextColumn get remarks => text().nullable()();
  TextColumn get markedByUserId => text()();
  TextColumn get markingMethod => text()(); // 'manual' | 'qr_scan' | 'mark_all'
  TextColumn get idempotencyKey => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {studentId, date},
    {idempotencyKey},
  ];
}

// 9. Attendance Audit Log Table
class AttendanceAuditLogs extends Table {
  TextColumn get id => text()();
  TextColumn get attendanceRecordId => text()();
  TextColumn get changedByUserId => text()();
  TextColumn get oldStatus => text().nullable()();
  TextColumn get newStatus => text()();
  TextColumn get reason => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// 10. Local Sync Outbox Queue Table
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get targetTable => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // 'INSERT' | 'UPDATE' | 'DELETE'
  TextColumn get payloadJson => text()();
  TextColumn get idempotencyKey => text().unique()();
  IntColumn get clientRevision => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, in_progress, failed, synced
  TextColumn get errorMessage => text().nullable()();
}

// 11. School Settings Table
@DataClassName('SchoolSettingsEntry')
class SchoolSettings extends Table {
  TextColumn get schoolId => text()();
  TextColumn get schoolType => text().withDefault(const Constant('GPS'))();
  TextColumn get district => text().withDefault(const Constant('Peshawar'))();
  TextColumn get tehsil => text().withDefault(const Constant('City Peshawar'))();
  TextColumn get circleOffice => text().withDefault(const Constant('ASDEO Circle City-I'))();
  TextColumn get unionCouncil => text().withDefault(const Constant('UC-12'))();
  TextColumn get climateZone => text().withDefault(const Constant('summer_zone'))();
  TextColumn get openingTime => text().withDefault(const Constant('08:00'))();
  TextColumn get closingTime => text().withDefault(const Constant('13:30'))();
  TextColumn get lateCutoffTime => text().withDefault(const Constant('08:15'))();
  TextColumn get headTeacherName => text().withDefault(const Constant('Head Teacher'))();
  TextColumn get deoName => text().withDefault(const Constant('DEO Peshawar'))();
  TextColumn get circleSdeoName => text().withDefault(const Constant(''))();
  TextColumn get centerInchargeName => text().withDefault(const Constant(''))();
  TextColumn get goshwaraNo => text().withDefault(const Constant(''))();
  TextColumn get naConstituency => text().withDefault(const Constant(''))();
  TextColumn get pkConstituency => text().withDefault(const Constant(''))();
  TextColumn get ltrcCenter => text().withDefault(const Constant(''))();
  IntColumn get sanctionedPostsPsht => integer().withDefault(const Constant(1))();
  IntColumn get sanctionedPostsSpst => integer().withDefault(const Constant(4))();
  IntColumn get sanctionedPostsPst => integer().withDefault(const Constant(4))();
  IntColumn get vacantPostsPst => integer().withDefault(const Constant(0))();
  IntColumn get vacantPostsChowkidar => integer().withDefault(const Constant(0))();
  IntColumn get classroomsInstructional => integer().withDefault(const Constant(3))();
  IntColumn get classroomsNonInstructional => integer().withDefault(const Constant(0))();
  TextColumn get establishmentYear => text().withDefault(const Constant(''))();
  TextColumn get constructionYear => text().withDefault(const Constant(''))();
  IntColumn get facilityElectricity => integer().withDefault(const Constant(1))();
  IntColumn get facilityWaterPipe => integer().withDefault(const Constant(1))();
  IntColumn get facilityWaterWell => integer().withDefault(const Constant(0))();
  IntColumn get facilitySolar => integer().withDefault(const Constant(1))();
  IntColumn get facilityBoundaryWall => integer().withDefault(const Constant(1))();
  IntColumn get facilityPlayArea => integer().withDefault(const Constant(0))();
  IntColumn get facilityOffice => integer().withDefault(const Constant(1))();
  IntColumn get facilityToiletCount => integer().withDefault(const Constant(2))();
  TextColumn get ptcChairmanName => text().withDefault(const Constant(''))();
  TextColumn get ptcBankName => text().withDefault(const Constant(''))();
  TextColumn get ptcAccountNo => text().withDefault(const Constant(''))();
  TextColumn get ptcSanctionDate => text().withDefault(const Constant(''))();
  RealColumn get fundTotalBudget => real().withDefault(const Constant(0.0))();
  RealColumn get fundTotalSpent => real().withDefault(const Constant(0.0))();
  TextColumn get workingDaysCsv => text().withDefault(const Constant('1,2,3,4,5,6'))();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {schoolId};
}

// 12. Student Extended Info Table
@DataClassName('StudentExtendedInfoEntry')
class StudentExtendedInfo extends Table {
  TextColumn get studentId => text()();
  TextColumn get studentBForm => text().nullable()();
  TextColumn get fatherCnic => text().nullable()();
  TextColumn get motherName => text().nullable()();
  TextColumn get domicileDistrict => text().nullable()();
  TextColumn get leavingDate => text().nullable()();
  TextColumn get leavingReason => text().nullable()();
  TextColumn get slcNumber => text().nullable()();
  IntColumn get freeBooksIssued => integer().withDefault(const Constant(1))();
  IntColumn get isVaccinated => integer().withDefault(const Constant(0))();
  TextColumn get vaccineFirstDoseDate => text().nullable()();
  TextColumn get vaccineSecondDoseDate => text().nullable()();
  TextColumn get previousQrTokensJson => text().withDefault(const Constant('[]'))();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {studentId};
}

// 13. Attendance Sessions Table
@DataClassName('AttendanceSessionEntry')
class AttendanceSessions extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get classId => text()();
  TextColumn get sectionId => text()();
  TextColumn get date => text()();
  TextColumn get status => text().withDefault(const Constant('draft'))();
  TextColumn get finalizedByUserId => text().nullable()();
  IntColumn get finalizedAt => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {sectionId, date},
  ];
}

// 14. Correction Requests Table
@DataClassName('CorrectionRequestEntry')
class CorrectionRequests extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text()();
  TextColumn get attendanceRecordId => text()();
  TextColumn get studentId => text()();
  TextColumn get studentName => text().nullable()();
  TextColumn get classId => text()();
  TextColumn get sectionId => text()();
  TextColumn get date => text()();
  TextColumn get oldStatus => text()();
  TextColumn get proposedStatus => text()();
  TextColumn get reason => text()();
  TextColumn get requestedByUserId => text()();
  TextColumn get requestedByName => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get reviewedByUserId => text().nullable()();
  TextColumn get reviewRemarks => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

// 15. Sync Conflicts Table
@DataClassName('SyncConflictEntry')
class SyncConflicts extends Table {
  TextColumn get id => text()();
  TextColumn get schoolId => text().nullable()();
  TextColumn get recordId => text()();
  TextColumn get targetTableName => text().named('table_name')();
  TextColumn get studentId => text()();
  TextColumn get date => text()();
  TextColumn get localStatus => text()();
  TextColumn get serverStatus => text()();
  TextColumn get conflictReason => text()();
  TextColumn get status => text().withDefault(const Constant('unresolved'))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// 16. Teacher Goshwara Profiles Table
@DataClassName('TeacherGoshwaraProfileEntry')
class TeacherGoshwaraProfiles extends Table {
  TextColumn get userId => text()();
  TextColumn get fatherName => text().withDefault(const Constant(''))();
  TextColumn get personalNo => text().withDefault(const Constant(''))();
  TextColumn get dob => text().withDefault(const Constant(''))();
  TextColumn get academicQualification => text().withDefault(const Constant(''))();
  TextColumn get professionalQualification => text().withDefault(const Constant(''))();
  TextColumn get appointmentDate => text().withDefault(const Constant(''))();
  TextColumn get transferInDate => text().withDefault(const Constant(''))();
  TextColumn get currentBps => text().withDefault(const Constant(''))();
  TextColumn get bpsAwardDate => text().withDefault(const Constant(''))();
  RealColumn get basicPay => real().withDefault(const Constant(0.0))();
  TextColumn get village => text().withDefault(const Constant(''))();
  TextColumn get unionCouncil => text().withDefault(const Constant(''))();
  TextColumn get district => text().withDefault(const Constant(''))();
  TextColumn get employmentType => text().withDefault(const Constant('permanent'))();
  IntColumn get updatedAt => integer().withDefault(const Constant(0))();
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {userId};
}
