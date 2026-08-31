import 'package:flutter/material.dart';

/// Google Stitch Design Tokens for Batkhela Marketplace
///
/// Visual Direction:
/// - Primary: Deep Teal (#006D77)
/// - Indigo Accent: (#5354C7)
/// - Warm Coral Accent: (#FE7766)
/// - Soft Cyan: (#9FF0FB)
/// - Background: Soft Lilac (#F3F2FF)
class AppColors {
  // Primary Brand Colors (Deep Teal)
  static const Color primary = Color(0xFF006D77);
  static const Color primaryLight = Color(0xFFE0F7F6);
  static const Color primaryDark = Color(0xFF004D53);

  // Indigo Accent (Secondary Brand Color)
  static const Color indigo = Color(0xFF5354C7);
  static const Color indigoLight = Color(0xFFEEF0FF);
  static const Color secondary = indigo;
  static const Color secondaryLight = indigoLight;
  static const Color secondaryDark = Color(0xFF3E3FA6);

  // Warm Coral Accent
  static const Color coral = Color(0xFFFE7766);
  static const Color coralLight = Color(0xFFFFECE9);
  static const Color accentCoral = coral;

  // Soft Cyan Accent
  static const Color softCyan = Color(0xFF9FF0FB);
  static const Color softCyanLight = Color(0xFFE6FCFF);
  static const Color accentCyan = softCyan;

  // Background & Surface (Soft Lilac foundation)
  static const Color backgroundLight = Color(0xFFF3F2FF);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceContainerLight = Color(0xFFFAF9FF);
  static const Color backgroundDark = Color(0xFF0D131A);
  static const Color surfaceDark = Color(0xFF1B2430);
  static const Color surfaceContainerDark = Color(0xFF242F3D);

  // Text & Typography
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textInverse = Colors.white;

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);

  // Semantic Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF006D77);
  static const Color infoLight = Color(0xFFE0F7F6);

  // Role Badge Accents (Stitch Palette)
  static const Color customerBadge = Color(0xFF006D77);
  static const Color vendorBadge = Color(0xFF5354C7);
  static const Color riderBadge = Color(0xFFFE7766);
  static const Color adminBadge = Color(0xFF004D53);
}
