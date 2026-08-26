import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../models/auth/user_model.dart';
import '../settings/settings_service.dart';

class AuthService {
  static const String _usersBoxName = 'users_box';
  static const String _sessionBoxName = 'session_box';
  static const String _currentUserKey = 'current_user_id';

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    await Hive.openBox(_usersBoxName);
    await Hive.openBox(_sessionBoxName);
    _isInitialized = true;
  }

  static Box get _usersBox => Hive.box(_usersBoxName);
  static Box get _sessionBox => Hive.box(_sessionBoxName);

  static String? get currentUserId => _sessionBox.get(_currentUserKey);

  static bool get isAuthenticated => currentUserId != null;

  static UserModel? get currentUser {
    final id = currentUserId;
    if (id == null) return null;
    final userJson = _usersBox.get(id);
    if (userJson == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(userJson));
  }

  static Future<bool> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    // Check if user already exists
    final existingUser = _usersBox.values.any((u) => u['email'] == email);
    if (existingUser) throw Exception('Email already registered');

    final userId = const Uuid().v4();
    final newUser = UserModel(
      id: userId,
      name: name,
      email: email,
      password: password,
      isPremium: false,
    );

    await _usersBox.put(userId, newUser.toJson());
    await _loginUser(userId);
    return true;
  }

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      final userEntry = _usersBox.values.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => null,
      );

      if (userEntry == null) throw Exception('Invalid email or password');

      await _loginUser(userEntry['id']);
      return true;
    } catch (e) {
      if (e is StateError) throw Exception('Invalid email or password');
      rethrow;
    }
  }

  static Future<void> _loginUser(String userId) async {
    await _sessionBox.put(_currentUserKey, userId);
    
    // Sync with SettingsService for backward compatibility/global access
    final user = currentUser;
    if (user != null) {
      await SettingsService.setUserName(user.name);
      await SettingsService.setUserBio(user.bio);
      if (user.isPremium) {
        await SettingsService.enablePremium();
      } else {
        await SettingsService.disablePremium();
      }
    }
  }

  static Future<void> logout() async {
    await _sessionBox.delete(_currentUserKey);
    // Optionally clear local settings or reset to defaults
    await SettingsService.setUserName('Nova Explorer');
    await SettingsService.setUserBio('AI Explorer & Tech Enthusiast');
    await SettingsService.disablePremium();
  }

  static Future<void> updateProfile({String? name, String? bio}) async {
    final user = currentUser;
    if (user == null) return;

    final updatedUser = user.copyWith(
      name: name,
      bio: bio,
    );

    await _usersBox.put(user.id, updatedUser.toJson());
    
    // Sync settings
    if (name != null) await SettingsService.setUserName(name);
    if (bio != null) await SettingsService.setUserBio(bio);
  }

  static Future<void> syncPremiumStatus(bool isPremium) async {
    final user = currentUser;
    if (user == null) return;

    final updatedUser = user.copyWith(isPremium: isPremium);
    await _usersBox.put(user.id, updatedUser.toJson());
    
    if (isPremium) {
      await SettingsService.enablePremium();
    } else {
      await SettingsService.disablePremium();
    }
  }
}
