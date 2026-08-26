import 'package:flutter/widgets.dart';

abstract class LocalStorageRepository {
  Future<void> init();
  Locale? getLocale();
  Future<void> setLocale(Locale locale);
  Future<String?> getAccessToken();
  Future<void> setAccessToken(String accessToken);
  Future<String?> getRefreshToken();
  Future<void> setRefreshToken(String refreshToken);
  bool getWelcomePageShown();
  Future<void> setWelcomePageShown(bool shown);
  Future<String?> getPasscode();
  Future<void> setPasscode(String passcode);
  bool comparePasscode({
    required String rawPasscode,
    required String hashedPasscode,
  });
  bool getQuestionnaireCompleted();
  Future<void> setQuestionnaireCompleted(bool completed);
}
