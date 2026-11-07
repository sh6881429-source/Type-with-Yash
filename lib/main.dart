import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'core/constants/app_constants.dart';
import 'data/database/app_database.dart';
import 'data/services/passage_seeder.dart';
import 'core/theme/neo_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Local SQLite is initialized before UI so every later screen has the same
  // offline data source. A failure remains visible in logs instead of crashing
  // the onboarding experience.
  try {
    await AppDatabase.instance.database;
    await PassageSeeder.seedIfNeeded();
  } catch (e) {
    debugPrint('[LocalDatabase] Initialization or passage seeding failed: $e');
  }

  // Desktop Window Configuration
  if (!kIsWeb && Platform.isWindows) {
    try {
      await windowManager.ensureInitialized();

      const WindowOptions windowOptions = WindowOptions(
        size: Size(
          AppConstants.windowDefaultWidth,
          AppConstants.windowDefaultHeight,
        ),
        minimumSize: Size(
          AppConstants.windowMinWidth,
          AppConstants.windowMinHeight,
        ),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        title: AppConstants.appName,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    } catch (e) {
      debugPrint('[WindowManager] Could not initialize window manager: $e');
    }
  }

  runApp(const TypeWithYashApp());
}

class TypeWithYashApp extends StatelessWidget {
  const TypeWithYashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: NeoTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
