import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Use Inter from Google Fonts (closest to Geist)
  static TextStyle get primaryFont => GoogleFonts.inter();

  // Responsive font sizes
  static double get displayLargeFontSize => 32.sp;
  static double get displayMediumFontSize => 28.sp;
  static double get displaySmallFontSize => 24.sp;
  static double get headlineLargeFontSize => 24.sp;
  static double get headlineMediumFontSize => 20.sp;
  static double get headlineSmallFontSize => 18.sp;
  static double get titleLargeFontSize => 16.sp;
  static double get titleMediumFontSize => 14.sp;
  static double get titleSmallFontSize => 12.sp;
  static double get bodyLargeFontSize => 16.sp;
  static double get bodyMediumFontSize => 14.sp;
  static double get bodySmallFontSize => 12.sp;
  static double get labelLargeFontSize => 14.sp;
  static double get labelMediumFontSize => 12.sp;
  static double get labelSmallFontSize => 10.sp;

  // Responsive spacing
  static double get spacingXS => 4.w;
  static double get spacingS => 8.w;
  static double get spacingM => 16.w;
  static double get spacingL => 24.w;
  static double get spacingXL => 32.w;
  static double get spacingXXL => 48.w;

  // Responsive border radius
  static double get radiusXS => 4.r;
  static double get radiusS => 8.r;
  static double get radiusM => 12.r;
  static double get radiusL => 16.r;
  static double get radiusXL => 20.r;
  static double get radiusXXL => 28.r;
  static double get radiusCircle => 100.r;

  // Responsive heights
  static double get buttonHeightS => 40.h;
  static double get buttonHeightM => 48.h;
  static double get buttonHeightL => 56.h;

  // Icon sizes
  static double get iconXS => 16.sp;
  static double get iconS => 20.sp;
  static double get iconM => 24.sp;
  static double get iconL => 32.sp;
  static double get iconXL => 48.sp;
  static double get iconXXL => 64.sp;

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
          fontSize: displayLargeFontSize,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: displayMediumFontSize,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: displaySmallFontSize,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: headlineLargeFontSize,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: headlineMediumFontSize,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: headlineSmallFontSize,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: titleLargeFontSize,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: titleMediumFontSize,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: titleSmallFontSize,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: bodyLargeFontSize,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: bodyMediumFontSize,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: bodySmallFontSize,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: labelLargeFontSize,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: labelMediumFontSize,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: labelSmallFontSize,
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
          fontSize: displayLargeFontSize,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: GoogleFonts.inter(
          fontSize: displayMediumFontSize,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: GoogleFonts.inter(
          fontSize: displaySmallFontSize,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: GoogleFonts.inter(
          fontSize: headlineLargeFontSize,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: headlineMediumFontSize,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.inter(
          fontSize: headlineSmallFontSize,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: titleLargeFontSize,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: titleMediumFontSize,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: titleSmallFontSize,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: bodyLargeFontSize,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: bodyMediumFontSize,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: bodySmallFontSize,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: labelLargeFontSize,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: labelMediumFontSize,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: labelSmallFontSize,
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