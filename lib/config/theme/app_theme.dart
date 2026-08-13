import 'package:flutter/material.dart';
import 'package:jupyter_health/config/theme/app_colors.dart';
import 'package:jupyter_health/config/theme/app_typography.dart';

class AppTheme {
  AppTheme._({required this.colors, required this.typography});

  factory AppTheme.light() {
    final colors = AppColorsTheme.light();
    return AppTheme._(colors: colors, typography: AppTypography.light());
  }

  final AppColorsTheme colors;
  final AppTypography typography;

  ThemeData toThemeData() {
    final base = ThemeData(
      useMaterial3: true,
      fontFamily: AppTypography.fontFamily,
    );

    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: colors.primary,
        onPrimary: colors.black,
        secondary: colors.secondary,
        onSecondary: colors.black,
        surface: colors.primary,
        onSurface: colors.black,
        error: colors.error,
        onError: colors.white,
      ),
      scaffoldBackgroundColor: colors.white,
      textTheme: base.textTheme.apply(
        fontFamily: AppTypography.fontFamily,
        bodyColor: colors.black,
        displayColor: colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors.black,
          backgroundColor: colors.primary,
          disabledForegroundColor: colors.textSecondary,
          disabledBackgroundColor: colors.disabled,
          textStyle: typography.buttonLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        ),
      ),
      extensions: [colors, typography],
    );
  }
}
