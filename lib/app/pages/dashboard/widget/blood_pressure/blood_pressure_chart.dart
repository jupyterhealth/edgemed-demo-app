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
  final void Function(Observation observation) onObservationSelected;
  final VoidCallback? onLoadMore;

  const BloodPressureChart({
    super.key,
    required this.observations,
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
      isHourly: false,
    );
    final selectablePoints = _dailyPoints(points, origin);
    final systolicSpots = [
      for (final point in selectablePoints) point.systolicSpot,
    ];
    final diastolicSpots = [
      for (final point in selectablePoints) point.diastolicSpot,
    ];

    if (selectablePoints.isEmpty ||
        systolicSpots.isEmpty ||
        diastolicSpots.isEmpty) {
      return const SizedBox();
    }

    return ScrollableLineChart<Observation>(
      isHourly: false,
      origin: origin,
      dataMaxX: systolicSpots.last.x,
      ySpots: [...systolicSpots, ...diastolicSpots],
      selectablePoints: [
        for (final point in selectablePoints)
          (x: point.systolicSpot.x, data: point.observation),
      ],
      onPointSelected: onObservationSelected,
      onReachOlderData: onLoadMore,
      buildSeries: (chartContext) {
        final isolatedXs = ChartAxis.isolatedSpotXs(
          systolicSpots,
          maxGap: ChartAxis.minutesPerDay,
        );
        final gappedDiastolic = ChartAxis.spotsWithGaps(
          diastolicSpots,
          maxGap: ChartAxis.minutesPerDay,
        );
        final gappedSystolic = ChartAxis.spotsWithGaps(
          systolicSpots,
          maxGap: ChartAxis.minutesPerDay,
        );
        return [
          _series(
            spots: gappedDiastolic,
            isolatedXs: isolatedXs,
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
            spots: gappedSystolic,
            isolatedXs: isolatedXs,
            color: chartContext.colors.primary,
            chartContext: chartContext,
          ),
        ];
      },
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
    required Set<double> isolatedXs,
    required Color color,
    required ScrollableChartContext chartContext,
    BarAreaData? belowBarData,
  }) => LineChartBarData(
    isCurved: false,
    color: color,
    barWidth: 2,
    isStrokeCapRound: true,
    belowBarData: belowBarData,
    dotData: FlDotData(
      show: true,
      checkToShowDot: (spot, _) =>
          spot.x == chartContext.highlightedX || isolatedXs.contains(spot.x),
      getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
        radius: spot.x == chartContext.highlightedX ? 6 : 5,
        color: color,
        strokeWidth: spot.x == chartContext.highlightedX ? 6 : 0,
        strokeColor: color.withValues(alpha: 0.25),
      ),
    ),
    spots: spots,
  );
}
