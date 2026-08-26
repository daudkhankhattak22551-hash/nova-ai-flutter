import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'services/history/chat_history_service.dart';
import 'services/settings/settings_service.dart';
import 'services/auth/auth_service.dart';
import 'dart:async';

void main() async {
  // 1. Ensure Flutter bindings are initialized properly
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Perform essential initialization before the UI starts.
  await initializeAppServices();
  
  // 3. Start the application
  runApp(const NovaAIApp());
}

/// Robust startup initialization for all core services
Future<void> initializeAppServices() async {
  try {
    // Initialize Hive core with a timeout
    await Hive.initFlutter().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        debugPrint('Startup: Hive.initFlutter timed out');
      },
    );
    
    // Initialize essential storage boxes in parallel with a safe timeout.
    await Future.wait([
      SettingsService.init(),
      ChatHistoryService.init(),
      AuthService.init(),
    ]).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        debugPrint('Startup: Services initialization timed out');
        return []; 
      },
    ).catchError((e) {
      debugPrint('Startup: Critical error during box initialization: $e');
      return [];
    });
    
  } catch (e) {
    debugPrint('Startup: Unexpected initialization error: $e');
  }
}

class NovaAIApp extends StatefulWidget {
  const NovaAIApp({super.key});

  @override
  State<NovaAIApp> createState() => _NovaAIAppState();
}

class _NovaAIAppState extends State<NovaAIApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = SettingsService.themeMode;
  }

  /// Callback to refresh theme when changed in settings
  void _updateTheme() {
    if (mounted) {
      setState(() {
        _themeMode = SettingsService.themeMode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: (settings) => AppRoutes.generateRoute(
        settings, 
        onThemeChanged: _updateTheme,
      ),
    );
  }
}
