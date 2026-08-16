import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jupyter_health/domain/entity/consents/consent_item.dart';

part 'patient_consents.freezed.dart';

@freezed
abstract class PatientConsents with _$PatientConsents {
  const factory PatientConsents({
    @Default([]) List<ConsentItem> consented,
    @Default([]) List<ConsentItem> pending,
  }) = _PatientConsents;
}
