part of 'dashboard_cubit.dart';

@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.data(List<Observation> observations) = _Loaded;
  const factory DashboardState.error(Failure failure) = _Error;
}
