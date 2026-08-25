import 'package:freezed_annotation/freezed_annotation.dart';

part 'fhir_source_dto.freezed.dart';
part 'fhir_source_dto.g.dart';

@freezed
abstract class RegisterFhirSourceRequestDto
    with _$RegisterFhirSourceRequestDto {
  const factory RegisterFhirSourceRequestDto({
    required String label,
    @JsonKey(name: 'fhir_base_url') required String fhirBaseUrl,
    @JsonKey(name: 'data_source') required int dataSource,
  }) = _RegisterFhirSourceRequestDto;

  factory RegisterFhirSourceRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RegisterFhirSourceRequestDtoFromJson(json);
}

@freezed
abstract class FhirSourceDto with _$FhirSourceDto {
  const factory FhirSourceDto({required int id}) = _FhirSourceDto;

  factory FhirSourceDto.fromJson(Map<String, dynamic> json) =>
      _$FhirSourceDtoFromJson(json);
}
