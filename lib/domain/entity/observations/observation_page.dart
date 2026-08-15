import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';

part 'observation_page.freezed.dart';

@freezed
abstract class ObservationPage with _$ObservationPage {
  const factory ObservationPage({
    @Default([]) List<Observation> observations,
    @Default(<String, String>{}) Map<String, String> nextUrls,
  }) = _ObservationPage;
}
