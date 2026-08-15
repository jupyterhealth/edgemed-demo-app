import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/chart_axis.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_chart_context.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_line_chart.dart';
import 'package:jupyter_health/config/theme/app_colors.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';

class GlucoseChart extends StatelessWidget {
  final List<Observation> observations;
  final bool isHourly;
  final void Function(Observation observation) onObservationSelected;
  final VoidCallback? onLoadMore;

  const GlucoseChart({
    super.key,
    required this.observations,
    required this.isHourly,
    required this.onObservationSelected,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final points = _glucosePoints;
    if (points.isEmpty) {
      return const SizedBox();
    }

    final origin = ChartAxis.chartOrigin(
      firstDate: points.first.date,
      isHourly: isHourly,
    );
    final selectablePoints = isHourly
        ? _hourlyPoints(points, origin)
        : _dailyPoints(points, origin);
    final spots = isHourly
        ? [
            for (final point in points)
              FlSpot(
                point.date.difference(origin).inMinutes.toDouble(),
                point.value,
              ),
          ]
        : [for (final point in selectablePoints) point.spot];

    if (selectablePoints.isEmpty || spots.isEmpty) {
      return const SizedBox();
    }

    return ScrollableLineChart<Observation>(
      isHourly: isHourly,
      origin: origin,
      dataMaxX: spots.last.x,
      yValues: [for (final spot in spots) spot.y],
      selectablePoints: [
        for (final point in selectablePoints)
          (x: point.spot.x, data: point.observation),
      ],
      onPointSelected: onObservationSelected,
      onReachOlderData: onLoadMore,
      buildSeries: (chartContext) => [
        _glucoseSeries(spots: spots, chartContext: chartContext),
      ],
    );
  }

  List<({DateTime date, double value, Observation observation})>
  get _glucosePoints {
    final points = observations
        .map(
          (observation) => observation.data.whenOrNull(
            glucose: (value, date) =>
                (date: date, value: value, observation: observation),
          ),
        )
        .whereType<({DateTime date, double value, Observation observation})>()
        .toList();

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  List<({FlSpot spot, Observation observation})> _hourlyPoints(
    List<({DateTime date, double value, Observation observation})> points,
    DateTime origin,
  ) {
    final bestByHour =
        <int, ({FlSpot spot, Observation observation, int distance})>{};

    for (final point in points) {
      final minutes = point.date.difference(origin).inMinutes;
      final nearestHour = (minutes / ChartAxis.minutesPerHour).round();
      final distance = (minutes - nearestHour * ChartAxis.minutesPerHour)
          .abs()
          .toInt();
      final existing = bestByHour[nearestHour];

      if (existing == null || distance < existing.distance) {
        bestByHour[nearestHour] = (
          spot: FlSpot(minutes.toDouble(), point.value),
          observation: point.observation,
          distance: distance,
        );
      }
    }

    final hours = bestByHour.keys.toList()..sort();
    return [
      for (final hour in hours)
        (
          spot: bestByHour[hour]!.spot,
          observation: bestByHour[hour]!.observation,
        ),
    ];
  }

  List<({FlSpot spot, Observation observation})> _dailyPoints(
    List<({DateTime date, double value, Observation observation})> points,
    DateTime origin,
  ) {
    final sumByDay = <int, double>{};
    final countByDay = <int, int>{};
    final sampleByDay = <int, Observation>{};

    for (final point in points) {
      final minutes = point.date.difference(origin).inMinutes;
      final dayIndex = (minutes / ChartAxis.minutesPerDay).floor();
      sumByDay[dayIndex] = (sumByDay[dayIndex] ?? 0) + point.value;
      countByDay[dayIndex] = (countByDay[dayIndex] ?? 0) + 1;
      sampleByDay[dayIndex] = point.observation;
    }

    final days = sumByDay.keys.toList()..sort();
    final averaged = <({FlSpot spot, Observation observation})>[];

    for (final day in days) {
      final average = sumByDay[day]! / countByDay[day]!;
      final dayMinutes = day * ChartAxis.minutesPerDay;
      final dayDate = origin.add(Duration(minutes: dayMinutes.round()));
      final sample = sampleByDay[day]!;

      averaged.add((
        spot: FlSpot(dayMinutes.toDouble(), average),
        observation: Observation(
          id: sample.id,
          type: sample.type,
          data: ObservationData.glucose(value: average, date: dayDate),
          date: dayDate,
        ),
      ));
    }

    return averaged;
  }

  LineChartBarData _glucoseSeries({
    required List<FlSpot> spots,
    required ScrollableChartContext chartContext,
  }) => LineChartBarData(
    isCurved: true,
    curveSmoothness: 0.25,
    color: chartContext.colors.primary,
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(
      show: true,
      checkToShowDot: (spot, _) => spot.x == chartContext.highlightedX,
      getDotPainter: (spot, percent, bar, index) =>
          _dotPainter(chartContext.colors),
    ),
    spots: spots,
  );

  FlDotCirclePainter _dotPainter(AppColorsTheme colors) => FlDotCirclePainter(
    radius: 6,
    color: colors.primary,
    strokeWidth: 6,
    strokeColor: colors.primary.withValues(alpha: 0.25),
  );
}
