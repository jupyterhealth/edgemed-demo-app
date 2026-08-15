import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/glucose/glucose_chart.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/mode_switch.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/utils/extensions/date_time_extension.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class GlucoseChartBox extends StatefulWidget {
  final List<Observation> observations;
  final void Function()? onLoadMore;
  final bool isLoadingMore;

  const GlucoseChartBox({
    super.key,
    required this.observations,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  @override
  State<GlucoseChartBox> createState() => _GlucoseChartBoxState();
}

class _GlucoseChartBoxState extends State<GlucoseChartBox> {
  bool _mode = true;
  Observation? _selectedObservation;

  @override
  void initState() {
    super.initState();
    _selectedObservation = widget.observations.firstOrNull;
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
              Row(
                children: [
                  Text(T(context).glucose, style: context.typography.bodyLarge),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          _selectedObservation?.data.mapOrNull(
                            glucose: (value) => value.value.toStringAsFixed(0),
                          ) ??
                          '-',
                      style: context.typography.headerLarge,
                    ),
                    TextSpan(
                      text: ' ${T(context).glucoseUnit}',
                      style: context.typography.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                _selectedObservation == null
                    ? ''
                    : T(context).measured(
                        _selectedObservation!.date.toMeasuredLabel(
                          isHourly: _mode,
                        ),
                      ),
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
            onLoadMore: widget.onLoadMore,
          ),
        ],
      ),
    );
  }
}
