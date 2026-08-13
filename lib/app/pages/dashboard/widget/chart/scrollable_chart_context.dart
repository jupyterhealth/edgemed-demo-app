import 'package:jupyter_health/config/theme/app_colors.dart';

class ScrollableChartContext {
  final AppColorsTheme colors;
  final double windowStart;
  final double visibleMinutes;
  final double highlightedX;
  final double minutesPerPixel;
  final double minY;
  final double maxY;

  const ScrollableChartContext({
    required this.colors,
    required this.windowStart,
    required this.visibleMinutes,
    required this.highlightedX,
    required this.minutesPerPixel,
    required this.minY,
    required this.maxY,
  });
}
