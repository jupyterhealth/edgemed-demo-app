import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/consents/consent_item.dart';
import 'package:jupyter_health/domain/entity/consents/patient_consents.dart';

part 'patient_consents_dto.freezed.dart';
part 'patient_consents_dto.g.dart';

@freezed
abstract class PatientConsentsDto with _$PatientConsentsDto {
  const PatientConsentsDto._();

  const factory PatientConsentsDto({
    @Default([]) List<StudyConsentDto> studiesPendingConsent,
    @Default([]) List<StudyConsentDto> studies,
  }) = _PatientConsentsDto;

  factory PatientConsentsDto.fromJson(Map<String, dynamic> json) =>
      _$PatientConsentsDtoFromJson(json);

  PatientConsents toDomain() {
    final consented = <ConsentItem>[];
    final pending = <ConsentItem>[];

    void collect(StudyConsentDto study, List<ScopeConsentDto> scopes) {
      for (final scope in scopes) {
        final item = ConsentItem(
          studyId: study.id,
          studyName: study.name,
          codeId: scope.code.id,
          text: scope.code.text,
          codingSystem: scope.code.codingSystem,
          codingCode: scope.code.codingCode,
        );
        if (scope.consented == true) {
          consented.add(item);
        } else {
          pending.add(item);
        }
      }
    }

    for (final study in studies) {
      collect(study, study.scopeConsents);
    }
    for (final study in studiesPendingConsent) {
      collect(study, study.pendingScopeConsents);
    }

    return PatientConsents(consented: consented, pending: pending);
  }
}

@freezed
abstract class StudyConsentDto with _$StudyConsentDto {
  const factory StudyConsentDto({
    required int id,
    required String name,
    String? description,
    @Default([]) List<ScopeConsentDto> pendingScopeConsents,
    @Default([]) List<ScopeConsentDto> scopeConsents,
  }) = _StudyConsentDto;

  factory StudyConsentDto.fromJson(Map<String, dynamic> json) =>
      _$StudyConsentDtoFromJson(json);
}

@freezed
abstract class ScopeConsentDto with _$ScopeConsentDto {
  const factory ScopeConsentDto({
    required ConsentCodeDto code,
    bool? consented,
    DateTime? consentedTime,
  }) = _ScopeConsentDto;

  factory ScopeConsentDto.fromJson(Map<String, dynamic> json) =>
      _$ScopeConsentDtoFromJson(json);
}

@freezed
abstract class ConsentCodeDto with _$ConsentCodeDto {
  const factory ConsentCodeDto({
    required int id,
    required String codingSystem,
    required String codingCode,
    required String text,
  }) = _ConsentCodeDto;

  factory ConsentCodeDto.fromJson(Map<String, dynamic> json) =>
      _$ConsentCodeDtoFromJson(json);
}
