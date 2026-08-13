import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/blood_pressure/blood_pressure_chart.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/mode_switch.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/utils/extensions/date_time_extension.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class BloodPressureChartBox extends StatefulWidget {
  final List<Observation> observations;
  const BloodPressureChartBox({super.key, required this.observations});

  @override
  State<BloodPressureChartBox> createState() => _BloodPressureChartBoxState();
}

class _BloodPressureChartBoxState extends State<BloodPressureChartBox> {
  late Observation _selectedObservation;
  bool _mode = true;

  @override
  void initState() {
    super.initState();
    _selectedObservation = widget.observations.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme;
    final bp = _selectedObservation.data.mapOrNull(
      bloodPressure: (value) => value,
    );

    return ChartBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Blood Pressure', style: context.typography.bodyLarge),
              ModeSwitch(
                value: _mode,
                onChanged: (value) => setState(() => _mode = value),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: context.theme.primary,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: bp?.systolic.toStringAsFixed(0) ?? '-',
                              style: context.typography.headerLarge,
                            ),
                            TextSpan(
                              text: ' SYS/mmHg',
                              style: context.typography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    spacing: 8,
                    children: [
                      CircleAvatar(
                        radius: 6,
                        backgroundColor: BloodPressureChart.diastolicColor,
                      ),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: bp?.diastolic.toStringAsFixed(0) ?? '-',
                              style: context.typography.headerLarge,
                            ),
                            TextSpan(
                              text: ' DIA/mmHg',
                              style: context.typography.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'measured: ${_selectedObservation.date.toMeasuredLabel(isHourly: _mode)}',
                style: context.typography.bodySmall.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          BloodPressureChart(
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
