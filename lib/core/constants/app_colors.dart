import 'package:flutter/material.dart';

class AppColors {
  // Deep premium dark backgrounds
  static const Color background = Color(0xFF0F0E17);
  static const Color surface = Color(0xFF1E1C2A);
  static const Color surfaceElevated = Color(0xFF2E2B3E);
  
  // Neon Accents
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF8D87FF);
  static const Color primaryDark = Color(0xFF4B42E6);
  
  // Known / Swipe Right
  static const Color success = Color(0xFF00F5A0);
  
  // Needs Practice / Swipe Left
  static const Color error = Color(0xFFFF3F6C);
  
  // Neutral Text
  static const Color textPrimary = Color(0xFFFFFFFE);
  static const Color textSecondary = Color(0xFFA7A9BE);
  static const Color textMuted = Color(0xFF5F627A);
  
  // Shading / Border / Glassmorphism
  static const Color border = Color(0xFF332F46);
  static const Color glow = Color(0xFF6C63FF);
  
  // Premium Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF9D63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF0F0E17), Color(0xFF151421)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [Color(0xFF00F5A0), Color(0xFF00D2B4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient errorGradient = LinearGradient(
    colors: [Color(0xFFFF3F6C), Color(0xFFFF5D8F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E1C2A), Color(0xFF232135)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
