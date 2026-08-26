import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Palette - Purple/Indigo AI Theme
  static const Color primary = Color(0xFF7C3AED); // Modern Violet
  static const Color secondary = Color(0xFF4F46E5); // Indigo
  static const Color accent = Color(0xFF8B5CF6); // Soft Purple
  
  // Sophisticated Dark Palette - Charcoal/Black
  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800
  static const Color cardDark = Color(0xFF1E293B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC); // Slate 50
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate 400
  static const Color borderDark = Color(0xFF334155); // Slate 700

  // Premium Light Palette - Clean/Soft
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color border = Color(0xFFE2E8F0); // Slate 200

  // Functional Colors
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF64748B); // Slate 500
  
  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF7C3AED),
    Color(0xFF4F46E5),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF8B5CF6),
    Color(0xFFC084FC),
  ];

  static const List<Color> darkGradient = [
    Color(0xFF0F172A),
    Color(0xFF1E293B),
  ];

  // Glows & Shadows
  static Color primaryGlow = const Color(0xFF7C3AED).withValues(alpha: 0.2);
}
