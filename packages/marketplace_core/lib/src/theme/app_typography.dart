import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized Typography supporting English (Plus Jakarta Sans + Inter) and Urdu (Noto Nastaliq Urdu)
class AppTypography {
  /// Base TextTheme: Plus Jakarta Sans for Display/Headline/Title and Inter for Body/Label
  static TextTheme get textTheme {
    final baseInter = GoogleFonts.interTextTheme();
    final headlineTheme = GoogleFonts.plusJakartaSansTextTheme();

    return baseInter.copyWith(
      displayLarge: headlineTheme.displayLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      displayMedium: headlineTheme.displayMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      displaySmall: headlineTheme.displaySmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: headlineTheme.headlineLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: headlineTheme.headlineMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: headlineTheme.headlineSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: headlineTheme.titleLarge?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: headlineTheme.titleMedium?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: headlineTheme.titleSmall?.copyWith(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: baseInter.bodyLarge?.copyWith(
        color: AppColors.textPrimary,
      ),
      bodyMedium: baseInter.bodyMedium?.copyWith(
        color: AppColors.textSecondary,
      ),
      bodySmall: baseInter.bodySmall?.copyWith(
        color: AppColors.textTertiary,
      ),
      labelLarge: baseInter.labelLarge?.copyWith(
        fontWeight: FontWeight.w600,
      ),
      labelMedium: baseInter.labelMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      labelSmall: baseInter.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // Headline Style (Plus Jakarta Sans)
  static TextStyle headline({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );

  // Body Style (Inter)
  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );

  // Urdu Regional Font (Noto Nastaliq Urdu)
  static TextStyle urduHeading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.bold,
    Color color = AppColors.textPrimary,
  }) => GoogleFonts.notoNastaliqUrdu(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );

  static TextStyle urduBody({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textSecondary,
  }) => GoogleFonts.notoNastaliqUrdu(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}
