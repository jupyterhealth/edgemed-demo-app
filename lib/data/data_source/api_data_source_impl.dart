import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/data/dto/auth/invitation_redeem_response_dto.dart';
import 'package:jupyter_health/data/dto/auth/oauth_token_response_dto.dart';
import 'package:jupyter_health/data/dto/consents/patient_consents_dto.dart';
import 'package:jupyter_health/data/dto/consents/submit_consents_request_dto.dart';
import 'package:jupyter_health/data/dto/fhe/fhir/fhir_source_dto.dart';
import 'package:jupyter_health/data/dto/fhe/fhir/observation_dto.dart';
import 'package:jupyter_health/data/dto/fhe/fhir/questionnaire_response_dto.dart';
import 'package:jupyter_health/data/dto/ow/create_ow_user_request_dto.dart';
import 'package:jupyter_health/domain/entity/ow_credentials.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:retrofit/retrofit.dart';

part 'api_data_source_impl.g.dart';

@lazySingleton
@RestApi()
abstract class ApiDataSource {
  @factoryMethod
  factory ApiDataSource(@Named('apiDio') Dio dio) = _ApiDataSource;

  @POST('/api/v1/invitation/{invitationCode}')
  Future<HttpResponse<InvitationRedeemResponseDto>> redeemInvitation({
    @Path('invitationCode') required String invitationCode,
  });

  @POST('/o/token/')
  @FormUrlEncoded()
  Future<HttpResponse<OAuthTokenResponseDto>> exchangeToken({
    @Field('grant_type') required String grantType,
    @Field('code') required String code,
    @Field('redirect_uri') required String redirectUri,
    @Field('client_id') required String clientId,
    @Field('code_verifier') required String codeVerifier,
  });

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

  @POST('/api/v1/fhir_sources')
  Future<HttpResponse<FhirSourceDto>> registerFhirSource({
    @Body() required RegisterFhirSourceRequestDto body,
  });

  @POST('/FHIR/R5/QuestionnaireResponse')
  Future<HttpResponse<dynamic>> submitQuestionnaireResponse({
    @Body() required QuestionnaireResponseDto body,
  });

  @GET('/FHIR/R5/QuestionnaireResponse')
  Future<HttpResponse<QuestionnaireResponseBundleDto>>
  getQuestionnaireResponses({
    @Query('patient') required int patient,
    @Query('status') required String status,
    @Query('_summary') required String summary,
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

  @POST('/api/v1/ow/users')
  Future<HttpResponse<OwCredentials>> createOwUser({
    @Body() required CreateOwUserRequestDto body,
  });
}
