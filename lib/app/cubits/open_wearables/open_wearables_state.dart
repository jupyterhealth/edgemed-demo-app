part of 'open_wearables_cubit.dart';

@freezed
class OpenWearablesState with _$OpenWearablesState {
  const factory OpenWearablesState.initial() = _Initial;
  const factory OpenWearablesState.syncing() = _Syncing;
  const factory OpenWearablesState.notConfigured() = _NotConfigured;
}
