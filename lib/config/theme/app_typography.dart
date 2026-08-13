import 'package:flutter/material.dart';

class AppTypography extends ThemeExtension<AppTypography> {
  AppTypography._({
    required this.headerLarge,
    required this.headerMedium,
    required this.headerSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.buttonLarge,
    required this.buttonMedium,
    required this.buttonUnderline,
    required this.buttonSmall,
    required this.captionMedium,
    required this.captionSmall,
  });

  static const String fontFamily = 'Outfit';

  factory AppTypography.light() => AppTypography._(
    headerLarge: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      height: 36 / 32,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    headerMedium: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      height: 28 / 24,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    headerSmall: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 18,
      height: 24 / 18,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 32 / 16,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 20 / 16,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
    buttonLarge: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    buttonMedium: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
    ),
    buttonUnderline: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      height: 20 / 16,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
      decoration: TextDecoration.underline,
    ),
    buttonSmall: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0,
      fontWeight: FontWeight.w600,
    ),
    captionMedium: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      height: 16 / 14,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
    captionSmall: const TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      height: 14 / 12,
      letterSpacing: 0,
      fontWeight: FontWeight.w400,
    ),
  );

  final TextStyle headerLarge;
  final TextStyle headerMedium;
  final TextStyle headerSmall;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle bodySmall;
  final TextStyle buttonLarge;
  final TextStyle buttonMedium;
  final TextStyle buttonUnderline;
  final TextStyle buttonSmall;
  final TextStyle captionMedium;
  final TextStyle captionSmall;

  AppTypography withColor(Color color) => AppTypography._(
    headerLarge: headerLarge.copyWith(color: color),
    headerMedium: headerMedium.copyWith(color: color),
    headerSmall: headerSmall.copyWith(color: color),
    bodyLarge: bodyLarge.copyWith(color: color),
    bodyMedium: bodyMedium.copyWith(color: color),
    bodySmall: bodySmall.copyWith(color: color),
    buttonLarge: buttonLarge.copyWith(color: color),
    buttonMedium: buttonMedium.copyWith(color: color),
    buttonUnderline: buttonUnderline.copyWith(color: color),
    buttonSmall: buttonSmall.copyWith(color: color),
    captionMedium: captionMedium.copyWith(color: color),
    captionSmall: captionSmall.copyWith(color: color),
  );

  @override
  AppTypography copyWith({
    TextStyle? headerLarge,
    TextStyle? headerMedium,
    TextStyle? headerSmall,
    TextStyle? bodyLarge,
    TextStyle? bodyMedium,
    TextStyle? bodySmall,
    TextStyle? buttonLarge,
    TextStyle? buttonMedium,
    TextStyle? buttonUnderline,
    TextStyle? buttonSmall,
    TextStyle? captionMedium,
    TextStyle? captionSmall,
  }) => AppTypography._(
    headerLarge: headerLarge ?? this.headerLarge,
    headerMedium: headerMedium ?? this.headerMedium,
    headerSmall: headerSmall ?? this.headerSmall,
    bodyLarge: bodyLarge ?? this.bodyLarge,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    bodySmall: bodySmall ?? this.bodySmall,
    buttonLarge: buttonLarge ?? this.buttonLarge,
    buttonMedium: buttonMedium ?? this.buttonMedium,
    buttonUnderline: buttonUnderline ?? this.buttonUnderline,
    buttonSmall: buttonSmall ?? this.buttonSmall,
    captionMedium: captionMedium ?? this.captionMedium,
    captionSmall: captionSmall ?? this.captionSmall,
  );

  @override
  AppTypography lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) {
      return this;
    }
    return AppTypography._(
      headerLarge: TextStyle.lerp(headerLarge, other.headerLarge, t)!,
      headerMedium: TextStyle.lerp(headerMedium, other.headerMedium, t)!,
      headerSmall: TextStyle.lerp(headerSmall, other.headerSmall, t)!,
      bodyLarge: TextStyle.lerp(bodyLarge, other.bodyLarge, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      bodySmall: TextStyle.lerp(bodySmall, other.bodySmall, t)!,
      buttonLarge: TextStyle.lerp(buttonLarge, other.buttonLarge, t)!,
      buttonMedium: TextStyle.lerp(buttonMedium, other.buttonMedium, t)!,
      buttonUnderline: TextStyle.lerp(
        buttonUnderline,
        other.buttonUnderline,
        t,
      )!,
      buttonSmall: TextStyle.lerp(buttonSmall, other.buttonSmall, t)!,
      captionMedium: TextStyle.lerp(captionMedium, other.captionMedium, t)!,
      captionSmall: TextStyle.lerp(captionSmall, other.captionSmall, t)!,
    );
  }
}
