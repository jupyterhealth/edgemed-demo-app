import 'package:flutter/material.dart';
import 'package:jupyter_health/config/theme/app_colors.dart';

class AppTypography extends ThemeExtension<AppTypography> {
  AppTypography._({
    required this.h1Headline,
    required this.h2Headline,
    required this.h3Headline,
    required this.h4Headline,
    required this.link,
    required this.button,
    required this.bodyRegular,
    required this.bodyMedium,
    required this.label,
    required this.description,
    required this.captionMedium,
    required this.captionSemiBold,
  });

  static const String _playfairDisplay = 'PlayfairDisplay';
  static const String _dmSans = 'DMSans';

  factory AppTypography.light() => AppTypography._(
    h1Headline: const TextStyle(
      fontFamily: _playfairDisplay,
      fontSize: 32,
      fontWeight: FontWeight.w600,
    ),
    h2Headline: const TextStyle(
      fontFamily: _playfairDisplay,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    h3Headline: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 24,
      fontWeight: FontWeight.w600,
    ),
    h4Headline: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
    link: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      decoration: TextDecoration.underline,
    ),
    button: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    bodyRegular: TextStyle(
      fontFamily: _dmSans,
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.4,
      color: AppColors.primaryBeige.shade800,
    ),
    bodyMedium: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 18,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    label: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
    ),
    description: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.4,
    ),
    captionMedium: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    captionSemiBold: const TextStyle(
      fontFamily: _dmSans,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    ),
  );

  final TextStyle h1Headline;
  final TextStyle h2Headline;
  final TextStyle h3Headline;
  final TextStyle h4Headline;
  final TextStyle link;
  final TextStyle button;
  final TextStyle bodyRegular;
  final TextStyle bodyMedium;
  final TextStyle label;
  final TextStyle description;
  final TextStyle captionMedium;
  final TextStyle captionSemiBold;

  AppTypography withColor(Color color) => AppTypography._(
    h1Headline: h1Headline.copyWith(color: color),
    h2Headline: h2Headline.copyWith(color: color),
    h3Headline: h3Headline.copyWith(color: color),
    h4Headline: h4Headline.copyWith(color: color),
    link: link.copyWith(color: color),
    button: button.copyWith(color: color),
    bodyRegular: bodyRegular.copyWith(color: color),
    bodyMedium: bodyMedium.copyWith(color: color),
    label: label.copyWith(color: color),
    description: description.copyWith(color: color),
    captionMedium: captionMedium.copyWith(color: color),
    captionSemiBold: captionSemiBold.copyWith(color: color),
  );

  @override
  AppTypography copyWith({
    TextStyle? h1Headline,
    TextStyle? h2Headline,
    TextStyle? h3Headline,
    TextStyle? h4Headline,
    TextStyle? link,
    TextStyle? button,
    TextStyle? bodyRegular,
    TextStyle? bodyMedium,
    TextStyle? label,
    TextStyle? description,
    TextStyle? captionMedium,
    TextStyle? captionSemiBold,
  }) => AppTypography._(
    h1Headline: h1Headline ?? this.h1Headline,
    h2Headline: h2Headline ?? this.h2Headline,
    h3Headline: h3Headline ?? this.h3Headline,
    h4Headline: h4Headline ?? this.h4Headline,
    link: link ?? this.link,
    button: button ?? this.button,
    bodyRegular: bodyRegular ?? this.bodyRegular,
    bodyMedium: bodyMedium ?? this.bodyMedium,
    label: label ?? this.label,
    description: description ?? this.description,
    captionMedium: captionMedium ?? this.captionMedium,
    captionSemiBold: captionSemiBold ?? this.captionSemiBold,
  );

  @override
  AppTypography lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) {
      return this;
    }
    return AppTypography._(
      h1Headline: TextStyle.lerp(h1Headline, other.h1Headline, t)!,
      h2Headline: TextStyle.lerp(h2Headline, other.h2Headline, t)!,
      h3Headline: TextStyle.lerp(h3Headline, other.h3Headline, t)!,
      h4Headline: TextStyle.lerp(h4Headline, other.h4Headline, t)!,
      link: TextStyle.lerp(link, other.link, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      bodyRegular: TextStyle.lerp(bodyRegular, other.bodyRegular, t)!,
      bodyMedium: TextStyle.lerp(bodyMedium, other.bodyMedium, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      description: TextStyle.lerp(description, other.description, t)!,
      captionMedium: TextStyle.lerp(captionMedium, other.captionMedium, t)!,
      captionSemiBold: TextStyle.lerp(
        captionSemiBold,
        other.captionSemiBold,
        t,
      )!,
    );
  }
}
