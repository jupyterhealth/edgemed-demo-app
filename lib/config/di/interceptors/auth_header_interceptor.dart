import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';
import 'package:logger/logger.dart';

@injectable
class AuthHeaderInterceptor extends Interceptor {
  final Logger _logger;
  final LocalStorageRepository _localStorageRepository;

  const AuthHeaderInterceptor(this._logger, this._localStorageRepository);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final isAuthRequest = options.path.contains('/oauth/token');
    if (!isAuthRequest && options.headers['Authorization'] == null) {
      final accessToken = await _localStorageRepository.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    _logger.d(
      'Request: ${options.method} ${options.path}\n'
      'Payload: ${options.data}',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _logger.d('Response: ${response.data}');
    handler.next(response);
  }
}
