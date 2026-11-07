import 'package:flutter/material.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/neo_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';

/// Browser-only development entry point. The Windows application continues to
/// use main.dart and SQLite; this target reads the same bundled passage asset.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TypeWithYashPreviewApp());
}

class TypeWithYashPreviewApp extends StatelessWidget {
  const TypeWithYashPreviewApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '${AppConstants.appName} - Development Preview',
    debugShowCheckedModeBanner: false,
    theme: NeoTheme.lightTheme,
    home: const SplashScreen(),
  );
}
