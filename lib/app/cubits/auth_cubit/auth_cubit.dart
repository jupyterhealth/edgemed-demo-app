import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/utils/invitation_utils.dart';
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
    : super(AuthState.loading()) {
    _subscription = AppLinks().uriLinkStream.listen(_onUri);
  }

  StreamSubscription<Uri>? _subscription;

  void _onUri(Uri uri) {
    final invitationCode = InvitationLink.codeFrom(uri);
    if (invitationCode == null) return;
    _login(invitationCode);
  }

  void _login(String invitationCode) async {
    emit(AuthState.loading());
    final result = await _apiRepository.login(invitationCode);
    await result.fold(
      (l) async {
        await _localStorageRepository.clear();
        emit(AuthState.unauthenticated());
      },
      (authToken) async {
        await (
          _localStorageRepository.setAccessToken(authToken.accessToken),
          _localStorageRepository.setRefreshToken(authToken.refreshToken),
        ).wait;
        final user = await _apiRepository.getUser();
        user.fold(
          (l) {
            emit(AuthState.unauthenticated());
          },
          (user) {
            emit(
              AuthState.authenticated(
                user: user,
                accessToken: authToken.accessToken,
                refreshToken: authToken.refreshToken,
              ),
            );
          },
        );
      },
    );
  }

  // REDACTED_TOKEN most data to test
  // REDACTED_TOKEN

  // final _accessToken = 'REDACTED_TOKEN';

  void fetchUser() async {
    emit(AuthState.loading());
    final (userResult, accessTokenResult, refreshTokenResult) = await (
      _apiRepository.getUser(),
      _localStorageRepository.getAccessToken(),
      _localStorageRepository.getRefreshToken(),
    ).wait;
    userResult.fold(
      (l) {
        emit(AuthState.unauthenticated());
      },
      (user) {
        if (accessTokenResult == null || refreshTokenResult == null) {
          emit(AuthState.unauthenticated());
          return;
        }
        emit(
          AuthState.authenticated(
            user: user,
            accessToken: accessTokenResult,
            refreshToken: refreshTokenResult,
          ),
        );
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
