import 'package:flutter/widgets.dart';

abstract class LocalStorageRepository {
  Future<void> init();
  Locale? getLocale();
  Future<void> setLocale(Locale locale);
  Future<String?> getAccessToken();
  Future<void> setAccessToken(String accessToken);
  Future<String?> getRefreshToken();
  Future<void> setRefreshToken(String refreshToken);
  Future<String?> getPasscode();
  Future<void> setPasscode(String passcode);
  bool getQuestionnaireCompleted();
  Future<void> setQuestionnaireCompleted(bool completed);
  Future<void> clear();
}
