import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/entity/consents/consent_item.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';

part 'consents_state.dart';
part 'consents_cubit.freezed.dart';

@injectable
class ConsentsCubit extends Cubit<ConsentsState> {
  final ApiRepository _apiRepository;

  ConsentsCubit(this._apiRepository) : super(ConsentsState.initial());

  late int userId;

  void init(int userId) async {
    this.userId = userId;
    if (state.maybeMap(loading: (_) => true, orElse: () => false)) return;

    emit(ConsentsState.loading());
    final result = await _apiRepository.getPatientConsents(patientId: userId);
    result.fold((failure) => emit(ConsentsState.error(failure)), (consents) {
      if (consents.pending.isEmpty) {
        emit(ConsentsState.consented());
        return;
      }
      emit(
        ConsentsState.consentsPending(
          consented: consents.consented,
          pending: consents.pending,
          selected: consents.pending, //all selected by default
        ),
      );
    });
  }

  void togglePending(ConsentItem item) {
    final pendingState = state.mapOrNull(consentsPending: (value) => value);
    if (pendingState == null || pendingState.isSubmitting) return;

    final selected = [...pendingState.selected];
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      selected.add(item);
    }
    emit(pendingState.copyWith(selected: selected));
  }

  void submit() async {
    final pendingState = state.mapOrNull(consentsPending: (value) => value);
    if (pendingState == null || pendingState.isSubmitting) return;
    if (pendingState.selected.length != pendingState.pending.length) return;

    emit(pendingState.copyWith(isSubmitting: true));
    final result = await _apiRepository.submitPatientConsents(
      patientId: userId,
      items: pendingState.selected,
    );
    result.fold(
      (failure) => emit(ConsentsState.error(failure)),
      (_) => emit(ConsentsState.consented()),
    );
  }
}
