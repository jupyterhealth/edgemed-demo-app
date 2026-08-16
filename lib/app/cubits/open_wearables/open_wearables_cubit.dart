import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/config/env/env.dart';
import 'package:open_wearables_health_sdk/health_data_type.dart';
import 'package:open_wearables_health_sdk/open_wearables_health_sdk.dart';

part 'open_wearables_state.dart';
part 'open_wearables_cubit.freezed.dart';

@injectable
class OpenWearablesCubit extends Cubit<OpenWearablesState> {
  OpenWearablesCubit() : super(OpenWearablesState.initial());

  void init() async {
    final status = OpenWearablesHealthSdk.isSyncActive;
    if (status) {
      emit(OpenWearablesState.syncing());
    } else {
      emit(OpenWearablesState.notConfigured());
    }
  }

  void configure({
    required String userAccessToken,
    required String refreshToken,
    required int userId,
  }) async {
    await OpenWearablesHealthSdk.configure(host: Env.apiBaseUrl);
    await OpenWearablesHealthSdk.signIn(
      accessToken: userAccessToken,
      refreshToken: refreshToken,
      userId: userId.toString(),
    );
    final authorizationResult =
        await OpenWearablesHealthSdk.requestAuthorization(
          types: [HealthDataType.bloodGlucose],
        );
    if (authorizationResult) {
      await OpenWearablesHealthSdk.startBackgroundSync();
    } else {
      emit(OpenWearablesState.notConfigured());
    }
  }
}
