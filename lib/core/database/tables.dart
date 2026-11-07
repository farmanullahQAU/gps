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
