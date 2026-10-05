import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/chart_axis.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_chart_context.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_line_chart.dart';
import 'package:jupyter_health/config/theme/app_colors.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';

class StepsChart extends StatelessWidget {
  final List<Observation> observations;
  final void Function(Observation observation) onObservationSelected;
  final VoidCallback? onLoadMore;

  const StepsChart({
    super.key,
    required this.observations,
    required this.onObservationSelected,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final points = _stepsPoints;
    if (points.isEmpty) {
      return const SizedBox();
    }

    final origin = ChartAxis.chartOrigin(
      firstDate: points.first.date,
      isHourly: false,
    );
    final selectablePoints = _dailyPoints(points, origin);
    final spots = [for (final point in selectablePoints) point.spot];

    if (selectablePoints.isEmpty || spots.isEmpty) {
      return const SizedBox();
    }

    return ScrollableLineChart<Observation>(
      isHourly: false,
      origin: origin,
      dataMaxX: spots.last.x,
      ySpots: spots,
      selectablePoints: [
        for (final point in selectablePoints)
          (x: point.spot.x, data: point.observation),
      ],
      onPointSelected: onObservationSelected,
      onReachOlderData: onLoadMore,
      buildSeries: (chartContext) => [
        _stepsSeries(
          spots: ChartAxis.spotsWithGaps(
            spots,
            maxGap: ChartAxis.minutesPerDay,
          ),
          isolatedXs: ChartAxis.isolatedSpotXs(
            spots,
            maxGap: ChartAxis.minutesPerDay,
          ),
          chartContext: chartContext,
        ),
      ],
    );
  }

  List<({DateTime date, double value, Observation observation})>
  get _stepsPoints {
    final points = observations
        .map(
          (observation) => observation.data.whenOrNull(
            steps: (value, date) =>
                (date: date, value: value, observation: observation),
          ),
        )
        .whereType<({DateTime date, double value, Observation observation})>()
        .toList();

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  List<({FlSpot spot, Observation observation})> _dailyPoints(
    List<({DateTime date, double value, Observation observation})> points,
    DateTime origin,
  ) {
    final sumByDay = <int, double>{};
    final sampleByDay = <int, Observation>{};

    for (final point in points) {
      final minutes = point.date.difference(origin).inMinutes;
      final dayIndex = (minutes / ChartAxis.minutesPerDay).floor();
      sumByDay[dayIndex] = (sumByDay[dayIndex] ?? 0) + point.value;
      sampleByDay[dayIndex] = point.observation;
    }

    final days = sumByDay.keys.toList()..sort();
    final summed = <({FlSpot spot, Observation observation})>[];

    for (final day in days) {
      final sum = sumByDay[day]!;
      final dayMinutes = day * ChartAxis.minutesPerDay;
      final dayDate = origin.add(Duration(minutes: dayMinutes.round()));
      final sample = sampleByDay[day]!;

      summed.add((
        spot: FlSpot(dayMinutes.toDouble(), sum),
        observation: Observation(
          id: sample.id,
          type: sample.type,
          data: ObservationData.steps(value: sum, date: dayDate),
          date: dayDate,
        ),
      ));
    }

    return summed;
  }

  LineChartBarData _stepsSeries({
    required List<FlSpot> spots,
    required Set<double> isolatedXs,
    required ScrollableChartContext chartContext,
  }) => LineChartBarData(
    isCurved: true,
    curveSmoothness: 0.25,
    color: chartContext.colors.tertiary,
    barWidth: 2,
    isStrokeCapRound: true,
    dotData: FlDotData(
      show: true,
      checkToShowDot: (spot, _) =>
          spot.x == chartContext.highlightedX || isolatedXs.contains(spot.x),
      getDotPainter: (spot, percent, bar, index) => _dotPainter(
        chartContext.colors,
        isHighlighted: spot.x == chartContext.highlightedX,
      ),
    ),
    spots: spots,
  );

  FlDotCirclePainter _dotPainter(
    AppColorsTheme colors, {
    required bool isHighlighted,
  }) => FlDotCirclePainter(
    radius: isHighlighted ? 6 : 5,
    color: colors.tertiary,
    strokeWidth: isHighlighted ? 6 : 0,
    strokeColor: colors.tertiary.withValues(alpha: 0.25),
  );
}
