import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';

part 'app_startup_state.dart';
part 'app_startup_cubit.freezed.dart';

@injectable
class AppStartupCubit extends Cubit<AppStartupState> {
  final ApiRepository _apiRepository;
  final LocalStorageRepository _localStorageRepository;
  AppStartupCubit(this._apiRepository, this._localStorageRepository)
    : super(AppStartupState.initial());

  Future<void> initialize() async {
    await Future.delayed(Duration.zero);
    final isPasscodeExists =
        (await _localStorageRepository.getPasscode()) != null;
    if (!isPasscodeExists) {
      emit(AppStartupState.welcomePage());
      return;
    }

    final userResponse = await _apiRepository.getUser();
    final isAuthenticated = userResponse.isRight();
    if (isAuthenticated) {
      emit(AppStartupState.passcodeConfirmationRequired());
      return;
    } else {
      emit(AppStartupState.welcomePage());
      return;
    }
  }
}
