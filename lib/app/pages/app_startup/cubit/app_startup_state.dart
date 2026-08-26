part of 'app_startup_cubit.dart';

@freezed
class AppStartupState with _$AppStartupState {
  const factory AppStartupState.initial() = _Initial;
  const factory AppStartupState.welcomePage() = _WelcomePage;
  const factory AppStartupState.passcodeSetupMissing() = _PasscodeSetupMissing;
  const factory AppStartupState.passcodeConfirmationRequired() =
      _PasscodeConfirmationRequired;
}
