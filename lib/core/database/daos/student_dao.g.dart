// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_dao.dart';

// ignore_for_file: type=lint
mixin _$StudentDaoMixin on DatabaseAccessor<AppDatabase> {
  $StudentsTable get students => attachedDatabase.students;
  $ParentContactsTable get parentContacts => attachedDatabase.parentContacts;
  $ClassesTable get classes => attachedDatabase.classes;
  $SectionsTable get sections => attachedDatabase.sections;
  $SchoolCalendarHolidaysTable get schoolCalendarHolidays =>
      attachedDatabase.schoolCalendarHolidays;
  StudentDaoManager get managers => StudentDaoManager(this);
}

class StudentDaoManager {
  final _$StudentDaoMixin _db;
  StudentDaoManager(this._db);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db.attachedDatabase, _db.students);
  $$ParentContactsTableTableManager get parentContacts =>
      $$ParentContactsTableTableManager(
        _db.attachedDatabase,
        _db.parentContacts,
      );
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db.attachedDatabase, _db.classes);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db.attachedDatabase, _db.sections);
  $$SchoolCalendarHolidaysTableTableManager get schoolCalendarHolidays =>
      $$SchoolCalendarHolidaysTableTableManager(
        _db.attachedDatabase,
        _db.schoolCalendarHolidays,
      );
}
