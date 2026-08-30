import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';

part 'passcode_state.dart';
part 'passcode_cubit.freezed.dart';

@injectable
class PasscodeCubit extends Cubit<PasscodeState> {
  final LocalStorageRepository _localStorageRepository;
  final ApiRepository _apiRepository;

  PasscodeCubit(this._localStorageRepository, this._apiRepository)
    : super(const PasscodeState());

  bool get canSubmit =>
      state.flow != null &&
      state.passcode.length == 6 &&
      !state.isSubmitting &&
      state.nextRoute == null;

  Future<void> init() async {
    final storedPasscode = await _localStorageRepository.getPasscode();
    emit(
      state.copyWith(
        flow: storedPasscode == null ? PasscodeFlow.setup : PasscodeFlow.unlock,
      ),
    );
  }

  void updatePasscode(String passcode) {
    emit(state.copyWith(passcode: passcode, hasError: false));
  }

  Future<void> submit() async {
    final flow = state.flow;
    final passcode = state.passcode;
    if (flow == null ||
        passcode.length != 6 ||
        state.isSubmitting ||
        state.nextRoute != null) {
      return;
    }

    emit(state.copyWith(isSubmitting: true, hasError: false));

    switch (flow) {
      case PasscodeFlow.setup:
        await _localStorageRepository.setPasscode(passcode);
      case PasscodeFlow.unlock:
        final storedPasscode = await _localStorageRepository.getPasscode();
        final isValid = storedPasscode != null && storedPasscode == passcode;
        if (!isValid) {
          emit(state.copyWith(isSubmitting: false, hasError: true));
          return;
        }
    }

    final nextRoute = await _resolveNextRoute();
    emit(state.copyWith(isSubmitting: false, nextRoute: nextRoute));
  }

  Future<PasscodeNextRoute> _resolveNextRoute() async {
    if (!_localStorageRepository.getQuestionnaireCompleted()) {
      return PasscodeNextRoute.questionnaire;
    }

    final userResult = await _apiRepository.getUser();
    final userId = userResult.fold((_) => null, (user) => user.id);
    if (userId == null) {
      return PasscodeNextRoute.consents;
    }

    final consentsResult = await _apiRepository.getPatientConsents(
      patientId: userId,
    );
    return consentsResult.fold((_) => PasscodeNextRoute.consents, (consents) {
      final hasPending = consents.pending.any(
        (element) =>
            element.codingCode == 'omh:blood-glucose:4.0' ||
            element.codingCode == 'QuestionnaireResponse',
      );
      return hasPending
          ? PasscodeNextRoute.consents
          : PasscodeNextRoute.dashboard;
    });
  }
}
