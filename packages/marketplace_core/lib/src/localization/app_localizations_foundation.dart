import 'package:flutter/material.dart';

/// Localization Foundation for English and Urdu (with RTL support)
class AppLocalizationFoundation {
  static const List<Locale> supportedLocales = [
    Locale('en', 'US'), // English
    Locale('ur', 'PK'), // Urdu
  ];

  static const Locale defaultLocale = Locale('en', 'US');

  /// Check if the current locale is RTL (Right-to-Left)
  static bool isRtl(Locale locale) {
    return locale.languageCode == 'ur' || locale.languageCode == 'ar';
  }

  /// Text direction for given locale
  static TextDirection textDirectionFor(Locale locale) {
    return isRtl(locale) ? TextDirection.rtl : TextDirection.ltr;
  }
}
