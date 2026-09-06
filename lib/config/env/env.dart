import 'package:flutter/foundation.dart';

enum EnvironmentType { staging, preprod, prod }

class Env {
  static const String _current = String.fromEnvironment('ENV');
  static final current = EnvironmentType.values.firstWhere(
    (element) => element.name == _current,
  );

  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const String owApiUrl = String.fromEnvironment('OW_API_URL');
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const String termsAndConditionsUrl = String.fromEnvironment(
    'TERMS_AND_CONDITIONS_URL',
  );
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
  );

  static bool get enableLogging =>
      kDebugMode || current == EnvironmentType.staging;
}
