import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/pages/dashboard/cubit/dashboard_cubit.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/glucose/glucose_chart_box.dart';
import 'package:jupyter_health/config/di/injectable.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DashboardCubit>()..fetchObservations(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => Scaffold(
          body: Center(
            child: state.map(
              loading: (_) => const CircularProgressIndicator(),
              error: (value) =>
                  Text(value.failure.message ?? 'Something went wrong'),
              data: (value) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [GlucoseChartBox()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
