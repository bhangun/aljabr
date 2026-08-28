import 'package:flutter/material.dart';

/// Centralized color tokens so every widget pulls from one dark IDE palette
/// instead of hardcoding hex values everywhere.
class AppTheme {
  AppTheme._();

  static const background = Color(0xFF161616);
  static const panel = Color(0xFF1B1B1B);
  static const panelAlt = Color(0xFF1E1E1E);
  static const sidebarSelected = Color(0xFF2A2A2A);
  static const border = Color(0xFF2C2C2C);
  static const chip = Color(0xFF2A2A2A);

  static const textPrimary = Color(0xFFECECEC);
  static const textSecondary = Color(0xFF9B9B9B);
  static const textMuted = Color(0xFF6E6E6E);

  static const accentBlue = Color(0xFF4C8DFF);
  static const accentGreen = Color(0xFF34C759);
  static const accentAmber = Color(0xFFE0A94C);

  // Code editor syntax accents
  static const codeComment = Color(0xFF6E9B6E);
  static const codeKey = Color(0xFF9CDCFE);
  static const codeValue = Color(0xFFCE9178);
  static const codeKeyword = Color(0xFFC586C0);
  static const codeType = Color(0xFF4EC9B0);
  static const lineNumber = Color(0xFF585858);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppTheme.background,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        surface: AppTheme.panel,
        primary: AppTheme.accentBlue,
      ),
      dividerColor: AppTheme.border,
      useMaterial3: true,
    );
  }
}
