import 'package:injectable/injectable.dart';

import 'package:dio/dio.dart';
import 'package:jupyter_health/domain/entity/user.dart';
import 'package:retrofit/retrofit.dart';

part 'api_data_source_impl.g.dart';

@lazySingleton
@RestApi()
abstract class ApiDataSource {
  @factoryMethod
  factory ApiDataSource(@Named('apiDio') Dio dio) = _ApiDataSource;

  @GET('/users/profile')
  Future<HttpResponse<User>> getUser();
}
