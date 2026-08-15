import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/config/env/env.dart';
import 'package:jupyter_health/data/dto/fhe/fhir/observation_dto.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:retrofit/retrofit.dart';

part 'api_data_source_impl.g.dart';

@RestApi()
abstract class GeneratedApiDataSource {
  factory GeneratedApiDataSource(Dio dio) = _GeneratedApiDataSource;

  @GET('/api/v1/users/profile')
  Future<HttpResponse<User>> getUser();

  @GET('/FHIR/R5/Observation')
  Future<HttpResponse<ObservationBundleDto>> getObservations({
    @Query('code') required String code,
    @Query('date') required List<String> date,
    @Query('_count') int? count,
  });
}

@lazySingleton
class ApiDataSource {
  final Dio _dio;
  final GeneratedApiDataSource _client;

  ApiDataSource(@Named('apiDio') Dio dio)
    : _dio = dio,
      _client = GeneratedApiDataSource(dio);

  Future<HttpResponse<User>> getUser() => _client.getUser();

  Future<HttpResponse<ObservationBundleDto>> getObservations({
    required String code,
    required List<String> date,
    int? count,
  }) => _client.getObservations(code: code, date: date, count: count);

  Future<HttpResponse<ObservationBundleDto>> getObservationsByUrl(
    String url,
  ) async {
    if (!_isTrustedPaginationUrl(url)) {
      throw ArgumentError.value(url, 'url', 'Untrusted pagination URL');
    }

    final result = await _dio.get<Map<String, dynamic>>(url);
    return HttpResponse(ObservationBundleDto.fromJson(result.data!), result);
  }

  bool _isTrustedPaginationUrl(String url) {
    final base = Uri.tryParse(Env.apiBaseUrl);
    if (base == null || base.scheme != 'https') return false;

    final parsed = Uri.tryParse(url);
    if (parsed == null) return false;

    final resolved = parsed.hasScheme ? parsed : base.resolveUri(parsed);
    if (resolved.scheme != 'https') return false;
    return resolved.origin == base.origin;
  }
}
