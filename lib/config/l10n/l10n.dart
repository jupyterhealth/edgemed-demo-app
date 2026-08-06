import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jupyter_health/config/l10n/generated/app_localizations.dart';

AppLocalizations T(BuildContext context) => AppLocalizations.of(context);

class L10n {
  static const supported = AppLocalizations.supportedLocales;

  static List<LocalizationsDelegate<dynamic>> get localizationDelegates => [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static String currentLanguage(BuildContext context) => AppLocalizations.of(context).localeName;

  static String getNativeLangName(String? langCode) {
    switch (langCode) {
      case 'en':
        return 'English';
      default:
        return '';
    }
  }
}
