import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/dashboard_card_widget.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/sleep/sleep_chart.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/sleep/sleep_stage_row.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/utils/extensions/date_time_extension.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

class SleepChartBox extends StatefulWidget {
  final List<Observation> observations;
  final void Function()? onLoadMore;
  final bool isLoadingMore;

  const SleepChartBox({
    super.key,
    required this.observations,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  @override
  State<SleepChartBox> createState() => _SleepChartBoxState();
}

class _SleepChartBoxState extends State<SleepChartBox> {
  Observation? _selectedObservation;

  @override
  void initState() {
    super.initState();
    _selectedObservation = SleepChart.defaultSelection(widget.observations);
    _scheduleLoadMoreIfNeeded();
  }

  @override
  void didUpdateWidget(covariant SleepChartBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.observations, widget.observations)) {
      final shouldRefresh =
          _selectedObservation == null || oldWidget.observations.isEmpty;
      if (shouldRefresh) {
        final next = SleepChart.defaultSelection(widget.observations);
        if (next != _selectedObservation) {
          _selectedObservation = next;
        }
      }
    }
    _scheduleLoadMoreIfNeeded();
  }

  void _scheduleLoadMoreIfNeeded() {
    if (widget.observations.isNotEmpty ||
        widget.onLoadMore == null ||
        widget.isLoadingMore) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.observations.isNotEmpty ||
          widget.onLoadMore == null ||
          widget.isLoadingMore) {
        return;
      }
      widget.onLoadMore!();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sleep = _selectedObservation?.data.mapOrNull(sleep: (value) => value);

    return DashboardCardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(T(context).sleep, style: context.typography.bodyLarge),
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
          const SizedBox(height: 8),
          SleepStageRow(
            color: context.theme.tertiary,
            duration: sleep == null
                ? '-'
                : SleepChart.formatDuration(sleep.deep),
            label: T(context).deepSleep,
            percent: sleep == null
                ? ''
                : SleepChart.formatPercent(sleep.deep, sleep.value),
          ),
          SleepStageRow(
            color: SleepChart.remColor,
            duration: sleep == null
                ? '-'
                : SleepChart.formatDuration(sleep.rem),
            label: T(context).rem,
            percent: sleep == null
                ? ''
                : SleepChart.formatPercent(sleep.rem, sleep.value),
          ),
          SleepStageRow(
            color: SleepChart.lightSleepColor,
            duration: sleep == null
                ? '-'
                : SleepChart.formatDuration(sleep.light),
            label: T(context).lightSleep,
            percent: sleep == null
                ? ''
                : SleepChart.formatPercent(sleep.light, sleep.value),
          ),
          const SizedBox(height: 4),
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
          const SizedBox(height: 12),
          SleepChart(
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
