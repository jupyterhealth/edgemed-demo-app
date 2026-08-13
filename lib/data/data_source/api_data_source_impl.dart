import 'package:injectable/injectable.dart';

import 'package:dio/dio.dart';
import 'package:jupyter_health/data/dto/fhe/fhir/observation_dto.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:retrofit/retrofit.dart';

part 'api_data_source_impl.g.dart';

@lazySingleton
@RestApi()
abstract class ApiDataSource {
  @factoryMethod
  factory ApiDataSource(@Named('apiDio') Dio dio) = _ApiDataSource;

  @GET('/api/v1/users/profile')
  Future<HttpResponse<User>> getUser();

  @GET('/FHIR/R5/Observation?date=ge2025-01-01&date=le2026-08-12')
  Future<HttpResponse<ObservationBundleDto>> getObservations();
}
