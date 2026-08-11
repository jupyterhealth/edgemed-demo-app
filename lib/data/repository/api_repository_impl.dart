import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/data/data_source/api_data_source_impl.dart';
import 'package:jupyter_health/data/utils/api_helpers.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';

@LazySingleton(as: ApiRepository)
class ApiRepositoryImpl implements ApiRepository {
  final ApiDataSource _apiDataSource;
  ApiRepositoryImpl(this._apiDataSource);

  @override
  Future<Either<Failure, User>> getUser() => safeApiCall(
    apiCall: () async {
      final response = await _apiDataSource.getUser();
      return response.data;
    },
  );

  @override
  Future<Either<Failure, List<Observation>>> getObservations() {
    return safeApiCall(
      apiCall: () async {
        final response = await _apiDataSource.getObservations();
        return response.data.entry
            .map((e) => e.resource.toDomain())
            .whereType<Observation>()
            .toList();
      },
    );
  }
}
