import 'package:drift/drift.dart';

/// Attendance Correction Request Model (Teacher -> Head Teacher Approval)
class CorrectionRequestModel {
  final String id;
  final String schoolId;
  final String attendanceRecordId;
  final String studentId;
  final String studentName;
  final String classId;
  final String sectionId;
  final String date;
  final String oldStatus;
  final String proposedStatus;
  final String reason;
  final String requestedByUserId;
  final String requestedByName;
  final String status; // 'pending' | 'approved' | 'rejected'
  final String? reviewedByUserId;
  final String? reviewRemarks;
  final int createdAt;
  final int updatedAt;
  final int revision;

  const CorrectionRequestModel({
    required this.id,
    required this.schoolId,
    required this.attendanceRecordId,
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.sectionId,
    required this.date,
    required this.oldStatus,
    required this.proposedStatus,
    required this.reason,
    required this.requestedByUserId,
    required this.requestedByName,
    required this.status,
    this.reviewedByUserId,
    this.reviewRemarks,
    required this.createdAt,
    required this.updatedAt,
    this.revision = 1,
  });

  factory CorrectionRequestModel.fromRow(QueryRow row) {
    return CorrectionRequestModel(
      id: row.readNullable<String>('id') ?? '',
      schoolId: row.readNullable<String>('school_id') ?? '',
      attendanceRecordId: row.readNullable<String>('attendance_record_id') ?? '',
      studentId: row.readNullable<String>('student_id') ?? '',
      studentName: row.readNullable<String>('student_name') ?? 'Student',
      classId: row.readNullable<String>('class_id') ?? '',
      sectionId: row.readNullable<String>('section_id') ?? '',
      date: row.readNullable<String>('date') ?? '',
      oldStatus: row.readNullable<String>('old_status') ?? '',
      proposedStatus: row.readNullable<String>('proposed_status') ?? '',
      reason: row.readNullable<String>('reason') ?? '',
      requestedByUserId: row.readNullable<String>('requested_by_user_id') ?? '',
      requestedByName: row.readNullable<String>('requested_by_name') ?? 'Teacher',
      status: row.readNullable<String>('status') ?? 'pending',
      reviewedByUserId: row.readNullable<String>('reviewed_by_user_id'),
      reviewRemarks: row.readNullable<String>('review_remarks'),
      createdAt: row.readNullable<int>('created_at') ?? 0,
      updatedAt: row.readNullable<int>('updated_at') ?? 0,
      revision: row.readNullable<int>('revision') ?? 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'school_id': schoolId,
        'attendance_record_id': attendanceRecordId,
        'student_id': studentId,
        'student_name': studentName,
        'class_id': classId,
        'section_id': sectionId,
        'date': date,
        'old_status': oldStatus,
        'proposed_status': proposedStatus,
        'reason': reason,
        'requested_by_user_id': requestedByUserId,
        'requested_by_name': requestedByName,
        'status': status,
        'reviewed_by_user_id': reviewedByUserId,
        'review_remarks': reviewRemarks,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'revision': revision,
      };
}
