import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Pakistani School Emerald & Forest Green
  static const Color primaryDark = Color(0xFF0F5132);    // Deep Forest Green
  static const Color primary = Color(0xFF198754);        // Pakistani National Green
  static const Color primaryLight = Color(0xFFE8F5E9);   // Mint Soft Tint
  static const Color primaryAccent = Color(0xFF20C997);  // Bright Jade Accent

  // Secondary & Accents
  static const Color secondary = Color(0xFF0D6EFD);      // Formal Blue
  static const Color secondaryLight = Color(0xFFE7F1FF);

  // Attendance Status Colors
  static const Color present = Color(0xFF10B981);        // Vibrant Emerald Green
  static const Color presentBg = Color(0xFFDCFCE7);

  static const Color absent = Color(0xFFEF4444);         // Vibrant Coral Red
  static const Color absentBg = Color(0xFFFEE2E2);

  static const Color late = Color(0xFFF59E0B);           // Warm Amber/Gold
  static const Color lateBg = Color(0xFFFEF3C7);

  static const Color leave = Color(0xFF0284C7);          // Sky Blue
  static const Color leaveBg = Color(0xFFE0F2FE);

  static const Color halfDay = Color(0xFFEA580C);        // Deep Orange
  static const Color halfDayBg = Color(0xFFFFEDD5);

  static const Color unmarked = Color(0xFF64748B);       // Slate Grey
  static const Color unmarkedBg = Color(0xFFF1F5F9);

  // Surface & Neutrals
  static const Color bgDark = Color(0xFF0B1320);
  static const Color bgLight = Color(0xFFF4F7F9);        // Soft Native Android Surface Tint
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A);    // Dark Slate
  static const Color textSecondary = Color(0xFF475569);  // Muted Slate
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color border = Color(0xFFE2E8F0);
  static const Color cardShadow = Color(0x0A000000);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.1,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 66,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryLight,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryDark,
            );
          }
          return const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primary, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
        ),
      ),
    );
  }
}
