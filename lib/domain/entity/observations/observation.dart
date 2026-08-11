import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';

part 'observation.freezed.dart';

@freezed
abstract class Observation with _$Observation {
  const factory Observation({
    required String id,
    required ObservationType type,
    required ObservationData data,
    required DateTime date,
  }) = _Observation;
}
