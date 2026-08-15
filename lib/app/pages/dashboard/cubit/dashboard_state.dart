part of 'dashboard_cubit.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.data({
    required ObservationFeed glucose,
    required ObservationFeed bloodPressure,
    required ObservationFeed steps,
    required ObservationFeed sleep,
  }) = _Loaded;
  const factory DashboardState.error(Failure failure) = _Error;
}
