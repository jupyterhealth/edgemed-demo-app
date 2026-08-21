import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/blood_pressure/blood_pressure_chart.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/mode_switch.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/utils/extensions/date_time_extension.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class BloodPressureChartBox extends StatefulWidget {
  final List<Observation> observations;
  final bool isLoadingMore;
  final void Function()? onLoadMore;

  const BloodPressureChartBox({
    super.key,
    required this.observations,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  @override
  State<BloodPressureChartBox> createState() => _BloodPressureChartBoxState();
}

class _BloodPressureChartBoxState extends State<BloodPressureChartBox> {
  Observation? _selectedObservation;
  bool _mode = true;

  @override
  void initState() {
    super.initState();
    _selectedObservation = widget.observations.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme;
    final bp = _selectedObservation?.data.mapOrNull(
      bloodPressure: (value) => value,
    );

    return ChartBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    T(context).bloodPressure,
                    style: context.typography.bodyLarge,
                  ),
                  if (widget.isLoadingMore) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
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
                              style: context.typography.headerMedium,
                            ),
                            TextSpan(
                              text: ' ${T(context).systolicUnit}',
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
                              style: context.typography.headerMedium,
                            ),
                            TextSpan(
                              text: ' ${T(context).diastolicUnit}',
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
                _selectedObservation == null
                    ? ''
                    : T(context).measured(
                        _selectedObservation!.date.toMeasuredLabel(
                          isHourly: _mode,
                        ),
                      ),
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
            onLoadMore: widget.onLoadMore,
          ),
        ],
      ),
    );
  }
}
