import 'package:flutter/material.dart';

/// Elevation & Shadow Rules for Soft & Premium UI
class AppElevation {
  static const List<BoxShadow> softSubtle = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> softCard = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> premiumElevated = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
