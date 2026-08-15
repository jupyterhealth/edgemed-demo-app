import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';

part 'observation_feed.freezed.dart';

@freezed
abstract class ObservationFeed with _$ObservationFeed {
  const ObservationFeed._();

  const factory ObservationFeed({
    @Default([]) List<Observation> observations,
    @Default(<String, String>{}) Map<String, String> nextUrls,
    @Default(false) bool isLoadingMore,
  }) = _ObservationFeed;

  bool get hasMore => nextUrls.isNotEmpty;
}
