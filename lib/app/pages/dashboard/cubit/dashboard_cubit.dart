import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_feed.dart';
import 'package:jupyter_health/domain/entity/observations/observation_page.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';

part 'dashboard_state.dart';
part 'dashboard_cubit.freezed.dart';

@Injectable()
class DashboardCubit extends Cubit<DashboardState> {
  final ApiRepository _apiRepository;
  var _requestGeneration = 0;

  DashboardCubit(this._apiRepository) : super(DashboardState.loading());

  static const _chartTypes = [
    ObservationType.glucose,
    ObservationType.bloodPressure,
    ObservationType.steps,
    ObservationType.sleep,
  ];

  Future<void> fetchObservations() async {
    final generation = ++_requestGeneration;
    emit(DashboardState.loading());

    final results = await Future.wait([
      for (final type in _chartTypes)
        _apiRepository.getObservations(type: type),
    ]);

    if (generation != _requestGeneration) return;

    final feeds = <ObservationType, ObservationFeed>{};
    for (var i = 0; i < _chartTypes.length; i++) {
      final feed = results[i].fold<ObservationFeed?>((error) {
        emit(DashboardState.error(error));
        return null;
      }, _feedFromPage);
      if (feed == null) return;
      feeds[_chartTypes[i]] = feed;
    }

    emit(
      DashboardState.data(
        glucose: feeds[ObservationType.glucose] ?? const ObservationFeed(),
        bloodPressure:
            feeds[ObservationType.bloodPressure] ?? const ObservationFeed(),
        steps: feeds[ObservationType.steps] ?? const ObservationFeed(),
        sleep: feeds[ObservationType.sleep] ?? const ObservationFeed(),
      ),
    );
  }

  Future<void> loadMore(ObservationType type) async {
    final loaded = state.mapOrNull(data: (value) => value);
    if (loaded == null) return;

    final feed = _feedOf(loaded, type);
    final nextUrls = feed.nextUrls;
    if (nextUrls.isEmpty || feed.isLoadingMore) return;

    final generation = _requestGeneration;
    emit(_withFeed(loaded, type, feed.copyWith(isLoadingMore: true)));

    final remaining = <String, String>{};
    var observations = feed.observations;

    for (final entry in nextUrls.entries) {
      if (generation != _requestGeneration) return;

      final result = await _apiRepository.getObservations(
        type: type,
        nextUrls: {entry.key: entry.value},
      );
      if (generation != _requestGeneration) return;

      final page = result.fold<ObservationPage?>((error) {
        emit(DashboardState.error(error));
        return null;
      }, (value) => value);
      if (page == null) return;

      observations = _mergeObservations(observations, page.observations);
      remaining.addAll(page.nextUrls);
    }

    if (generation != _requestGeneration) return;

    final latest = state.mapOrNull(data: (value) => value);
    if (latest == null) return;

    emit(
      _withFeed(
        latest,
        type,
        _feedOf(latest, type).copyWith(
          observations: observations,
          nextUrls: remaining,
          isLoadingMore: false,
        ),
      ),
    );
  }

  ObservationFeed _feedFromPage(ObservationPage page) =>
      ObservationFeed(observations: page.observations, nextUrls: page.nextUrls);

  ObservationFeed _feedOf(_Loaded state, ObservationType type) =>
      switch (type) {
        ObservationType.glucose => state.glucose,
        ObservationType.bloodPressure => state.bloodPressure,
        ObservationType.steps => state.steps,
        ObservationType.sleep => state.sleep,
        ObservationType.unknown => const ObservationFeed(),
      };

  DashboardState _withFeed(
    _Loaded state,
    ObservationType type,
    ObservationFeed feed,
  ) => switch (type) {
    ObservationType.glucose => state.copyWith(glucose: feed),
    ObservationType.bloodPressure => state.copyWith(bloodPressure: feed),
    ObservationType.steps => state.copyWith(steps: feed),
    ObservationType.sleep => state.copyWith(sleep: feed),
    ObservationType.unknown => state,
  };

  List<Observation> _mergeObservations(
    List<Observation> current,
    List<Observation> incoming,
  ) {
    final existingIds = {for (final observation in current) observation.id};
    return [
      ...current,
      for (final observation in incoming)
        if (!existingIds.contains(observation.id)) observation,
    ];
  }
}
