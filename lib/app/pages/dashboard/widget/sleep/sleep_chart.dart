import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/chart_axis.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_chart_context.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_line_chart.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';

typedef _SleepStages = ({double total, double deep, double rem, double light});

typedef _SleepPoint = ({
  DateTime date,
  _SleepStages stages,
  Observation observation,
});

typedef _SleepDay = ({
  FlSpot spot,
  Observation observation,
  _SleepStages stages,
});

class SleepChart extends StatelessWidget {
  static const remColor = Color(0xFF7068E5);
  static const lightSleepColor = Color(0xFF8E919D);
  static const _barWidthPx = 14.0;
  static const _segmentGapPx = 4.0;
  static const _minSegmentHours = 1 / 60;

  final List<Observation> observations;
  final void Function(Observation observation) onObservationSelected;
  final VoidCallback? onLoadMore;

  const SleepChart({
    super.key,
    required this.observations,
    required this.onObservationSelected,
    this.onLoadMore,
  });

  static String formatDuration(double hours) {
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h${m}m';
  }

  static String formatPercent(double part, double total) {
    if (total <= 0) return '0%';
    return '${((part / total) * 100).round()}%';
  }

  static double _stackedHours({
    required double deep,
    required double rem,
    required double light,
    required double total,
  }) {
    final stacked = deep + rem + light;
    if (stacked > 0) return stacked;
    if (total > 0) return total;
    return 0;
  }

  /// Keeps chart scale aligned with rendered bars when a day aggregates both
  /// stage breakdowns and total-only observations.
  static _SleepStages _normalizedStages(_SleepStages stages) {
    final stacked = stages.deep + stages.rem + stages.light;
    if (stacked <= 0) return stages;
    return (
      total: stacked,
      deep: stages.deep,
      rem: stages.rem,
      light: stages.light,
    );
  }

  static String hourAxisLabel(double value) {
    if (value == 0) return '0';
    final text = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(1);
    return '${text}h';
  }

  static Observation? defaultSelection(List<Observation> observations) {
    final points = _sleepPointsOf(observations);
    if (points.isEmpty) return null;

    final origin = ChartAxis.chartOrigin(
      firstDate: points.first.date,
      isHourly: false,
    );
    return _dailyPointsOf(points, origin).lastOrNull?.observation;
  }

  @override
  Widget build(BuildContext context) {
    final points = _sleepPointsOf(observations);
    if (points.isEmpty) {
      if (onLoadMore == null) return const SizedBox();
      return SizedBox(
        height: ChartAxis.height,
        child: Center(
          child: TextButton(
            onPressed: onLoadMore,
            child: Text(T(context).loadOlderData),
          ),
        ),
      );
    }

    final origin = ChartAxis.chartOrigin(
      firstDate: points.first.date,
      isHourly: false,
    );
    final selectablePoints = _dailyPointsOf(points, origin);
    final spots = [for (final point in selectablePoints) point.spot];

    return ScrollableLineChart<Observation>(
      isHourly: false,
      origin: origin,
      dataMaxX: spots.last.x,
      yFromZero: true,
      minYInterval: 1,
      formatY: hourAxisLabel,
      ySpots: spots,
      selectablePoints: [
        for (final point in selectablePoints)
          (x: point.spot.x, data: point.observation),
      ],
      onPointSelected: onObservationSelected,
      onReachOlderData: onLoadMore,
      buildSeries: (chartContext) =>
          _sleepSeries(days: selectablePoints, chartContext: chartContext),
    );
  }

  static List<_SleepPoint> _sleepPointsOf(List<Observation> observations) {
    final points = observations
        .map(
          (observation) => observation.data.mapOrNull(
            sleep: (sleep) => (
              date: sleep.date,
              stages: (
                total: _stackedHours(
                  deep: sleep.deep,
                  rem: sleep.rem,
                  light: sleep.light,
                  total: sleep.value,
                ),
                deep: sleep.deep,
                rem: sleep.rem,
                light: sleep.light,
              ),
              observation: observation,
            ),
          ),
        )
        .whereType<_SleepPoint>()
        .toList();

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  static List<_SleepDay> _dailyPointsOf(
    List<_SleepPoint> points,
    DateTime origin,
  ) {
    final stagesByDay = <int, _SleepStages>{};
    final sampleByDay = <int, Observation>{};

    for (final point in points) {
      final minutes = point.date.difference(origin).inMinutes;
      final dayIndex = (minutes / ChartAxis.minutesPerDay).floor();
      final previous = stagesByDay[dayIndex];
      stagesByDay[dayIndex] = previous == null
          ? point.stages
          : (
              total: previous.total + point.stages.total,
              deep: previous.deep + point.stages.deep,
              rem: previous.rem + point.stages.rem,
              light: previous.light + point.stages.light,
            );
      sampleByDay[dayIndex] = point.observation;
    }

    final days = stagesByDay.keys.toList()..sort();
    final summed = <_SleepDay>[];

    for (final day in days) {
      final stages = _normalizedStages(stagesByDay[day]!);
      final hours = stages.total;
      final dayMinutes = day * ChartAxis.minutesPerDay;
      final dayDate = origin.add(Duration(minutes: dayMinutes.round()));
      final sample = sampleByDay[day]!;

      summed.add((
        spot: FlSpot(dayMinutes.toDouble(), hours),
        stages: stages,
        observation: Observation(
          id: sample.id,
          type: sample.type,
          data: ObservationData.sleep(
            value: hours,
            date: dayDate,
            deep: stages.deep,
            rem: stages.rem,
            light: stages.light,
          ),
          date: dayDate,
        ),
      ));
    }

    return summed;
  }

  List<LineChartBarData> _sleepSeries({
    required List<_SleepDay> days,
    required ScrollableChartContext chartContext,
  }) {
    final plotHeight = ChartAxis.height - ChartAxis.bottomTitlesSize;
    final yRange = chartContext.maxY - chartContext.minY;
    final yPerPixel = yRange <= 0 || plotHeight <= 0
        ? 0.0
        : yRange / plotHeight;
    final radiusY = (_barWidthPx / 2) * yPerPixel;
    final gapY = _segmentGapPx * yPerPixel;
    final yCapScale = chartContext.maxY <= 0
        ? 1.0
        : (chartContext.maxY - radiusY) / chartContext.maxY;
    final minX = chartContext.windowStart - ChartAxis.minutesPerDay;
    final maxX =
        chartContext.windowStart +
        chartContext.visibleMinutes +
        ChartAxis.minutesPerDay;

    return [
      for (final day in days)
        if (day.spot.x >= minX && day.spot.x <= maxX)
          ..._dayBars(
            x: day.spot.x,
            stages: day.stages,
            radiusY: radiusY,
            gapY: gapY * yCapScale,
            yCapScale: yCapScale,
            color: chartContext.colors.tertiary,
          ),
    ];
  }

  List<LineChartBarData> _dayBars({
    required double x,
    required _SleepStages stages,
    required double radiusY,
    required double gapY,
    required double yCapScale,
    required Color color,
  }) {
    final remainder =
        stages.total - stages.light - stages.rem - stages.deep;
    final segments = [
      (hours: stages.light, color: lightSleepColor),
      (hours: stages.rem, color: remColor),
      (hours: stages.deep, color: color),
    ];
    final hasStages = segments.any((stage) => stage.hours > _minSegmentHours);
    final displayed = [
      if (hasStages && remainder > _minSegmentHours)
        (hours: remainder * yCapScale, color: color),
      if (hasStages)
        for (final stage in segments)
          if (stage.hours > _minSegmentHours)
            (hours: stage.hours * yCapScale, color: stage.color),
      if (!hasStages && stages.total > _minSegmentHours)
        (hours: stages.total * yCapScale, color: color),
    ];
    if (displayed.isEmpty) return const [];

    final totalHours = displayed.fold<double>(
      0,
      (sum, stage) => sum + stage.hours,
    );
    final gapCount = displayed.length - 1;
    final effectiveGap = gapCount <= 0
        ? 0.0
        : gapY.clamp(0.0, totalHours / gapCount);
    final drawableHours = totalHours - gapCount * effectiveGap;
    final scale = totalHours <= 0 ? 0.0 : drawableHours / totalHours;

    var fromY = 0.0;
    final bars = <LineChartBarData>[];
    for (var i = 0; i < displayed.length; i++) {
      final stage = displayed[i];
      bars.add(
        _segmentBar(
          x: x,
          fromY: fromY,
          hours: stage.hours * scale,
          color: stage.color,
          radiusY: radiusY,
        ),
      );
      fromY += stage.hours * scale;
      if (i < gapCount) fromY += effectiveGap;
    }

    return bars;
  }

  LineChartBarData _segmentBar({
    required double x,
    required double fromY,
    required double hours,
    required Color color,
    required double radiusY,
  }) {
    final visualEnd = fromY + hours;
    var lineStart = fromY + radiusY;
    var lineEnd = visualEnd - radiusY;
    if (lineEnd <= lineStart) {
      final mid = (fromY + visualEnd) / 2;
      lineStart = mid;
      lineEnd = mid + 0.001;
    }

    return LineChartBarData(
      spots: [FlSpot(x, lineStart), FlSpot(x, lineEnd)],
      color: color,
      barWidth: _barWidthPx,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
    );
  }
}
