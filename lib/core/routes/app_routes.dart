import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/onboarding/onboarding_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/chat/chat_screen.dart';
import '../../screens/image/image_generator_screen.dart';
import '../../screens/voice/voice_assistant_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/about/about_screen.dart';
import '../../screens/about/privacy_policy_screen.dart';
import '../../screens/about/terms_screen.dart';
import '../../screens/premium/premium_screen.dart';

class AppRoutes {
  AppRoutes._();


  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String chat = '/chat';
  static const String imageGenerator = '/image-generator';
  static const String voiceAssistant = '/voice-assistant';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String terms = '/terms';
  static const String premium = '/premium';

  /// Centralized Route Generator
  static Route<dynamic> generateRoute(RouteSettings settings, {VoidCallback? onThemeChanged}) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      case onboarding:
        return _buildRoute(const OnboardingScreen(), settings);
      case login:
        return _buildRoute(const LoginScreen(), settings);
      case signup:
        return _buildRoute(const SignupScreen(), settings);
      case home:
        return _buildRoute(const HomeScreen(), settings);
      case chat:
        final chatId = settings.arguments as String?;
        return _buildRoute(ChatScreen(chatId: chatId), settings);
      case imageGenerator:
        return _buildRoute(const ImageGeneratorScreen(), settings);
      case voiceAssistant:
        return _buildRoute(const VoiceAssistantScreen(), settings);
      case history:
        return _buildRoute(const HistoryScreen(), settings);
      case AppRoutes.settings:
        return _buildRoute(SettingsScreen(onThemeChanged: onThemeChanged ?? () {}), settings);
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
      case about:
        return _buildRoute(const AboutScreen(), settings);
      case privacyPolicy:
        return _buildRoute(const PrivacyPolicyScreen(), settings);
      case terms:
        return _buildRoute(const TermsScreen(), settings);
      case premium:
        return _buildRoute(const PremiumScreen(), settings);
      default:
        return _errorRoute(settings);
    }
  }


  static MaterialPageRoute _buildRoute(Widget child, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => child,
      settings: settings,
    );
  }


  static Route<dynamic> _errorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Navigation Error')),
        body: Center(
          child: Text(
            'No route defined for: ${settings.name}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
