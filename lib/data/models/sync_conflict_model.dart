import 'package:drift/drift.dart';

/// Sync Conflict Record Model (Audit trail for multi-device concurrent conflicts)
class SyncConflictModel {
  final String id;
  final String recordId;
  final String tableName;
  final String studentId;
  final String date;
  final String localStatus;
  final String serverStatus;
  final String conflictReason;
  final String status; // 'unresolved' | 'resolved_keep_local' | 'resolved_accept_server'
  final int createdAt;

  const SyncConflictModel({
    required this.id,
    required this.recordId,
    required this.tableName,
    required this.studentId,
    required this.date,
    required this.localStatus,
    required this.serverStatus,
    required this.conflictReason,
    required this.status,
    required this.createdAt,
  });

  factory SyncConflictModel.fromRow(QueryRow row) {
    return SyncConflictModel(
      id: row.readNullable<String>('id') ?? '',
      recordId: row.readNullable<String>('record_id') ?? '',
      tableName: row.readNullable<String>('table_name') ?? '',
      studentId: row.readNullable<String>('student_id') ?? '',
      date: row.readNullable<String>('date') ?? '',
      localStatus: row.readNullable<String>('local_status') ?? '',
      serverStatus: row.readNullable<String>('server_status') ?? '',
      conflictReason: row.readNullable<String>('conflict_reason') ?? '',
      status: row.readNullable<String>('status') ?? 'unresolved',
      createdAt: row.readNullable<int>('created_at') ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'record_id': recordId,
        'table_name': tableName,
        'student_id': studentId,
        'date': date,
        'local_status': localStatus,
        'server_status': serverStatus,
        'conflict_reason': conflictReason,
        'status': status,
        'created_at': createdAt,
      };
}
