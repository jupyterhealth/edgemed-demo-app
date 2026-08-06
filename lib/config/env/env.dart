import 'package:flutter/foundation.dart';

enum EnvironmentType { staging, preprod, prod }

class Env {
  static const String _current = String.fromEnvironment('ENV');
  static final current = EnvironmentType.values.firstWhere(
    (element) => element.name == _current,
  );

  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get enableLogging =>
      kDebugMode || current == EnvironmentType.staging;
}
