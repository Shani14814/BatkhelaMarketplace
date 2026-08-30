import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized Typography supporting English and Urdu typography
class AppTypography {
  // English Base Font (Inter)
  static TextTheme get textTheme {
    return GoogleFonts.interTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
  }

  // Urdu Regional Font (Noto Nastaliq / Noto Sans Arabic)
  static TextStyle get urduHeading => GoogleFonts.notoNastaliqUrdu(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle get urduBody => GoogleFonts.notoNastaliqUrdu(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
