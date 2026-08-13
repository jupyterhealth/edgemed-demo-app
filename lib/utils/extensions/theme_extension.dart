import 'package:flutter/material.dart';
import 'package:jupyter_health/config/theme/app_colors.dart';
import 'package:jupyter_health/config/theme/app_typography.dart';

extension ThemeContextExtension on BuildContext {
  AppColorsTheme get theme => Theme.of(this).extension<AppColorsTheme>()!;

  AppTypography get typography => Theme.of(this).extension<AppTypography>()!;
}
