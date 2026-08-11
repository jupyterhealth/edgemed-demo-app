import 'package:freezed_annotation/freezed_annotation.dart';

part 'observation_data.freezed.dart';

@freezed
abstract class ObservationData with _$ObservationData {
  const factory ObservationData.glucose({
    required double value,
    required DateTime date,
  }) = _Glucose;
  const factory ObservationData.bloodPressure({
    required double systolic,
    required double diastolic,
    required DateTime date,
  }) = _BloodPressure;
  const factory ObservationData.heartRate({
    required double value,
    required DateTime date,
  }) = _HeartRate;
  const factory ObservationData.sleep({
    required double value,
    required DateTime date,
  }) = _Sleep;
  const factory ObservationData.steps({
    required double value,
    required DateTime date,
  }) = _Steps;
  const factory ObservationData.unknown({
    required String value,
    required DateTime date,
  }) = _Unknown;
}
