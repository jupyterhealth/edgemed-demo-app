import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:jupyter_health/config/di/injectable.config.dart';
import 'package:jupyter_health/domain/repository/local_storage_repository.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();
  await Future.wait([getIt<LocalStorageRepository>().init()]);
}
