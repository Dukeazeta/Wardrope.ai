import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Use Inter from Google Fonts (closest to Geist)
  static TextStyle get primaryFont => GoogleFonts.inter();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.black,
        brightness: Brightness.light,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.white,
        brightness: Brightness.dark,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.inter(
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}