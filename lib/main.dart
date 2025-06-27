// lib/main.dart
import 'package:flutter/material.dart';
import 'app.dart';
import 'package:frontendpatient/core/di/service_locator.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar dependencias
  await di.init();

  runApp(const MyApp());
}