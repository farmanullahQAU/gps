import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class IdempotencyUtil {
  static final Random _secureRandom = Random.secure();

  /// Generates a deterministic idempotency key for attendance records
  /// Format: `att_<studentId>_<date>`
  static String forAttendance(String studentId, String date) {
    return 'att_${studentId}_$date';
  }

  /// Generates a deterministic idempotency key for an attendance session
  /// Format: `ses_<sectionId>_<date>`
  static String forSession(String sectionId, String date) {
    return 'ses_${sectionId}_$date';
  }

  /// Generates a deterministic idempotency key for a student mutation
  static String forStudent(String studentId, int revision) {
    return 'std_${studentId}_v$revision';
  }

  /// Generates a cryptographically random, opaque QR credential token
  /// Does not embed student name, phone, CNIC, or predictable sequential IDs.
  static String generateOpaqueQrToken() {
    final randomBytes = List<int>.generate(12, (_) => _secureRandom.nextInt(256));
    final hex = randomBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
    return 'KPK_QR_${hex.substring(0, 8)}_${hex.substring(8, 16)}_${hex.substring(16, 24)}';
  }

  /// Generates a unique key for arbitrary operations
  static String generate(String prefix) {
    final nonce = _secureRandom.nextInt(1 << 30);
    final bytes = utf8.encode('$prefix-${DateTime.now().microsecondsSinceEpoch}-$nonce');
    final digest = sha256.convert(bytes).toString().substring(0, 16);
    return '${prefix}_$digest';
  }
}
