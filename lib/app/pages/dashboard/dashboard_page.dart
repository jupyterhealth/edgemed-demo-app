import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jupyter_health/app/common/widgets/error_screen.dart';
import 'package:jupyter_health/app/common/widgets/loading_screen.dart';
import 'package:jupyter_health/app/common/widgets/styled_app_bar.dart';
import 'package:jupyter_health/app/common/widgets/styled_scaffold.dart';
import 'package:jupyter_health/app/pages/dashboard/cubit/dashboard_cubit.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/blood_pressure/blood_pressure_chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/empty_dashboard_widget.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/glucose/glucose_chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/sleep/sleep_chart_box.dart';
import 'package:jupyter_health/app/pages/dashboard/widget/steps/steps_chart_box.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/l10n/l10n.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';
import 'package:jupyter_health/utils/extensions/theme_extension.dart';

@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  bool _isEmpty(DashboardState state) {
    return state.maybeWhen(
      data: (glucose, bloodPressure, steps, sleep) =>
          glucose.observations.isEmpty &&
          bloodPressure.observations.isEmpty &&
          steps.observations.isEmpty &&
          sleep.observations.isEmpty,
      orElse: () => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<DashboardCubit>()..fetchObservations(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) => state.map(
          error: (value) => ErrorScreen(
            failure: value.failure,
            onRetry: () => context.read<DashboardCubit>().fetchObservations(),
          ),
          loading: (_) => const LoadingScreen(),
          data: (value) {
            final isEmpty = _isEmpty(state);
            return StyledScaffold(
              appBar: StyledAppBar(),
              scrollBody: !isEmpty,
              body: isEmpty
                  ? EmptyDashboardWidget()
                  : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 20),
                              Text(
                                T(context).welcomeToUcsfEdge,
                                style: context.typography.headerMedium,
                              ),
                              Text(
                                T(context).currentHealthData,
                                style: context.typography.bodyLarge,
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                          GlucoseChartBox(
                            observations: value.glucose.observations,
                            isLoadingMore: value.glucose.isLoadingMore,
                            onLoadMore: value.glucose.hasMore
                                ? () => context.read<DashboardCubit>().loadMore(
                                    ObservationType.glucose,
                                  )
                                : null,
                          ),

                          StepsChartBox(
                            observations: value.steps.observations,
                            isLoadingMore: value.steps.isLoadingMore,
                            onLoadMore: value.steps.hasMore
                                ? () => context.read<DashboardCubit>().loadMore(
                                    ObservationType.steps,
                                  )
                                : null,
                          ),
                          SleepChartBox(
                            observations: value.sleep.observations,
                            isLoadingMore: value.sleep.isLoadingMore,
                            onLoadMore: value.sleep.hasMore
                                ? () => context.read<DashboardCubit>().loadMore(
                                    ObservationType.sleep,
                                  )
                                : null,
                          ),
                          BloodPressureChartBox(
                            observations: value.bloodPressure.observations,
                            isLoadingMore: value.bloodPressure.isLoadingMore,
                            onLoadMore: value.bloodPressure.hasMore
                                ? () => context.read<DashboardCubit>().loadMore(
                                    ObservationType.bloodPressure,
                                  )
                                : null,
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}
