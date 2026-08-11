import 'package:dartz/dartz.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/observations/observation.dart';
import 'package:jupyter_health/domain/entity/user.dart';

abstract class ApiRepository {
  Future<Either<Failure, User>> getUser();
  Future<Either<Failure, List<Observation>>> getObservations();
}
