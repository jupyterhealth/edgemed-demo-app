import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/dashboard_card_widget.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/steps/steps_chart.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/utils/extensions/date_time_extension.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class StepsChartBox extends StatefulWidget {
  final List<Observation> observations;
  final void Function()? onLoadMore;
  final bool isLoadingMore;

  const StepsChartBox({
    super.key,
    required this.observations,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  @override
  State<StepsChartBox> createState() => _StepsChartBoxState();
}

class _StepsChartBoxState extends State<StepsChartBox> {
  Observation? _selectedObservation;

  @override
  void initState() {
    super.initState();
    _selectedObservation = widget.observations.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return DashboardCardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(T(context).steps, style: context.typography.bodyLarge),
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
                          _selectedObservation?.data.mapOrNull(
                            steps: (value) => value.value.toStringAsFixed(0),
                          ) ??
                          '-',
                      style: context.typography.headerLarge,
                    ),
                    TextSpan(
                      text: ' ${T(context).stepsUnit}',
                      style: context.typography.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                _selectedObservation == null
                    ? ''
                    : T(
                        context,
                      ).measured(_selectedObservation!.date.toMeasuredLabel()),
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
            onLoadMore: widget.onLoadMore,
          ),
        ],
      ),
    );
  }
}
