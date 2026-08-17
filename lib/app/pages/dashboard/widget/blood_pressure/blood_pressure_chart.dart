import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/chart_axis.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_chart_context.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart/scrollable_line_chart.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';

class BloodPressureChart extends StatelessWidget {
  static const diastolicColor = Color(0xFF9B8BC4);

  final List<Observation> observations;
  final bool isHourly;
  final void Function(Observation observation) onObservationSelected;
  final VoidCallback? onLoadMore;

  const BloodPressureChart({
    super.key,
    required this.observations,
    required this.isHourly,
    required this.onObservationSelected,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final points = _bloodPressurePoints;
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
    final systolicSpots = isHourly
        ? [
            for (final point in points)
              FlSpot(
                point.date.difference(origin).inMinutes.toDouble(),
                point.systolic,
              ),
          ]
        : [for (final point in selectablePoints) point.systolicSpot];
    final diastolicSpots = isHourly
        ? [
            for (final point in points)
              FlSpot(
                point.date.difference(origin).inMinutes.toDouble(),
                point.diastolic,
              ),
          ]
        : [for (final point in selectablePoints) point.diastolicSpot];

    if (selectablePoints.isEmpty ||
        systolicSpots.isEmpty ||
        diastolicSpots.isEmpty) {
      return const SizedBox();
    }

    return ScrollableLineChart<Observation>(
      isHourly: isHourly,
      origin: origin,
      dataMaxX: systolicSpots.last.x,
      ySpots: [...systolicSpots, ...diastolicSpots],
      selectablePoints: [
        for (final point in selectablePoints)
          (x: point.systolicSpot.x, data: point.observation),
      ],
      onPointSelected: onObservationSelected,
      onReachOlderData: onLoadMore,
      buildSeries: (chartContext) => [
        _series(
          spots: diastolicSpots,
          color: diastolicColor,
          chartContext: chartContext,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                diastolicColor.withValues(alpha: 0.35),
                diastolicColor.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
        _series(
          spots: systolicSpots,
          color: chartContext.colors.primary,
          chartContext: chartContext,
        ),
      ],
      buildBetweenBars: (chartContext, seriesStartIndex) => [
        BetweenBarsData(
          fromIndex: seriesStartIndex,
          toIndex: seriesStartIndex + 1,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              chartContext.colors.primary.withValues(alpha: 0.45),
              diastolicColor.withValues(alpha: 0.2),
            ],
          ),
        ),
      ],
    );
  }

  List<
    ({
      DateTime date,
      double systolic,
      double diastolic,
      Observation observation,
    })
  >
  get _bloodPressurePoints {
    final points = observations
        .map(
          (observation) => observation.data.whenOrNull(
            bloodPressure: (systolic, diastolic, date) => (
              date: date,
              systolic: systolic,
              diastolic: diastolic,
              observation: observation,
            ),
          ),
        )
        .whereType<
          ({
            DateTime date,
            double systolic,
            double diastolic,
            Observation observation,
          })
        >()
        .toList();

    points.sort((a, b) => a.date.compareTo(b.date));
    return points;
  }

  List<({FlSpot systolicSpot, FlSpot diastolicSpot, Observation observation})>
  _hourlyPoints(
    List<
      ({
        DateTime date,
        double systolic,
        double diastolic,
        Observation observation,
      })
    >
    points,
    DateTime origin,
  ) {
    final bestByHour =
        <
          int,
          ({
            FlSpot systolicSpot,
            FlSpot diastolicSpot,
            Observation observation,
            int distance,
          })
        >{};

    for (final point in points) {
      final minutes = point.date.difference(origin).inMinutes;
      final nearestHour = (minutes / ChartAxis.minutesPerHour).round();
      final distance = (minutes - nearestHour * ChartAxis.minutesPerHour)
          .abs()
          .toInt();
      final existing = bestByHour[nearestHour];

      if (existing == null || distance < existing.distance) {
        bestByHour[nearestHour] = (
          systolicSpot: FlSpot(minutes.toDouble(), point.systolic),
          diastolicSpot: FlSpot(minutes.toDouble(), point.diastolic),
          observation: point.observation,
          distance: distance,
        );
      }
    }

    final hours = bestByHour.keys.toList()..sort();
    return [
      for (final hour in hours)
        (
          systolicSpot: bestByHour[hour]!.systolicSpot,
          diastolicSpot: bestByHour[hour]!.diastolicSpot,
          observation: bestByHour[hour]!.observation,
        ),
    ];
  }

  List<({FlSpot systolicSpot, FlSpot diastolicSpot, Observation observation})>
  _dailyPoints(
    List<
      ({
        DateTime date,
        double systolic,
        double diastolic,
        Observation observation,
      })
    >
    points,
    DateTime origin,
  ) {
    final systolicSumByDay = <int, double>{};
    final diastolicSumByDay = <int, double>{};
    final countByDay = <int, int>{};
    final sampleByDay = <int, Observation>{};

    for (final point in points) {
      final minutes = point.date.difference(origin).inMinutes;
      final dayIndex = (minutes / ChartAxis.minutesPerDay).floor();
      systolicSumByDay[dayIndex] =
          (systolicSumByDay[dayIndex] ?? 0) + point.systolic;
      diastolicSumByDay[dayIndex] =
          (diastolicSumByDay[dayIndex] ?? 0) + point.diastolic;
      countByDay[dayIndex] = (countByDay[dayIndex] ?? 0) + 1;
      sampleByDay[dayIndex] = point.observation;
    }

    final days = systolicSumByDay.keys.toList()..sort();
    final averaged =
        <
          ({FlSpot systolicSpot, FlSpot diastolicSpot, Observation observation})
        >[];

    for (final day in days) {
      final count = countByDay[day]!;
      final avgSystolic = systolicSumByDay[day]! / count;
      final avgDiastolic = diastolicSumByDay[day]! / count;
      final dayMinutes = day * ChartAxis.minutesPerDay;
      final dayDate = origin.add(Duration(minutes: dayMinutes.round()));
      final sample = sampleByDay[day]!;

      averaged.add((
        systolicSpot: FlSpot(dayMinutes.toDouble(), avgSystolic),
        diastolicSpot: FlSpot(dayMinutes.toDouble(), avgDiastolic),
        observation: Observation(
          id: sample.id,
          type: sample.type,
          data: ObservationData.bloodPressure(
            systolic: avgSystolic,
            diastolic: avgDiastolic,
            date: dayDate,
          ),
          date: dayDate,
        ),
      ));
    }

    return averaged;
  }

  LineChartBarData _series({
    required List<FlSpot> spots,
    required Color color,
    required ScrollableChartContext chartContext,
    BarAreaData? belowBarData,
  }) => LineChartBarData(
    isCurved: true,
    curveSmoothness: 0.25,
    color: color,
    barWidth: 2,
    isStrokeCapRound: true,
    belowBarData: belowBarData,
    dotData: FlDotData(
      show: true,
      checkToShowDot: (spot, _) => spot.x == chartContext.highlightedX,
      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
        radius: 6,
        color: color,
        strokeWidth: 6,
        strokeColor: color.withValues(alpha: 0.25),
      ),
    ),
    spots: spots,
  );
}
