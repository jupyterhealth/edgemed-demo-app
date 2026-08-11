import 'dart:math';

import 'package:flutter/material.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/glucose/glucose_chart.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/mode_switch.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';

class GlucoseChartBox extends StatefulWidget {
  const GlucoseChartBox({super.key});

  @override
  State<GlucoseChartBox> createState() => _GlucoseChartBoxState();
}

class _GlucoseChartBoxState extends State<GlucoseChartBox> {
  late Observation _selectedObservation;
  bool _mode = true;

  @override
  void initState() {
    super.initState();
    _selectedObservation = _generateObservations().first;
  }

  List<Observation> _generateObservations() {
    final observations = <Observation>[];
    final random = Random();
    for (int i = 0; i < 1000; i++) {
      observations.add(
        Observation(
          id: '${i + 1}',
          type: ObservationType.glucose,
          data: ObservationData.glucose(
            value: random.nextInt(20).toDouble() + 20,
            date: DateTime(2026, 1, 1, 0, 0, 0).add(Duration(minutes: i * 15)),
          ),
          date: DateTime(2026, 1, 1, 0, 0, 0).add(Duration(minutes: i * 15)),
        ),
      );
    }
    return observations;
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
              Text('Glucose'),
              ModeSwitch(
                value: _mode,
                onChanged: (value) => setState(() => _mode = value),
              ),
            ],
          ),

          Row(
            children: [
              Expanded(
                child: Text(
                  '${_selectedObservation.data.mapOrNull(glucose: (value) => value.value.toStringAsFixed(0))} mg/dL',
                ),
              ),
              Expanded(
                child: Text(
                  'measured: ${_selectedObservation.date.toLocal().toString()}',
                ),
              ),
            ],
          ),
          GlucoseChart(
            isHourly: _mode,
            onObservationSelected: (observation) =>
                setState(() => _selectedObservation = observation),
            observations: _generateObservations(),
          ),
        ],
      ),
    );
  }
}
