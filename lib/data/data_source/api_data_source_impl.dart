import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/data/dto/consents/patient_consents_dto.dart';
import 'package:jupyter_health/data/dto/consents/submit_consents_request_dto.dart';
import 'package:jupyter_health/data/dto/fhe/fhir/observation_dto.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:retrofit/retrofit.dart';

part 'api_data_source_impl.g.dart';

@lazySingleton
@RestApi()
abstract class ApiDataSource {
  @factoryMethod
  factory ApiDataSource(@Named('apiDio') Dio dio) = _ApiDataSource;

  @GET('/api/v1/patients/me')
  Future<HttpResponse<User>> getUser();

  @GET('/api/v1/patients/{patientId}/consents')
  Future<HttpResponse<PatientConsentsDto>> getPatientConsents({
    @Path('patientId') required int patientId,
  });

  @POST('/api/v1/patients/{patientId}/consents')
  Future<HttpResponse<dynamic>> submitPatientConsents({
    @Path('patientId') required int patientId,
    @Body() required SubmitConsentsRequestDto body,
  });

  @GET('/FHIR/R5/Observation')
  Future<HttpResponse<ObservationBundleDto>> getObservations({
    @Query('code') required String code,
    @Query('date') required List<String> date,
    @Query('_count') int? count,
  });

  @GET('{url}')
  Future<HttpResponse<ObservationBundleDto>> getObservationsByUrl(
    @Path('url') String url,
  );
}
