import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/config/theme/app_colors.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

abstract final class ChartAxis {
  static const height = 156.0;
  static const leftTitleCount = 6;
  static const hourlyBottomLabelCount = 8;
  static const dailyBottomLabelCount = 7;
  static const visibleHours = hourlyBottomLabelCount - 1;
  static const visibleDays = dailyBottomLabelCount - 1;
  static const minutesPerHour = 60.0;
  static const minutesPerDay = 24 * minutesPerHour;
  static const leftTitlesSize = 28.0;
  static const bottomTitlesSize = 32.0;
  static const dotPaddingPx = 18.0;
  static const _yPadding = 0.12;

  static List<String> dayLabels(BuildContext context) => [
    T(context).dayMon,
    T(context).dayTue,
    T(context).dayWed,
    T(context).dayThu,
    T(context).dayFri,
    T(context).daySat,
    T(context).daySun,
  ];

  static double visibleMinutes({required bool isHourly}) =>
      isHourly ? visibleHours * minutesPerHour : visibleDays * minutesPerDay;

  static double snapInterval({required bool isHourly}) =>
      isHourly ? minutesPerHour : minutesPerDay;

  static double bucketX(double x, {required bool isHourly}) {
    final interval = snapInterval(isHourly: isHourly);
    return (x / interval).round() * interval;
  }

  static DateTime chartOrigin({
    required DateTime firstDate,
    required bool isHourly,
  }) {
    if (isHourly) {
      return DateTime(
        firstDate.year,
        firstDate.month,
        firstDate.day,
        firstDate.hour,
      );
    }
    return DateTime(firstDate.year, firstDate.month, firstDate.day);
  }

  static double _niceNumber(double value) {
    if (value <= 0) return 1;
    final exp = (math.log(value) / math.ln10).floor();
    final fraction = value / math.pow(10, exp);
    final niceFraction = fraction <= 1
        ? 1.0
        : fraction <= 2
        ? 2.0
        : fraction <= 2.5
        ? 2.5
        : fraction <= 5
        ? 5.0
        : 10.0;
    return niceFraction * math.pow(10, exp);
  }

  static ({double minY, double maxY, double interval}) yBounds(
    Iterable<double> values, {
    double minInterval = 1,
    bool fromZero = false,
  }) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    if (fromZero) {
      final maxY = math.max(maxValue, minInterval);
      return (
        minY: 0.0,
        maxY: maxY,
        interval: niceYInterval(maxY, minInterval: minInterval),
      );
    }

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final span = math.max(maxValue - minValue, minInterval);
    final paddedMin = minValue - span * _yPadding;
    final paddedMax = maxValue + span * _yPadding;
    final paddedSpan = math.max(paddedMax - paddedMin, minInterval);
    final interval = niceYInterval(paddedSpan, minInterval: minInterval);
    final targetRange = interval * (leftTitleCount - 1);

    var minY = (paddedMin / interval).floor() * interval;
    if (minY < 0 && minValue >= 0) minY = 0;

    var maxY = (paddedMax / interval).ceil() * interval;
    if (maxY - minY < targetRange) {
      final extra = targetRange - (maxY - minY);
      minY -= (extra / 2 / interval).ceil() * interval;
      if (minY < 0 && minValue >= 0) minY = 0;
      maxY = minY + targetRange;
    }

    if (paddedMax > maxY) {
      maxY = (paddedMax / interval).ceil() * interval;
    }

    return (minY: minY, maxY: maxY, interval: interval);
  }

  static double niceYInterval(double span, {double minInterval = 1}) =>
      math.max(
        _niceNumber(math.max(span, minInterval) / (leftTitleCount - 1)),
        minInterval,
      );

  static bool isOnYInterval(double value, double interval) {
    if (interval <= 0) return true;
    final scaled = value / interval;
    return (scaled - scaled.round()).abs() < 0.001;
  }

  static List<double> yTicks({
    required double minY,
    required double maxY,
    required double interval,
  }) {
    if (interval <= 0 || maxY < minY) return [minY];
    final epsilon = interval * 1e-6;
    var y = (minY / interval).floor() * interval;
    if (y < minY - epsilon) y += interval;
    final ticks = <double>[];
    while (y <= maxY + epsilon) {
      ticks.add(y);
      y += interval;
    }
    return ticks.isEmpty ? [minY] : ticks;
  }

  static SideTitles leftTitles(
    BuildContext context, {
    required double interval,
    String Function(double value)? format,
  }) => SideTitles(
    showTitles: true,
    reservedSize: leftTitlesSize,
    interval: interval,
    getTitlesWidget: (value, meta) {
      if (!isOnYInterval(value, interval)) {
        return const SizedBox.shrink();
      }
      return SideTitleWidget(
        meta: meta,
        space: 0,
        child: SizedBox(
          width: leftTitlesSize,
          child: Text(
            (format ?? _yLabel)(value),
            textAlign: TextAlign.left,
            style: context.typography.bodySmall.copyWith(
              color: context.theme.textTertiary,
            ),
          ),
        ),
      );
    },
  );

  static String _yLabel(double value) {
    if (value.abs() >= 1000) {
      final thousands = value / 1000;
      final text = thousands == thousands.roundToDouble()
          ? thousands.toStringAsFixed(0)
          : thousands.toStringAsFixed(1);
      return '${text}k';
    }
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  static SideTitles bottomTitles({
    required BuildContext context,
    required DateTime origin,
    required bool isHourly,
    required double selectedX,
  }) {
    final interval = snapInterval(isHourly: isHourly);
    final selectedBucket = bucketX(selectedX, isHourly: isHourly);

    return SideTitles(
      showTitles: true,
      reservedSize: bottomTitlesSize,
      interval: interval,
      minIncluded: false,
      maxIncluded: false,
      getTitlesWidget: (value, meta) {
        final date = origin.add(Duration(minutes: value.round()));
        final isSelected = (value - selectedBucket).abs() < 0.01;

        return SideTitleWidget(
          meta: meta,
          space: 10,
          child: Text(
            isHourly ? hourLabel(context, date) : dayLabel(context, date),
            style: context.typography.bodySmall.copyWith(
              color: context.theme.textTertiary,
              fontWeight: isSelected ? FontWeight.w700 : null,
            ),
          ),
        );
      },
    );
  }

  static String hourLabel(BuildContext context, DateTime date) {
    final hour = date.hour;
    final period = hour < 12 ? T(context).timeAm : T(context).timePm;
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12$period';
  }

  static String dayLabel(BuildContext context, DateTime date) =>
      dayLabels(context)[date.weekday - 1];

  static List<LineChartBarData> gridBars({
    required AppColorsTheme colors,
    required double windowStart,
    required double visibleMinutes,
    required double minY,
    required double maxY,
    required double interval,
  }) => [
    for (final y in yTicks(minY: minY, maxY: maxY, interval: interval))
      LineChartBarData(
        spots: [
          FlSpot(windowStart, y),
          FlSpot(windowStart + visibleMinutes, y),
        ],
        color: colors.border,
        barWidth: 1,
        dotData: const FlDotData(show: false),
        dashArray: const [6, 4],
      ),
  ];
}
