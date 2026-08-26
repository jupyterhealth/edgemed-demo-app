part of 'passcode_cubit.dart';

enum PasscodeFlow { setup, unlock }

enum PasscodeNextRoute { questionnaire, consents, dashboard }

@freezed
abstract class PasscodeState with _$PasscodeState {
  const factory PasscodeState({
    PasscodeFlow? flow,
    @Default('') String passcode,
    @Default(false) bool hasError,
    @Default(false) bool isSubmitting,
    PasscodeNextRoute? nextRoute,
  }) = _PasscodeState;
}
