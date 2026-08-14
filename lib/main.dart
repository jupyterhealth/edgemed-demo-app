import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jupyter_health/app/main_app.dart';
import 'package:jupyter_health/config/di/injectable.dart';
import 'package:jupyter_health/config/env/env.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    await _initializeApp(useSentryBinding: false);
    runApp(const MainApp());
    return;
  }

  await _initializeApp(useSentryBinding: true);
  await SentryFlutter.init((options) {
    options
      ..dsn = Env.sentryDsn
      ..tracesSampleRate = 0.5
      ..environment = Env.current.name;
  }, appRunner: () => runApp(SentryWidget(child: const MainApp())));
  runApp(const MainApp());
}

Future<void> _initializeApp({required bool useSentryBinding}) async {
  late final WidgetsBinding widgetsBinding;
  if (useSentryBinding) {
    widgetsBinding = SentryWidgetsFlutterBinding.ensureInitialized();
  } else {
    widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  }
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  await Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]),
    configureDependencies(),
  ]);
}
