import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../database/app_database.dart';
import '../theme/app_theme.dart';

/// Offline-First Local Database Snapshot Backup & Restore Service
///
/// Designed for remote KPK Government Primary Schools where cellular coverage
/// may be unavailable for weeks:
/// - Exports a complete, verified JSON + SQLite snapshot of all school tables
///   (Schools, Users, Classes, Sections, Students, ParentContacts, Holidays,
///   AttendanceRecords) to permanent local storage (`<appDocumentsDir>/gps_backups/`).
/// - Allows restoring from any saved local snapshot or picking an external `.json`
///   backup file from device storage.
class DatabaseBackupService {
  DatabaseBackupService._();
  static final DatabaseBackupService instance = DatabaseBackupService._();

  Future<Directory> _getBackupsDir() async {
    Directory root;
    try {
      root = await getApplicationDocumentsDirectory();
    } catch (_) {
      root = Directory.systemTemp;
    }
    final dir = Directory(p.join(root.path, 'gps_backups'));
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Creates a complete JSON snapshot of the local Drift database for [schoolId]
  Future<({File file, int studentCount, int attendanceCount})> createSnapshotBackup(
    AppDatabase db, {
    String? schoolId,
  }) async {
    final schools = await db.select(db.schools).get();
    final users = await db.select(db.users).get();
    final classes = await db.select(db.classes).get();
    final sections = await db.select(db.sections).get();
    final students = await db.select(db.students).get();
    final parents = await db.select(db.parentContacts).get();
    final holidays = await db.select(db.schoolCalendarHolidays).get();
    final records = await db.select(db.attendanceRecords).get();

    final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final payload = {
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'schoolId': schoolId ?? (schools.isNotEmpty ? schools.first.id : 'all'),
      'counts': {
        'schools': schools.length,
        'users': users.length,
        'classes': classes.length,
        'sections': sections.length,
        'students': students.length,
        'parentContacts': parents.length,
        'holidays': holidays.length,
        'attendanceRecords': records.length,
      },
      'data': {
        'schools': schools.map((e) => e.toJson()).toList(),
        'users': users.map((e) => e.toJson()).toList(),
        'classes': classes.map((e) => e.toJson()).toList(),
        'sections': sections.map((e) => e.toJson()).toList(),
        'students': students.map((e) => e.toJson()).toList(),
        'parentContacts': parents.map((e) => e.toJson()).toList(),
        'holidays': holidays.map((e) => e.toJson()).toList(),
        'attendanceRecords': records.map((e) => e.toJson()).toList(),
      },
    };

    final dir = await _getBackupsDir();
    final filename = 'gps_kpk_backup_$timestampStr.json';
    final file = File(p.join(dir.path, filename));
    final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
    await file.writeAsString(jsonString, flush: true);

    return (
      file: file,
      studentCount: students.length,
      attendanceCount: records.length,
    );
  }

  /// Lists all locally stored backup snapshots ordered newest first
  Future<List<File>> listLocalBackups() async {
    final dir = await _getBackupsDir();
    if (!dir.existsSync()) return [];
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }

  /// Restores database records from a JSON backup snapshot idempotently
  Future<({int studentsRestored, int recordsRestored})> restoreFromJsonString(
    AppDatabase db,
    String jsonContent,
  ) async {
    final decoded = jsonDecode(jsonContent) as Map<String, dynamic>;
    final data = decoded['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid backup file format: missing data section.');
    }

    int studentsRestored = 0;
    int recordsRestored = 0;

    await db.transaction(() async {
      for (final raw in (data['schools'] as List<dynamic>? ?? [])) {
        final item = School.fromJson(Map<String, dynamic>.from(raw as Map));
        await db.into(db.schools).insertOnConflictUpdate(item);
      }
      for (final raw in (data['users'] as List<dynamic>? ?? [])) {
        final item = User.fromJson(Map<String, dynamic>.from(raw as Map));
        await db.into(db.users).insertOnConflictUpdate(item);
      }
      for (final raw in (data['classes'] as List<dynamic>? ?? [])) {
        final item = ClassesData.fromJson(Map<String, dynamic>.from(raw as Map));
        await db.into(db.classes).insertOnConflictUpdate(item);
      }
      for (final raw in (data['sections'] as List<dynamic>? ?? [])) {
        final item = Section.fromJson(Map<String, dynamic>.from(raw as Map));
        await db.into(db.sections).insertOnConflictUpdate(item);
      }
      for (final raw in (data['students'] as List<dynamic>? ?? [])) {
        final item = Student.fromJson(Map<String, dynamic>.from(raw as Map));
        await db.into(db.students).insertOnConflictUpdate(item);
        studentsRestored++;
      }
      for (final raw in (data['parentContacts'] as List<dynamic>? ?? [])) {
        final item = ParentContact.fromJson(Map<String, dynamic>.from(raw as Map));
        await db.into(db.parentContacts).insertOnConflictUpdate(item);
      }
      for (final raw in (data['holidays'] as List<dynamic>? ?? [])) {
        final item = SchoolCalendarHoliday.fromJson(Map<String, dynamic>.from(raw as Map));
        await db.into(db.schoolCalendarHolidays).insertOnConflictUpdate(item);
      }
      for (final raw in (data['attendanceRecords'] as List<dynamic>? ?? [])) {
        final item = AttendanceRecord.fromJson(Map<String, dynamic>.from(raw as Map));
        await db.into(db.attendanceRecords).insertOnConflictUpdate(item);
        recordsRestored++;
      }
    });

    return (studentsRestored: studentsRestored, recordsRestored: recordsRestored);
  }

  /// Opens an interactive Backup & Restore bottom sheet modal
  Future<void> showBackupRestoreModal(
    BuildContext context, {
    required AppDatabase db,
    String? schoolId,
    VoidCallback? onRestored,
  }) async {
    final backups = await listLocalBackups();
    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        List<File> currentBackups = List.from(backups);
        bool isBusy = false;

        return StatefulBuilder(
          builder: (context, setModalState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.backup_rounded, color: AppColors.primaryDark, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Offline Database Backup & Restore',
                              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            Text(
                              'Save full school register snapshots to device storage',
                              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Icon(Icons.save_alt_rounded, size: 18),
                          label: const Text('Create Snapshot Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                          onPressed: isBusy
                              ? null
                              : () async {
                                  setModalState(() => isBusy = true);
                                  try {
                                    final snap = await createSnapshotBackup(db, schoolId: schoolId);
                                    final content = await snap.file.readAsString();
                                    await Clipboard.setData(ClipboardData(text: content));
                                    currentBackups = await listLocalBackups();
                                    Get.snackbar(
                                      'Backup Snapshot Created',
                                      'Saved ${p.basename(snap.file.path)} (${snap.studentCount} students, ${snap.attendanceCount} attendance records).',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFDCFCE7),
                                      colorText: const Color(0xFF166534),
                                    );
                                  } catch (e) {
                                    Get.snackbar('Backup Failed', '$e', snackPosition: SnackPosition.BOTTOM);
                                  } finally {
                                    setModalState(() => isBusy = false);
                                  }
                                },
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryDark,
                          side: const BorderSide(color: AppColors.primaryDark, width: 1.3),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.folder_open_rounded, size: 18),
                        label: const Text('Import File', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                        onPressed: isBusy
                            ? null
                            : () async {
                                try {
                                  final picked = await FilePicker.pickFile(
                                    type: FileType.custom,
                                    allowedExtensions: ['json'],
                                  );
                                  if (picked != null && picked.path != null) {
                                    setModalState(() => isBusy = true);
                                    final file = File(picked.path!);
                                    final content = await file.readAsString();
                                    final stats = await restoreFromJsonString(db, content);
                                    onRestored?.call();
                                    if (ctx.mounted) Navigator.pop(ctx);
                                    Get.snackbar(
                                      'Database Restored Successfully',
                                      'Restored ${stats.studentsRestored} students and ${stats.recordsRestored} attendance records.',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: const Color(0xFFDCFCE7),
                                      colorText: const Color(0xFF166534),
                                    );
                                  }
                                } catch (e) {
                                  Get.snackbar('Restore Error', '$e', snackPosition: SnackPosition.BOTTOM);
                                } finally {
                                  setModalState(() => isBusy = false);
                                }
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SAVED SNAPSHOTS ON THIS DEVICE (${currentBackups.length})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  if (currentBackups.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.bgLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Text(
                        'No local snapshots yet. Tap "Create Snapshot Now" to save a full offline backup.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: currentBackups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 6),
                        itemBuilder: (_, idx) {
                          final f = currentBackups[idx];
                          final name = p.basename(f.path);
                          final modified = DateFormat('dd MMM yyyy, hh:mm a').format(f.lastModifiedSync());
                          final sizeKb = (f.lengthSync() / 1024).toStringAsFixed(1);

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.bgLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.description_outlined, color: AppColors.primaryDark, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                      ),
                                      Text(
                                        '$modified • $sizeKb KB',
                                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: isBusy
                                      ? null
                                      : () async {
                                          setModalState(() => isBusy = true);
                                          try {
                                            final content = await f.readAsString();
                                            final stats = await restoreFromJsonString(db, content);
                                            onRestored?.call();
                                            if (ctx.mounted) Navigator.pop(ctx);
                                            Get.snackbar(
                                              'Snapshot Restored',
                                              'Restored ${stats.studentsRestored} students & ${stats.recordsRestored} attendance records.',
                                              snackPosition: SnackPosition.BOTTOM,
                                              backgroundColor: const Color(0xFFDCFCE7),
                                              colorText: const Color(0xFF166534),
                                            );
                                          } catch (e) {
                                            Get.snackbar('Restore Failed', '$e', snackPosition: SnackPosition.BOTTOM);
                                          } finally {
                                            setModalState(() => isBusy = false);
                                          }
                                        },
                                  child: const Text('Restore', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
