import 'package:drift/drift.dart';

/// Daily Attendance Session Model (`draft` vs `finalized`)
class AttendanceSessionModel {
  final String id;
  final String schoolId;
  final String classId;
  final String sectionId;
  final String date; // YYYY-MM-DD
  final String status; // 'draft' | 'finalized'
  final String? finalizedByUserId;
  final int? finalizedAt;
  final String? notes;
  final int updatedAt;
  final int revision;

  const AttendanceSessionModel({
    required this.id,
    required this.schoolId,
    required this.classId,
    required this.sectionId,
    required this.date,
    required this.status,
    this.finalizedByUserId,
    this.finalizedAt,
    this.notes,
    required this.updatedAt,
    this.revision = 1,
  });

  bool get isFinalized => status == 'finalized';

  factory AttendanceSessionModel.fromRow(QueryRow row) {
    return AttendanceSessionModel(
      id: row.readNullable<String>('id') ?? '',
      schoolId: row.readNullable<String>('school_id') ?? '',
      classId: row.readNullable<String>('class_id') ?? '',
      sectionId: row.readNullable<String>('section_id') ?? '',
      date: row.readNullable<String>('date') ?? '',
      status: row.readNullable<String>('status') ?? 'draft',
      finalizedByUserId: row.readNullable<String>('finalized_by_user_id'),
      finalizedAt: row.readNullable<int>('finalized_at'),
      notes: row.readNullable<String>('notes'),
      updatedAt: row.readNullable<int>('updated_at') ?? 0,
      revision: row.readNullable<int>('revision') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'class_id': classId,
        'section_id': sectionId,
        'date': date,
        'status': status,
        'finalized_by_user_id': finalizedByUserId,
        'finalized_at': finalizedAt,
        'notes': notes,
        'updated_at': updatedAt,
        'revision': revision,
      };
}
