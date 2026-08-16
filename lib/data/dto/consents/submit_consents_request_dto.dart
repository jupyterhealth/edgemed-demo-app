import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/consents/consent_item.dart';

part 'submit_consents_request_dto.freezed.dart';
part 'submit_consents_request_dto.g.dart';

@freezed
abstract class SubmitConsentsRequestDto with _$SubmitConsentsRequestDto {
  const SubmitConsentsRequestDto._();

  const factory SubmitConsentsRequestDto({
    required List<StudyScopeConsentsRequestDto> studyScopeConsents,
  }) = _SubmitConsentsRequestDto;

  factory SubmitConsentsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SubmitConsentsRequestDtoFromJson(json);

  factory SubmitConsentsRequestDto.fromConsentItems(List<ConsentItem> items) {
    final grouped = <int, List<ConsentItem>>{};
    for (final item in items) {
      grouped.putIfAbsent(item.studyId, () => []).add(item);
    }

    return SubmitConsentsRequestDto(
      studyScopeConsents: [
        for (final entry in grouped.entries)
          StudyScopeConsentsRequestDto(
            studyId: entry.key,
            scopeConsents: [
              for (final item in entry.value)
                ScopeConsentRequestDto(
                  codingSystem: item.codingSystem,
                  codingCode: item.codingCode,
                  consented: true,
                ),
            ],
          ),
      ],
    );
  }
}

@freezed
abstract class StudyScopeConsentsRequestDto
    with _$StudyScopeConsentsRequestDto {
  const factory StudyScopeConsentsRequestDto({
    required int studyId,
    required List<ScopeConsentRequestDto> scopeConsents,
  }) = _StudyScopeConsentsRequestDto;

  factory StudyScopeConsentsRequestDto.fromJson(Map<String, dynamic> json) =>
      _$StudyScopeConsentsRequestDtoFromJson(json);
}

@freezed
abstract class ScopeConsentRequestDto with _$ScopeConsentRequestDto {
  const factory ScopeConsentRequestDto({
    required String codingSystem,
    required String codingCode,
    required bool consented,
  }) = _ScopeConsentRequestDto;

  factory ScopeConsentRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ScopeConsentRequestDtoFromJson(json);
}
