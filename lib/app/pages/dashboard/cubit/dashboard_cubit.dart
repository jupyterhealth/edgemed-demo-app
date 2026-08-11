import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';

part 'dashboard_state.dart';
part 'dashboard_cubit.freezed.dart';

@Injectable()
class DashboardCubit extends Cubit<DashboardState> {
  final ApiRepository _apiRepository;
  DashboardCubit(this._apiRepository) : super(DashboardState.loading());

  Future<void> fetchObservations() async {
    emit(DashboardState.loading());
    final result = await _apiRepository.getObservations();
    result.fold(
      (l) => emit(DashboardState.error(l)),
      (r) => emit(DashboardState.data(r)),
    );
  }
}
