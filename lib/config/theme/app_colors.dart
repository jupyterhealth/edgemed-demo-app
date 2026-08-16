import 'package:flutter/material.dart';

abstract final class AppColors {
  static const transparent = Colors.transparent;
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  static const primary = Color(0xFFFFDC00);
  static const secondary = Color(0xFFFFF5B9);
  static const loading = Color(0xFFCCB003);

  static const textSecondary = Color(0xFF676F7B);
  static const textTertiary = Color(0xFF495260);

  static const backgroundSecondary = Color(0xFFF4F6F9);
  static const border = Color(0xFFC5CCD8);
  static const borderDark = Color(0xFF495260);
  static const disabled = Color(0xFFDBDFE6);
  static const error = Color(0xFFC30D49);
}

class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  final Color transparent;
  final Color white;
  final Color black;
  final Color primary;
  final Color secondary;
  final Color loading;
  final Color textSecondary;
  final Color textTertiary;
  final Color backgroundSecondary;
  final Color border;
  final Color borderDark;
  final Color disabled;
  final Color error;
  final Color surface;

  const AppColorsTheme._({
    required this.surface,
    required this.transparent,
    required this.white,
    required this.black,
    required this.primary,
    required this.secondary,
    required this.loading,
    required this.textSecondary,
    required this.textTertiary,
    required this.backgroundSecondary,
    required this.border,
    required this.borderDark,
    required this.disabled,
    required this.error,
  });

  factory AppColorsTheme.light() => const AppColorsTheme._(
    transparent: AppColors.transparent,
    white: AppColors.white,
    black: AppColors.black,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    loading: AppColors.loading,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    backgroundSecondary: AppColors.backgroundSecondary,
    border: AppColors.border,
    borderDark: AppColors.borderDark,
    disabled: AppColors.disabled,
    error: AppColors.error,
    surface: AppColors.white,
  );

  @override
  AppColorsTheme copyWith({
    Color? transparent,
    Color? white,
    Color? black,
    Color? primary,
    Color? secondary,
    Color? loading,
    Color? textSecondary,
    Color? textTertiary,
    Color? backgroundSecondary,
    Color? border,
    Color? borderDark,
    Color? disabled,
    Color? error,
    Color? surface,
  }) => AppColorsTheme._(
    transparent: transparent ?? this.transparent,
    white: white ?? this.white,
    black: black ?? this.black,
    primary: primary ?? this.primary,
    secondary: secondary ?? this.secondary,
    loading: loading ?? this.loading,
    textSecondary: textSecondary ?? this.textSecondary,
    textTertiary: textTertiary ?? this.textTertiary,
    backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
    border: border ?? this.border,
    borderDark: borderDark ?? this.borderDark,
    disabled: disabled ?? this.disabled,
    error: error ?? this.error,
    surface: surface ?? this.surface,
  );

  @override
  AppColorsTheme lerp(
    covariant ThemeExtension<AppColorsTheme>? other,
    double t,
  ) {
    // No need if we are using one theme
    return this;
  }
}
