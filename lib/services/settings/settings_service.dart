import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsService {
  static const String _boxName = 'settings_box';
  static const String _themeKey = 'theme_mode';
  static const String _modelKey = 'ai_model';
  static const String _tempKey = 'ai_temperature';
  static const String _styleKey = 'response_style';
  static const String _onboardingKey = 'has_completed_onboarding';
  
  // Premium Key
  static const String _premiumKey = 'is_premium';
  
  // Profile Keys
  static const String _userNameKey = 'user_name';
  static const String _userBioKey = 'user_bio';

  static bool _isInitialized = false;
  static Future<void>? _initFuture;

  static Future<void> init() async {
    if (_isInitialized && Hive.isBoxOpen(_boxName)) return;
    
    // Prevent multiple concurrent initialization calls
    if (_initFuture != null) return _initFuture;

    _initFuture = _performInit();
    return _initFuture;
  }

  static Future<void> _performInit() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        await Hive.openBox(_boxName).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('SettingsService: Hive.openBox timed out');
            throw Exception('Settings box timeout');
          },
        );
      }
      _isInitialized = true;
    } catch (e) {
      debugPrint('SettingsService initialization failed: $e');
      rethrow;
    } finally {
      _initFuture = null;
    }
  }

  static Box get _box {
    if (!isReady) {
      // Fallback for unexpected access before init
      return Hive.box(_boxName); 
    }
    return Hive.box(_boxName);
  }

  static bool get isReady => _isInitialized && Hive.isBoxOpen(_boxName);

  // Premium Status
  static bool get isPremium {
    if (!isReady) return false;
    return _box.get(_premiumKey, defaultValue: false);
  }

  static Future<void> enablePremium() async {
    if (!isReady) await init();
    await _box.put(_premiumKey, true);
  }

  static Future<void> disablePremium() async {
    if (!isReady) await init();
    await _box.put(_premiumKey, false);
  }

  static Future<void> togglePremium() async {
    if (!isReady) await init();
    final current = isPremium;
    await _box.put(_premiumKey, !current);
  }

  // Onboarding Persistence
  static bool get hasCompletedOnboarding {
    if (!isReady) return false;
    return _box.get(_onboardingKey, defaultValue: false);
  }
  
  static Future<void> setOnboardingCompleted() async {
    if (!isReady) await init();
    await _box.put(_onboardingKey, true);
  }

  // Profile Persistence
  static String get userName {
    if (!isReady) return 'Nova Explorer';
    return _box.get(_userNameKey, defaultValue: 'Nova Explorer');
  }
  
  static Future<void> setUserName(String name) async {
    if (!isReady) await init();
    await _box.put(_userNameKey, name);
  }

  static String get userBio {
    if (!isReady) return 'AI Explorer & Tech Enthusiast';
    return _box.get(_userBioKey, defaultValue: 'AI Explorer & Tech Enthusiast');
  }
  
  static Future<void> setUserBio(String bio) async {
    if (!isReady) await init();
    await _box.put(_userBioKey, bio);
  }

  // Theme Settings
  static ThemeMode get themeMode {
    if (!isReady) return ThemeMode.system;
    final mode = _box.get(_themeKey, defaultValue: 'system');
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    if (!isReady) await init();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await _box.put(_themeKey, value);
  }


  static String get aiModel {
    if (!isReady) return 'llama-3.3-70b-versatile';
    return _box.get(_modelKey, defaultValue: 'llama-3.3-70b-versatile');
  }
  
  static Future<void> setAiModel(String model) async {
    if (!isReady) await init();
    await _box.put(_modelKey, model);
  }

  static double get temperature {
    if (!isReady) return 0.7;
    return _box.get(_tempKey, defaultValue: 0.7);
  }

  static Future<void> setTemperature(double temp) async {
    if (!isReady) await init();
    await _box.put(_tempKey, temp);
  }

  static String get responseStyle {
    if (!isReady) return 'Balanced';
    return _box.get(_styleKey, defaultValue: 'Balanced');
  }

  static Future<void> setResponseStyle(String style) async {
    if (!isReady) await init();
    await _box.put(_styleKey, style);
  }
}
