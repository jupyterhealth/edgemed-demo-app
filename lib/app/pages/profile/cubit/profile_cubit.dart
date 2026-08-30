import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';

part 'profile_state.dart';
part 'profile_cubit.freezed.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final LocalStorageRepository _localStorageRepository;
  ProfileCubit(this._localStorageRepository)
    : super(ProfileState(passcode: '******'));

  void init() async {
    final passcode = await _localStorageRepository.getPasscode();
    emit(ProfileState(passcode: passcode ?? '******'));
  }
}
