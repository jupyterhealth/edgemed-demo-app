import 'package:flutter/material.dart';
import 'package:jupyter_health/app/main_app.dart';
import 'package:jupyter_health/config/di/injectable.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const MainApp());
}
