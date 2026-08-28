import 'package:flutter/material.dart';

/// Semantic AppColors Theme Extension for Aljabr IDE.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceActive;

  final Color border;
  final Color borderStrong;

  final Color text;
  final Color textMuted;
  final Color textSubtle;

  final Color accent;
  final Color accentMuted;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceActive,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.accent,
    required this.accentMuted,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  static const dark = AppColors(
    background: Color(0xFF101114),
    surface: Color(0xFF17181C),
    surfaceElevated: Color(0xFF1D1F24),
    surfaceActive: Color(0xFF252831),

    border: Color(0xFF292C33),
    borderStrong: Color(0xFF3A3E47),

    text: Color(0xFFE7E9ED),
    textMuted: Color(0xFF9CA1AA),
    textSubtle: Color(0xFF70757F),

    accent: Color(0xFF7C9CFF),
    accentMuted: Color(0xFF2A3350),

    success: Color(0xFF55C58A),
    warning: Color(0xFFE4B65A),
    error: Color(0xFFE06C75),
    info: Color(0xFF69A8E8),
  );

  static const light = AppColors(
    background: Color(0xFFF7F8FA),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFF1F3F6),
    surfaceActive: Color(0xFFE8EBF0),

    border: Color(0xFFD9DDE5),
    borderStrong: Color(0xFFBEC4CF),

    text: Color(0xFF1B1D22),
    textMuted: Color(0xFF626873),
    textSubtle: Color(0xFF8A909A),

    accent: Color(0xFF4969D8),
    accentMuted: Color(0xFFE4E9FF),

    success: Color(0xFF248A58),
    warning: Color(0xFF9A6A00),
    error: Color(0xFFC23B45),
    info: Color(0xFF3174B8),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceActive,
    Color? border,
    Color? borderStrong,
    Color? text,
    Color? textMuted,
    Color? textSubtle,
    Color? accent,
    Color? accentMuted,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceActive: surfaceActive ?? this.surfaceActive,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      textSubtle: textSubtle ?? this.textSubtle,
      accent: accent ?? this.accent,
      accentMuted: accentMuted ?? this.accentMuted,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      surfaceActive: Color.lerp(surfaceActive, other.surfaceActive, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textSubtle: Color.lerp(textSubtle, other.textSubtle, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentMuted: Color.lerp(accentMuted, other.accentMuted, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Backward-compatible AppTheme utility providing centralized colors
class AppTheme {
  AppTheme._();

  static const background = Color(0xFF101114);
  static const panel = Color(0xFF17181C);
  static const panelAlt = Color(0xFF1D1F24);
  static const sidebarSelected = Color(0xFF252831);
  static const border = Color(0xFF292C33);
  static const chip = Color(0xFF252831);

  static const textPrimary = Color(0xFFE7E9ED);
  static const textSecondary = Color(0xFF9CA1AA);
  static const textMuted = Color(0xFF70757F);

  static const accent = Color(0xFF7C9CFF);
  static const accentBlue = Color(0xFF7C9CFF);
  static const accentGreen = Color(0xFF55C58A);
  static const accentAmber = Color(0xFFE4B65A);

  static const surface = Color(0xFF17181C);
  static const surfaceElevated = Color(0xFF1D1F24);

  // Code editor syntax accents
  static const codeComment = Color(0xFF6E9B6E);
  static const codeKey = Color(0xFF9CDCFE);
  static const codeValue = Color(0xFFCE9178);
  static const codeKeyword = Color(0xFFC586C0);
  static const codeType = Color(0xFF4EC9B0);
  static const lineNumber = Color(0xFF585858);

  static ThemeData get dark {
    const colors = AppColors.dark;
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: colors.background,
      useMaterial3: true,
      extensions: const [colors],
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF17181C),
        primary: Color(0xFF7C9CFF),
        error: Color(0xFFE06C75),
      ),
      dividerColor: colors.border,
    );
  }

  static ThemeData get light {
    const colors = AppColors.light;
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: colors.background,
      useMaterial3: true,
      extensions: const [colors],
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFFFFFFF),
        primary: Color(0xFF4969D8),
        error: Color(0xFFC23B45),
      ),
      dividerColor: colors.border,
    );
  }

  static AppColors colorsOf(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? AppColors.dark;
  }
}
