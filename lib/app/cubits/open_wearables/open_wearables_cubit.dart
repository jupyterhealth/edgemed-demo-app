import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/config/env/env.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';
import 'package:open_wearables_health_sdk/health_data_type.dart';
import 'package:open_wearables_health_sdk/open_wearables_health_sdk.dart';

part 'open_wearables_state.dart';
part 'open_wearables_cubit.freezed.dart';

@injectable
class OpenWearablesCubit extends Cubit<OpenWearablesState> {
  final ApiRepository _apiRepository;
  final LocalStorageRepository _localStorageRepository;

  OpenWearablesCubit(this._apiRepository, this._localStorageRepository)
    : super(OpenWearablesState.initial());

  var _isConfiguring = false;

  static const _authorizationTypes = [HealthDataType.bloodGlucose];

  Future<void> init() async {
    if (_isConfiguring) return;
    if (state.maybeMap(initial: (_) => false, orElse: () => true)) return;

    _isConfiguring = true;
    try {
      final accessToken = await _localStorageRepository.getAccessToken();
      final refreshToken = await _localStorageRepository.getRefreshToken();
      if (accessToken == null || refreshToken == null) {
        emit(OpenWearablesState.notConfigured());
        return;
      }

      final owUserId = (await _apiRepository.createOwUser()).fold(
        (_) => null,
        (id) => id,
      );
      if (owUserId == null || owUserId.isEmpty) {
        emit(OpenWearablesState.notConfigured());
        return;
      }

      await OpenWearablesHealthSdk.configure(host: Env.owApiUrl);

      final signedInUserId = OpenWearablesHealthSdk.currentUser?.userId;
      if (!OpenWearablesHealthSdk.isSignedIn || signedInUserId != owUserId) {
        await OpenWearablesHealthSdk.signIn(
          accessToken: accessToken,
          refreshToken: refreshToken,
          userId: owUserId,
        );
      }

      if (Platform.isAndroid) {
        await OpenWearablesHealthSdk.setProvider(
          AndroidHealthProvider.healthConnect,
        );
      }

      final authorizationResult =
          await OpenWearablesHealthSdk.requestAuthorization(
            types: _authorizationTypes,
          );
      if (!authorizationResult) {
        emit(OpenWearablesState.notConfigured());
        return;
      }

      if (!OpenWearablesHealthSdk.isSyncActive) {
        await OpenWearablesHealthSdk.startBackgroundSync();
      }
      emit(OpenWearablesState.syncing());
    } catch (_) {
      emit(OpenWearablesState.notConfigured());
    } finally {
      _isConfiguring = false;
    }
  }
}
