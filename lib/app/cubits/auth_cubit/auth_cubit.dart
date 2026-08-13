import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';

part 'auth_state.dart';
part 'auth_cubit.freezed.dart';

@Singleton()
class AuthCubit extends Cubit<AuthState> {
  final ApiRepository _apiRepository;
  final LocalStorageRepository _localStorageRepository;
  AuthCubit(this._apiRepository, this._localStorageRepository)
    : super(AuthState.loading());
  // REDACTED_TOKEN
  // REDACTED_TOKEN
  void fetchUser() async {
    emit(AuthState.loading());
    await _localStorageRepository.setAccessToken(
      'REDACTED_TOKEN',
    );
    final userResult = await _apiRepository.getUser();
    userResult.fold(
      (l) {
        emit(AuthState.unauthenticated());
      },
      (user) {
        emit(AuthState.authenticated(user));
      },
    );
  }
}
