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
    final base = ThemeData(useMaterial3: true);
    final defaultBody = typography.bodyRegular;

    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: colors.primaryBeige500,
        onPrimary: colors.black,
        secondary: colors.primaryBeige200,
        onSecondary: colors.primaryGreen500,
        error: colors.systemRed500,
        onError: colors.white,
        surface: colors.primaryBeige50,
        onSurface: colors.black,
      ),
      scaffoldBackgroundColor: colors.primaryBeige50,
      textTheme: base.textTheme.copyWith(
        bodyMedium: defaultBody,
        bodyLarge: defaultBody,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors.white,
          backgroundColor: colors.primaryGreen700,
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
