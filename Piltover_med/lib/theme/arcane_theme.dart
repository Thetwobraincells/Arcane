import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class ArcaneTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(AppConstants.hextechBlue),
      scaffoldBackgroundColor: const Color(AppConstants.darkBackground),
      colorScheme: const ColorScheme.dark(
        primary: Color(AppConstants.hextechBlue),
        secondary: Color(AppConstants.hextechGold),
        tertiary: Color(AppConstants.arcanePurple),
        surface: Color(0xFF1A1F3A),
        background: Color(AppConstants.darkBackground),
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: const Color(AppConstants.hextechBlue),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1F3A),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

