import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_data.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';

part 'omh_data_point_dto.freezed.dart';
part 'omh_data_point_dto.g.dart';

@freezed
abstract class OmhDataPointDto with _$OmhDataPointDto {
  const OmhDataPointDto._();

  @JsonSerializable(explicitToJson: true)
  const factory OmhDataPointDto({
    required OmhHeaderDto header,
    required OmhBodyDto body,
  }) = _OmhDataPointDto;

  factory OmhDataPointDto.fromJson(Map<String, dynamic> json) =>
      _$OmhDataPointDtoFromJson(json);

  ObservationType get observationType =>
      ObservationType.fromOmhCode(header.schemaId.name);

  ObservationData toDomain({required DateTime fallbackDate}) {
    final date =
        body.effectiveTimeFrame?.dateTime ??
        body.effectiveTimeFrame?.timeInterval?.startDateTime ??
        fallbackDate;

    return switch (observationType) {
      ObservationType.glucose when body.bloodGlucose != null =>
        ObservationData.glucose(value: body.bloodGlucose!.value, date: date),
      ObservationType.bloodPressure
          when body.systolicBloodPressure != null &&
              body.diastolicBloodPressure != null =>
        ObservationData.bloodPressure(
          systolic: body.systolicBloodPressure!.value,
          diastolic: body.diastolicBloodPressure!.value,
          date: date,
        ),
      ObservationType.sleep => _toSleep(body, date),
      ObservationType.steps when _stepsValue(body) != null =>
        ObservationData.steps(value: _stepsValue(body)!, date: date),
      _ => ObservationData.unknown(value: header.schemaId.name, date: date),
    };
  }

  static ObservationData _toSleep(OmhBodyDto body, DateTime date) {
    final deep = _optionalSleepHours(body.deepSleepDuration);
    final rem = _optionalSleepHours(body.remSleepDuration);
    final light = _optionalSleepHours(body.lightSleepDuration);
    final totalDuration = body.totalSleepTime ?? body.sleepDuration;
    final total = totalDuration != null
        ? _sleepHours(totalDuration)
        : deep + rem + light;

    return ObservationData.sleep(
      value: total,
      date: date,
      deep: deep,
      rem: rem,
      light: light,
    );
  }

  static double? _stepsValue(OmhBodyDto body) {
    final quantity = body.baseMovementQuantity;
    if (quantity != null && quantity.unit?.toLowerCase() == 'steps') {
      return quantity.value;
    }
    return body.stepCount?.value;
  }

  static double _optionalSleepHours(OmhUnitValueDto? duration) =>
      duration == null ? 0 : _sleepHours(duration);

  static double _sleepHours(OmhUnitValueDto duration) {
    final value = duration.value;
    return switch (duration.unit?.toLowerCase()) {
      'min' || 'minute' || 'minutes' => value / 60,
      'sec' || 's' || 'second' || 'seconds' => value / 3600,
      'ms' => value / 3600000,
      'd' || 'day' || 'days' => value * 24,
      'h' || 'hr' || 'hour' || 'hours' => value,
      _ => value > 24 ? value / 60 : value,
    };
  }
}

@freezed
abstract class OmhHeaderDto with _$OmhHeaderDto {
  @JsonSerializable(explicitToJson: true)
  const factory OmhHeaderDto({
    String? uuid,
    String? modality,
    @JsonKey(name: 'schema_id') required OmhSchemaIdDto schemaId,
    @JsonKey(name: 'external_datasheets')
    @Default([])
    List<OmhExternalDatasheetDto> externalDatasheets,
    @JsonKey(name: 'source_creation_date_time')
    DateTime? sourceCreationDateTime,
  }) = _OmhHeaderDto;

  factory OmhHeaderDto.fromJson(Map<String, dynamic> json) =>
      _$OmhHeaderDtoFromJson(json);
}

@freezed
abstract class OmhSchemaIdDto with _$OmhSchemaIdDto {
  const factory OmhSchemaIdDto({
    required String name,
    String? version,
    String? namespace,
  }) = _OmhSchemaIdDto;

  factory OmhSchemaIdDto.fromJson(Map<String, dynamic> json) =>
      _$OmhSchemaIdDtoFromJson(json);
}

@freezed
abstract class OmhExternalDatasheetDto with _$OmhExternalDatasheetDto {
  const factory OmhExternalDatasheetDto({
    @JsonKey(name: 'datasheet_type') String? datasheetType,
    @JsonKey(name: 'datasheet_reference') String? datasheetReference,
  }) = _OmhExternalDatasheetDto;

  factory OmhExternalDatasheetDto.fromJson(Map<String, dynamic> json) =>
      _$OmhExternalDatasheetDtoFromJson(json);
}

@freezed
abstract class OmhBodyDto with _$OmhBodyDto {
  @JsonSerializable(explicitToJson: true)
  const factory OmhBodyDto({
    @JsonKey(name: 'effective_time_frame')
    OmhEffectiveTimeFrameDto? effectiveTimeFrame,
    @JsonKey(name: 'heart_rate') OmhUnitValueDto? heartRate,
    @JsonKey(name: 'systolic_blood_pressure')
    OmhUnitValueDto? systolicBloodPressure,
    @JsonKey(name: 'diastolic_blood_pressure')
    OmhUnitValueDto? diastolicBloodPressure,
    @JsonKey(name: 'blood_glucose') OmhUnitValueDto? bloodGlucose,
    @JsonKey(name: 'step_count') OmhUnitValueDto? stepCount,
    @JsonKey(name: 'sleep_duration') OmhUnitValueDto? sleepDuration,
    @JsonKey(name: 'total_sleep_time') OmhUnitValueDto? totalSleepTime,
    @JsonKey(name: 'light_sleep_duration') OmhUnitValueDto? lightSleepDuration,
    @JsonKey(name: 'deep_sleep_duration') OmhUnitValueDto? deepSleepDuration,
    @JsonKey(name: 'rem_sleep_duration') OmhUnitValueDto? remSleepDuration,
    @JsonKey(name: 'base_movement_quantity')
    OmhUnitValueDto? baseMovementQuantity,
  }) = _OmhBodyDto;

  factory OmhBodyDto.fromJson(Map<String, dynamic> json) =>
      _$OmhBodyDtoFromJson(json);
}

@freezed
abstract class OmhUnitValueDto with _$OmhUnitValueDto {
  const factory OmhUnitValueDto({String? unit, required double value}) =
      _OmhUnitValueDto;

  factory OmhUnitValueDto.fromJson(Map<String, dynamic> json) =>
      _$OmhUnitValueDtoFromJson(json);
}

@freezed
abstract class OmhEffectiveTimeFrameDto with _$OmhEffectiveTimeFrameDto {
  @JsonSerializable(explicitToJson: true)
  const factory OmhEffectiveTimeFrameDto({
    @JsonKey(name: 'date_time') DateTime? dateTime,
    @JsonKey(name: 'time_interval') OmhTimeIntervalDto? timeInterval,
  }) = _OmhEffectiveTimeFrameDto;

  factory OmhEffectiveTimeFrameDto.fromJson(Map<String, dynamic> json) =>
      _$OmhEffectiveTimeFrameDtoFromJson(json);
}

@freezed
abstract class OmhTimeIntervalDto with _$OmhTimeIntervalDto {
  const factory OmhTimeIntervalDto({
    @JsonKey(name: 'start_date_time') DateTime? startDateTime,
    @JsonKey(name: 'end_date_time') DateTime? endDateTime,
  }) = _OmhTimeIntervalDto;

  factory OmhTimeIntervalDto.fromJson(Map<String, dynamic> json) =>
      _$OmhTimeIntervalDtoFromJson(json);
}
