import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/data/dto/jhe/open_mhealth/omh_data_point_dto.dart';
import 'package:jupyter_health/data/utils/converters.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';

part 'observation_dto.freezed.dart';
part 'observation_dto.g.dart';

@freezed
abstract class ObservationBundleDto with _$ObservationBundleDto {
  const factory ObservationBundleDto({
    required String resourceType,
    required String type,
    required int total,
    List<ObservationBundleEntryDto>? entry,
    List<FhirLinkDto>? link,
    FhirMetaDto? meta,
  }) = _ObservationBundleDto;

  factory ObservationBundleDto.fromJson(Map<String, dynamic> json) =>
      _$ObservationBundleDtoFromJson(json);
}

@freezed
abstract class ObservationBundleEntryDto with _$ObservationBundleEntryDto {
  const factory ObservationBundleEntryDto({
    required ObservationDto resource,
  }) = _ObservationBundleEntryDto;

  factory ObservationBundleEntryDto.fromJson(Map<String, dynamic> json) =>
      _$ObservationBundleEntryDtoFromJson(json);
}

@freezed
abstract class ObservationDto with _$ObservationDto {
  const ObservationDto._();

  const factory ObservationDto({
    required String resourceType,
    required String id,
    required String status,
    required FhirCodeableConceptDto code,
    required DateTime effectiveDateTime,
    required FhirReferenceDto subject,
    required FhirValueAttachmentDto valueAttachment,
    FhirMetaDto? meta,
  }) = _ObservationDto;

  factory ObservationDto.fromJson(Map<String, dynamic> json) =>
      _$ObservationDtoFromJson(json);

  /// Prefer FHIR coding code (`omh:heart-rate:2.0`) over display.
  ObservationType get observationType =>
      ObservationType.fromOmhCode(code.coding?.firstOrNull?.code);
}

@freezed
abstract class FhirMetaDto with _$FhirMetaDto {
  const factory FhirMetaDto({
    DateTime? lastUpdated,
    String? source,
  }) = _FhirMetaDto;

  factory FhirMetaDto.fromJson(Map<String, dynamic> json) =>
      _$FhirMetaDtoFromJson(json);
}

@freezed
abstract class FhirCodeableConceptDto with _$FhirCodeableConceptDto {
  const factory FhirCodeableConceptDto({
    List<FhirCodingDto>? coding,
  }) = _FhirCodeableConceptDto;

  factory FhirCodeableConceptDto.fromJson(Map<String, dynamic> json) =>
      _$FhirCodeableConceptDtoFromJson(json);
}

@freezed
abstract class FhirCodingDto with _$FhirCodingDto {
  const factory FhirCodingDto({
    String? system,
    String? code,
    String? display,
  }) = _FhirCodingDto;

  factory FhirCodingDto.fromJson(Map<String, dynamic> json) =>
      _$FhirCodingDtoFromJson(json);
}

@freezed
abstract class FhirReferenceDto with _$FhirReferenceDto {
  const factory FhirReferenceDto({
    String? reference,
    FhirIdentifierDto? identifier,
  }) = _FhirReferenceDto;

  factory FhirReferenceDto.fromJson(Map<String, dynamic> json) =>
      _$FhirReferenceDtoFromJson(json);
}

@freezed
abstract class FhirIdentifierDto with _$FhirIdentifierDto {
  const factory FhirIdentifierDto({
    String? system,
    String? value,
  }) = _FhirIdentifierDto;

  factory FhirIdentifierDto.fromJson(Map<String, dynamic> json) =>
      _$FhirIdentifierDtoFromJson(json);
}

@freezed
abstract class FhirValueAttachmentDto with _$FhirValueAttachmentDto {
  const factory FhirValueAttachmentDto({
    String? contentType,
    @Base64JsonConverter() OmhDataPointDto? data,
  }) = _FhirValueAttachmentDto;

  factory FhirValueAttachmentDto.fromJson(Map<String, dynamic> json) =>
      _$FhirValueAttachmentDtoFromJson(json);
}

@freezed
abstract class FhirLinkDto with _$FhirLinkDto {
  const factory FhirLinkDto({
    String? relation,
    String? url,
  }) = _FhirLinkDto;

  factory FhirLinkDto.fromJson(Map<String, dynamic> json) =>
      _$FhirLinkDtoFromJson(json);
}
