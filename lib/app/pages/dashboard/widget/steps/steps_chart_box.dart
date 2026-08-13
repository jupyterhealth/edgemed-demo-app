import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/steps/steps_chart.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/utils/extensions/date_time_extension.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class StepsChartBox extends StatefulWidget {
  final List<Observation> observations;
  const StepsChartBox({super.key, required this.observations});

  @override
  State<StepsChartBox> createState() => _StepsChartBoxState();
}

class _StepsChartBoxState extends State<StepsChartBox> {
  late Observation _selectedObservation;

  @override
  void initState() {
    super.initState();
    _selectedObservation = widget.observations.first;
  }

  @override
  Widget build(BuildContext context) {
    return ChartBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Steps', style: context.typography.bodyLarge),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${_selectedObservation.data.mapOrNull(steps: (value) => value.value.toStringAsFixed(0))}',
                      style: context.typography.headerLarge,
                    ),
                    TextSpan(
                      text: ' steps',
                      style: context.typography.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                'measured: ${_selectedObservation.date.toMeasuredLabel()}',
                style: context.typography.bodySmall.copyWith(
                  color: context.theme.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          StepsChart(
            onObservationSelected: (observation) =>
                setState(() => _selectedObservation = observation),
            observations: widget.observations,
          ),
        ],
      ),
    );
  }
}
