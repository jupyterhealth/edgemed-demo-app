import 'package:dartz/dartz.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/data/utils/api_repository_utils.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:logger/logger.dart';

Future<Either<Failure, T>> safeApiCall<T>({
  required Future<T> Function() apiCall,
}) async {
  try {
    final result = await apiCall();
    return Right(result);
  } catch (err, st) {
    final logger = getIt<Logger>();
    logger.e('safeApiCall<$T> failed', error: err, stackTrace: st);
    final failure = await ApiRepositoryUtils.handleFailure(err, st);
    return Left(failure);
  }
}
