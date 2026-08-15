import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/config/theme/app_colors.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

abstract final class ChartAxis {
  static const height = 156.0;
  static const yInterval = 20.0;
  static const leftTitleCount = 6;
  static const yRange = yInterval * (leftTitleCount - 1);
  static const hourlyBottomLabelCount = 8;
  static const dailyBottomLabelCount = 7;
  static const visibleHours = hourlyBottomLabelCount - 1;
  static const visibleDays = dailyBottomLabelCount - 1;
  static const minutesPerHour = 60.0;
  static const minutesPerDay = 24 * minutesPerHour;
  static const leftTitlesSize = 28.0;
  static const bottomTitlesSize = 32.0;
  static const dotPaddingPx = 18.0;
  static const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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

  static double resolveYInterval(
    Iterable<double> values, {
    double minInterval = yInterval,
  }) {
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final span = math.max(maxValue - minValue, minInterval);
    final nice = _niceNumber(span / (leftTitleCount - 1), minInterval);
    return math.max(nice, minInterval);
  }

  static double _niceNumber(double value, [double minInterval = yInterval]) {
    if (value <= 0) return minInterval;
    final exp = (math.log(value) / math.ln10).floor();
    final fraction = value / math.pow(10, exp);
    final niceFraction = fraction <= 1
        ? 1.0
        : fraction <= 2
        ? 2.0
        : fraction <= 5
        ? 5.0
        : 10.0;
    return niceFraction * math.pow(10, exp);
  }

  static ({double minY, double maxY, double interval}) yBounds(
    Iterable<double> values, {
    double minInterval = yInterval,
    bool fromZero = false,
  }) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final interval = resolveYInterval(
      fromZero ? [0.0, maxValue] : values,
      minInterval: minInterval,
    );
    final range = interval * (leftTitleCount - 1);

    if (fromZero) {
      var maxY = range;
      if (maxValue > maxY) {
        maxY = (maxValue / interval).ceil() * interval;
      }
      return (minY: 0, maxY: maxY, interval: interval);
    }

    final minValue = values.reduce((a, b) => a < b ? a : b);
    final mid = (minValue + maxValue) / 2;

    var minY = ((mid - range / 2) / interval).round() * interval;
    var maxY = minY + range;

    if (minValue < minY) {
      minY = (minValue / interval).floor() * interval;
      maxY = minY + range;
    }
    if (maxValue > maxY) {
      maxY = (maxValue / interval).ceil() * interval;
      minY = maxY - range;
    }

    if (minY < 0) {
      minY = 0;
      maxY = range;
    }

    return (minY: minY, maxY: maxY, interval: interval);
  }

  static SideTitles leftTitles(
    BuildContext context, {
    required double interval,
    String Function(double value)? format,
  }) => SideTitles(
    showTitles: true,
    reservedSize: leftTitlesSize,
    interval: interval,
    getTitlesWidget: (value, meta) => SideTitleWidget(
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
    ),
  );

  static String _yLabel(double value) {
    if (value.abs() >= 1000) {
      final thousands = value / 1000;
      final text = thousands == thousands.roundToDouble()
          ? thousands.toStringAsFixed(0)
          : thousands.toStringAsFixed(1);
      return '${text}k';
    }
    return value.toStringAsFixed(0);
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
            isHourly ? hourLabel(date) : dayLabel(date),
            style: context.typography.bodySmall.copyWith(
              color: context.theme.textTertiary,
              fontWeight: isSelected ? FontWeight.w700 : null,
            ),
          ),
        );
      },
    );
  }

  static String hourLabel(DateTime date) {
    final hour = date.hour;
    final period = hour < 12 ? 'am' : 'pm';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12$period';
  }

  static String dayLabel(DateTime date) => dayLabels[date.weekday - 1];

  static List<LineChartBarData> gridBars({
    required AppColorsTheme colors,
    required double windowStart,
    required double visibleMinutes,
    required double minY,
    required double interval,
  }) => [
    for (var i = 0; i < leftTitleCount; i++)
      LineChartBarData(
        spots: [
          FlSpot(windowStart, minY + i * interval),
          FlSpot(windowStart + visibleMinutes, minY + i * interval),
        ],
        color: colors.border,
        barWidth: 1,
        dotData: const FlDotData(show: false),
        dashArray: const [6, 4],
      ),
  ];
}
