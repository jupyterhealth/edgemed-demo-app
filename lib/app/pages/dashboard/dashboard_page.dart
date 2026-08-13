import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/pages/dashboard/cubit/dashboard_cubit.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/blood_pressure/blood_pressure_chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/glucose/glucose_chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/steps/steps_chart_box.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DashboardCubit>()..fetchObservations(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => StyledScaffold(
          appBar: StyledAppBar(),
          scrollBody: true,
          body: Center(
            child: state.map(
              loading: (_) => const CircularProgressIndicator(),
              error: (value) =>
                  Text(value.failure.message ?? 'Something went wrong'),
              data: (value) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  Text('Dashboard'),
                  GlucoseChartBox(observations: value.observations),
                  BloodPressureChartBox(observations: value.observations),
                  StepsChartBox(observations: value.observations),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
