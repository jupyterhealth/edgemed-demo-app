import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/glucose/glucose_chart.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/mode_switch.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/utils/extensions/date_time_extension.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class GlucoseChartBox extends StatefulWidget {
  final List<Observation> observations;
  const GlucoseChartBox({super.key, required this.observations});

  @override
  State<GlucoseChartBox> createState() => _GlucoseChartBoxState();
}

class _GlucoseChartBoxState extends State<GlucoseChartBox> {
  bool _mode = true;
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Glucose', style: context.typography.bodyLarge),
              ModeSwitch(
                value: _mode,
                onChanged: (value) => setState(() => _mode = value),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${_selectedObservation.data.mapOrNull(glucose: (value) => value.value.toStringAsFixed(0))}',
                      style: context.typography.headerLarge,
                    ),
                    TextSpan(
                      text: ' mg/dL',
                      style: context.typography.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                'measured: ${_selectedObservation.date.toMeasuredLabel(isHourly: _mode)}',
                style: context.typography.bodySmall,
              ),
            ],
          ),
          SizedBox(height: 12),
          GlucoseChart(
            isHourly: _mode,
            onObservationSelected: (observation) =>
                setState(() => _selectedObservation = observation),
            observations: widget.observations,
          ),
        ],
      ),
    );
  }
}
