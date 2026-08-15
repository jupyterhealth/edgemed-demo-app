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
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OmhHeaderDto({
    required String uuid,
    String? modality,
    required OmhSchemaIdDto schemaId,
    List<OmhExternalDatasheetDto>? externalDatasheets,
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
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OmhExternalDatasheetDto({
    required String datasheetType,
    required String datasheetReference,
  }) = _OmhExternalDatasheetDto;

  factory OmhExternalDatasheetDto.fromJson(Map<String, dynamic> json) =>
      _$OmhExternalDatasheetDtoFromJson(json);
}

@freezed
abstract class OmhBodyDto with _$OmhBodyDto {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OmhBodyDto({
    OmhEffectiveTimeFrameDto? effectiveTimeFrame,
    OmhUnitValueDto? heartRate,
    OmhUnitValueDto? systolicBloodPressure,
    OmhUnitValueDto? diastolicBloodPressure,
    OmhUnitValueDto? bloodGlucose,
    OmhUnitValueDto? stepCount,
    OmhUnitValueDto? sleepDuration,
    OmhUnitValueDto? totalSleepTime,
    OmhUnitValueDto? lightSleepDuration,
    OmhUnitValueDto? deepSleepDuration,
    OmhUnitValueDto? remSleepDuration,
    OmhUnitValueDto? baseMovementQuantity,
  }) = _OmhBodyDto;

  factory OmhBodyDto.fromJson(Map<String, dynamic> json) =>
      _$OmhBodyDtoFromJson(json);
}

@freezed
abstract class OmhUnitValueDto with _$OmhUnitValueDto {
  const factory OmhUnitValueDto({required String unit, required double value}) =
      _OmhUnitValueDto;

  factory OmhUnitValueDto.fromJson(Map<String, dynamic> json) =>
      _$OmhUnitValueDtoFromJson(json);
}

@freezed
abstract class OmhEffectiveTimeFrameDto with _$OmhEffectiveTimeFrameDto {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OmhEffectiveTimeFrameDto({
    DateTime? dateTime,
    OmhTimeIntervalDto? timeInterval,
  }) = _OmhEffectiveTimeFrameDto;

  factory OmhEffectiveTimeFrameDto.fromJson(Map<String, dynamic> json) =>
      _$OmhEffectiveTimeFrameDtoFromJson(json);
}

@freezed
abstract class OmhTimeIntervalDto with _$OmhTimeIntervalDto {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory OmhTimeIntervalDto({
    DateTime? startDateTime,
    DateTime? endDateTime,
  }) = _OmhTimeIntervalDto;

  factory OmhTimeIntervalDto.fromJson(Map<String, dynamic> json) =>
      _$OmhTimeIntervalDtoFromJson(json);
}
