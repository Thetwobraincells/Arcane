import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ArcaneTheme {
  // Medical Color Palette
  static const Color primaryBlue = Color(0xFF0EA5E9); // Medical blue
  static const Color lightBackground = Color(0xFFF8FAFC); // Light gray-blue
  static const Color cardBackground = Color(0xFFFFFFFF); // White
  static const Color textPrimary = Color(0xFF1E293B); // Dark slate
  static const Color textSecondary = Color(0xFF64748B); // Gray
  static const Color successGreen = Color(0xFF10B981); // Success
  static const Color warningOrange = Color(0xFFF59E0B); // Warning
  static const Color errorRed = Color(0xFFEF4444); // Error
  static const Color borderColor = Color(0xFFE2E8F0); // Light border

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: primaryBlue,
        secondary: Color(0xFF8B5CF6), // Purple accent
        tertiary: successGreen,
        surface: cardBackground,
        background: lightBackground,
        error: errorRed,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: cardBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
      ),
    );
  }
}