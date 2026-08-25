import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import 'package:jupyter_health/config/env/env.dart';
import 'package:jupyter_health/config/env/fhir_config.dart';
import 'package:jupyter_health/data/data_source/api_data_source_impl.dart';
import 'package:jupyter_health/data/dto/consents/submit_consents_request_dto.dart';
import 'package:jupyter_health/data/dto/fhe/fhir/fhir_source_dto.dart';
import 'package:jupyter_health/data/dto/fhe/fhir/questionnaire_response_dto.dart';
import 'package:jupyter_health/data/utils/api_helpers.dart';
import 'package:jupyter_health/data/utils/invitation_auth_utils.dart';
import 'package:jupyter_health/utils/invitation_utils.dart';
import 'package:jupyter_health/domain/entity/auth_token.dart';
import 'package:jupyter_health/domain/entity/consents/consent_item.dart';
import 'package:jupyter_health/domain/entity/consents/patient_consents.dart';
import 'package:jupyter_health/domain/entity/failure.dart';
import 'package:jupyter_health/domain/entity/observations/observation_page.dart';
import 'package:jupyter_health/domain/entity/observations/observation_type.dart';
import 'package:jupyter_health/domain/entity/questionnaire/question.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:jupyter_health/domain/repository/api_repository.dart';

@LazySingleton(as: ApiRepository)
class ApiRepositoryImpl implements ApiRepository {
  static const _pageSize = 1000;
  static const _observationsFrom = '2025-01-01';

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
  Future<Either<Failure, PatientConsents>> getPatientConsents({
    required int patientId,
  }) => safeApiCall(
    apiCall: () async {
      final response = await _apiDataSource.getPatientConsents(
        patientId: patientId,
      );
      return response.data.toDomain();
    },
  );

  @override
  Future<Either<Failure, Unit>> submitPatientConsents({
    required int patientId,
    required List<ConsentItem> items,
  }) => safeApiCall(
    apiCall: () async {
      await _apiDataSource.submitPatientConsents(
        patientId: patientId,
        body: SubmitConsentsRequestDto.fromConsentItems(items),
      );
      return unit;
    },
  );

  @override
  Future<Either<Failure, ObservationPage>> getObservations({
    required ObservationType type,
    Map<String, String>? nextUrls,
  }) async {
    return await safeApiCall(
      apiCall: () async {
        final sources = nextUrls != null
            ? Map<String, String?>.of(nextUrls)
            : <String, String?>{
                for (final code in type.fhirSearchCodes) code: null,
              };
        if (sources.isEmpty) return const ObservationPage();

        return await _fetchFeeds(sources);
      },
    );
  }

  Future<ObservationPage> _fetchFeeds(Map<String, String?> sources) async {
    ObservationPage? page;
    Object? lastError;
    var succeeded = false;

    for (final entry in sources.entries) {
      try {
        page = _mergePages(
          page,
          await _fetchUntilObservations(code: entry.key, nextUrl: entry.value),
        );
        succeeded = true;
      } catch (error) {
        lastError = error;
        final url = entry.value;
        if (url != null) {
          page = _mergePages(page, ObservationPage(nextUrls: {entry.key: url}));
        }
      }
    }

    if (!succeeded && lastError != null) throw lastError;
    return page ?? const ObservationPage();
  }

  Future<ObservationPage> _fetchUntilObservations({
    required String code,
    String? nextUrl,
  }) async {
    var url = nextUrl;
    var useSearch = nextUrl == null;

    while (true) {
      final response = useSearch
          ? await _apiDataSource.getObservations(
              code: code,
              date: _observationDateRange,
              count: _pageSize,
            )
          : await _apiDataSource.getObservationsByUrl(
              _trustedPaginationUrl(url!),
            );
      useSearch = false;

      final page = response.data.toPage(code: code);
      url = page.nextUrls[code];
      if (page.observations.isNotEmpty || url == null) return page;
    }
  }

  ObservationPage _mergePages(
    ObservationPage? current,
    ObservationPage incoming,
  ) {
    if (current == null) return incoming;

    final existingIds = {for (final item in current.observations) item.id};
    return ObservationPage(
      observations: [
        ...current.observations,
        for (final item in incoming.observations)
          if (!existingIds.contains(item.id)) item,
      ],
      nextUrls: {...current.nextUrls, ...incoming.nextUrls},
    );
  }

  List<String> get _observationDateRange {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now().toUtc());
    return ['ge$_observationsFrom', 'le$today'];
  }

  String _trustedPaginationUrl(String url) {
    final base = Uri.tryParse(Env.apiBaseUrl);
    if (base == null || base.scheme != 'https') {
      throw ArgumentError.value(url, 'url', 'Untrusted pagination URL');
    }

    final parsed = Uri.tryParse(url);
    if (parsed == null) {
      throw ArgumentError.value(url, 'url', 'Untrusted pagination URL');
    }

    final resolved = parsed.hasScheme ? parsed : base.resolveUri(parsed);
    if (resolved.scheme != 'https' || resolved.origin != base.origin) {
      throw ArgumentError.value(url, 'url', 'Untrusted pagination URL');
    }
    return resolved.toString();
  }

  @override
  Future<Either<Failure, Unit>> submitQuestionnaire({
    required int patientId,
    required List<Question> questions,
  }) => safeApiCall(
    apiCall: () async {
      final sourceResponse = await _apiDataSource.registerFhirSource(
        body: const RegisterFhirSourceRequestDto(
          label: FhirConfig.fhirSourceLabel,
          fhirBaseUrl: FhirConfig.fhirBaseUrl,
          dataSource: FhirConfig.dataSourceId,
        ),
      );

      await _apiDataSource.submitQuestionnaireResponse(
        body: QuestionnaireResponseDto.fromQuestions(
          patientId: patientId,
          fhirSourceId: sourceResponse.data.id,
          questions: questions,
          authored: DateTime.now().toUtc(),
        ),
      );
      return unit;
    },
  );

  @override
  Future<Either<Failure, AuthToken>> login(String invitationCode) =>
      safeApiCall(
        apiCall: () async {
          final token = normalizeInvitationCode(invitationCode);

          final redeemResponse = await _apiDataSource.redeemInvitation(
            invitationCode: token,
          );
          final grant = redeemResponse.data.grant;

          final tokenResponse = await _apiDataSource.exchangeToken(
            grantType: grant.grantType,
            code: grant.code,
            redirectUri: grant.redirectUri,
            clientId: grant.clientId,
            codeVerifier: invitationCodeVerifier(token),
          );

          return tokenResponse.data.toDomain();
        },
      );
}
