import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../theme/app_theme.dart';

/// Manages customizable WhatsApp parent notification templates (Absent, Late, Low Attendance)
/// and launches WhatsApp directly to the student's parent/guardian phone number.
class WhatsAppHelper {
  static const MethodChannel _channel = MethodChannel('com.school.gps/launcher');

  static const String _prefKeyAbsent = 'wa_tpl_absent_v1';
  static const String _prefKeyLate = 'wa_tpl_late_v1';
  static const String _prefKeyChronic = 'wa_tpl_chronic_v1';

  static const String defaultAbsentTemplate =
      'Assalam-o-Alaikum {father_name},\n'
      'This is to inform you that your child *{student_name}* (Roll No: {roll_no}, {class_name}) '
      'is marked *ABSENT* today ({date}) at {school_name}.\n'
      'براہ کرم بچے کی غیر حاضری کی وجہ سے سکول کو آگاہ کریں۔ شکریہ۔';

  static const String defaultLateTemplate =
      'Assalam-o-Alaikum {father_name},\n'
      'Your child *{student_name}* (Roll No: {roll_no}, {class_name}) arrived *LATE* today ({date}) '
      'at {school_name}.\n'
      'براہ کرم بچے کی وقت پر سکول آمد کو یقینی بنائیں۔ شکریہ۔';

  static const String defaultChronicTemplate =
      'Assalam-o-Alaikum {father_name},\n'
      'Attendance Alert for *{student_name}* (Roll No: {roll_no}, {class_name}):\n'
      '• Absent Days: *{absent_days}*\n'
      '• Attendance Rate: *{attendance_pct}%*\n'
      'Regular school attendance is mandatory under KPK E&SED policy. Please ensure daily attendance.\n'
      '— {school_name}';

  /// Normalizes a Pakistani phone number (e.g. `0333-9112233` -> `923339112233`) for `wa.me`.
  static String normalizePhoneForWhatsApp(String rawPhone) {
    String digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    } else if (digits.startsWith('0') && digits.length == 11) {
      digits = '92${digits.substring(1)}';
    } else if (digits.length == 10 && digits.startsWith('3')) {
      digits = '92$digits';
    }
    return digits;
  }

  static Future<String> getTemplate(String type) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case 'late':
        return prefs.getString(_prefKeyLate) ?? defaultLateTemplate;
      case 'chronic':
        return prefs.getString(_prefKeyChronic) ?? defaultChronicTemplate;
      case 'absent':
      default:
        return prefs.getString(_prefKeyAbsent) ?? defaultAbsentTemplate;
    }
  }

  static Future<void> saveTemplate(String type, String template) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case 'late':
        await prefs.setString(_prefKeyLate, template);
        break;
      case 'chronic':
        await prefs.setString(_prefKeyChronic, template);
        break;
      case 'absent':
      default:
        await prefs.setString(_prefKeyAbsent, template);
        break;
    }
  }

  static Future<void> resetTemplatesToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyAbsent);
    await prefs.remove(_prefKeyLate);
    await prefs.remove(_prefKeyChronic);
  }

  static String renderTemplate(
    String rawTemplate, {
    required Student student,
    required String className,
    required String schoolName,
    String? dateStr,
    int? absentDays,
    String? attendancePct,
  }) {
    final date = dateStr ?? DateFormat('dd MMM yyyy').format(DateTime.now());
    return rawTemplate
        .replaceAll('{student_name}', student.fullName)
        .replaceAll('{father_name}', student.fatherOrGuardianName)
        .replaceAll('{roll_no}', student.rollNumber ?? '-')
        .replaceAll('{adm_no}', student.admissionNumber)
        .replaceAll('{class_name}', className)
        .replaceAll('{school_name}', schoolName)
        .replaceAll('{date}', date)
        .replaceAll('{absent_days}', (absentDays ?? 1).toString())
        .replaceAll('{attendance_pct}', attendancePct ?? '0.0');
  }

  /// Launches WhatsApp with the given phone number and pre-filled text.
  static Future<void> launchWhatsApp({
    required String phone,
    required String message,
  }) async {
    final normalized = normalizePhoneForWhatsApp(phone);
    if (normalized.length < 10) {
      Get.snackbar(
        'Invalid Phone Number',
        'Please enter a valid mobile / WhatsApp number (e.g. +923331234567).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.absent,
        colorText: Colors.white,
      );
      return;
    }

    await Clipboard.setData(ClipboardData(text: message));

    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('openWhatsApp', {
          'phone': normalized,
          'text': message,
        });
        return;
      } else if (Platform.isLinux) {
        final uri = 'https://wa.me/$normalized?text=${Uri.encodeComponent(message)}';
        await Process.run('xdg-open', [uri]);
        return;
      }
    } catch (_) {
      // Fallback notification below
    }

    Get.snackbar(
      'Message Copied for WhatsApp',
      'Prepared WhatsApp message for +$normalized (copied to clipboard).',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF166534),
      colorText: Colors.white,
    );
  }
}
