import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';

part 'omh_data_point_dto.freezed.dart';
part 'omh_data_point_dto.g.dart';

@freezed
abstract class OmhDataPointDto with _$OmhDataPointDto {
  const OmhDataPointDto._();

  const factory OmhDataPointDto({
    required OmhHeaderDto header,
    required OmhBodyDto body,
  }) = _OmhDataPointDto;

  factory OmhDataPointDto.fromJson(Map<String, dynamic> json) =>
      _$OmhDataPointDtoFromJson(json);

  ObservationType get observationType =>
      ObservationType.fromOmhCode(header.schemaId.name);
}

@freezed
abstract class OmhHeaderDto with _$OmhHeaderDto {
  const factory OmhHeaderDto({
    required String uuid,
    String? modality,
    @JsonKey(name: 'schema_id') required OmhSchemaIdDto schemaId,
    @JsonKey(name: 'external_datasheets')
    List<OmhExternalDatasheetDto>? externalDatasheets,
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
    required String version,
    required String namespace,
  }) = _OmhSchemaIdDto;

  factory OmhSchemaIdDto.fromJson(Map<String, dynamic> json) =>
      _$OmhSchemaIdDtoFromJson(json);
}

@freezed
abstract class OmhExternalDatasheetDto with _$OmhExternalDatasheetDto {
  const factory OmhExternalDatasheetDto({
    @JsonKey(name: 'datasheet_type') required String datasheetType,
    @JsonKey(name: 'datasheet_reference') required String datasheetReference,
  }) = _OmhExternalDatasheetDto;

  factory OmhExternalDatasheetDto.fromJson(Map<String, dynamic> json) =>
      _$OmhExternalDatasheetDtoFromJson(json);
}

@freezed
abstract class OmhBodyDto with _$OmhBodyDto {
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
  }) = _OmhBodyDto;

  factory OmhBodyDto.fromJson(Map<String, dynamic> json) =>
      _$OmhBodyDtoFromJson(json);
}

@freezed
abstract class OmhUnitValueDto with _$OmhUnitValueDto {
  const factory OmhUnitValueDto({
    required String unit,
    required double value,
  }) = _OmhUnitValueDto;

  factory OmhUnitValueDto.fromJson(Map<String, dynamic> json) =>
      _$OmhUnitValueDtoFromJson(json);
}

@freezed
abstract class OmhEffectiveTimeFrameDto with _$OmhEffectiveTimeFrameDto {
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
