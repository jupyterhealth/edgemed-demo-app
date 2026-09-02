part of 'consents_cubit.dart';

@freezed
class ConsentsState with _$ConsentsState {
  const factory ConsentsState.initial() = _Initial;
  const factory ConsentsState.loading() = _Loading;
  const factory ConsentsState.consented({
    required List<ConsentItem> freshConsents,
    required List<ConsentItem> oldConsents,
  }) = _Consented;
  const factory ConsentsState.consentsPending({
    required List<ConsentItem> consented,
    required List<ConsentItem> pending,
    @Default([]) List<ConsentItem> selected,
    @Default(false) bool isSubmitting,
  }) = _ConsentsPending;
  const factory ConsentsState.error(Failure failure) = _Error;
}
