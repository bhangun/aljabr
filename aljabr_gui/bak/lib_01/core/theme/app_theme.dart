import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const _bg = Color(0xFF0D1117); // deep github-dark
  static const _surface = Color(0xFF161B22);
  static const _surfaceEl = Color(0xFF21262D);
  static const _border = Color(0xFF30363D);
  static const _accent = Color(0xFF58A6FF); // cool blue
  static const _accentGreen = Color(0xFF3FB950);
  static const _accentRed = Color(0xFFF85149);
  static const _accentYellow = Color(0xFFD29922);
  static const _textPrimary = Color(0xFFE6EDF3);
  static const _textSecondary = Color(0xFF8B949E);
  static const _textMuted = Color(0xFF484F58);

  // Public tokens for use in widgets
  static const Color background = _bg;
  static const Color surface = _surface;
  static const Color surfaceElevated = _surfaceEl;
  static const Color border = _border;
  static const Color accent = _accent;
  static const Color success = _accentGreen;
  static const Color error = _accentRed;
  static const Color warning = _accentYellow;
  static const Color textPrimary = _textPrimary;
  static const Color textSecondary = _textSecondary;
  static const Color textMuted = _textMuted;

  // Diff colors
  static const Color diffAdded = Color(0xFF1A4A1A);
  static const Color diffRemoved = Color(0xFF4A1A1A);
  static const Color diffAddedText = Color(0xFF3FB950);
  static const Color diffRemovedText = Color(0xFFF85149);
  static const Color diffAddedLine = Color(0xFF0D2818);
  static const Color diffRemovedLine = Color(0xFF2D0D0D);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      // Prefer local Inter font registered in pubspec (falls back to system if
      // not available). This avoids runtime HTTP font fetches.
      scaffoldBackgroundColor: _bg,
      colorScheme: const ColorScheme.dark(
        surface: _surface,
        primary: _accent,
        secondary: _accentGreen,
        error: _accentRed,
        onSurface: _textPrimary,
        outline: _border,
        surfaceContainerHighest: _surfaceEl,
      ),
      textTheme: GoogleFonts.interTextTheme(
        base.textTheme,
      ).apply(fontFamily: 'Inter', bodyColor: _textPrimary, displayColor: _textPrimary),
      dividerColor: _border,
      cardColor: _surface,
      cardTheme: const CardThemeData(
        color: _surface,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceEl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: _textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
      ),
      scrollbarTheme: const ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(Color(0xFF30363D)),
        trackColor: WidgetStatePropertyAll(Colors.transparent),
        radius: Radius.circular(4),
        thickness: WidgetStatePropertyAll(4),
      ),
    );
  }

  static TextStyle get monoStyle => const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        color: _textPrimary,
        height: 1.6,
      );

  static TextStyle get monoSmall => const TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 11.5,
        color: _textSecondary,
        height: 1.5,
      );
}
