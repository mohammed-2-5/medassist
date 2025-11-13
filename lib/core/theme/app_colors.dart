import 'package:flutter/material.dart';

/// Modern medical app color palette
/// Designed to be calming, trustworthy, and professional
class AppColors {
  AppColors._();

  // Primary Colors - Medical Blue/Teal gradient
  static const Color primaryBlue = Color(0xFF0BA9A7); // Calm medical teal
  static const Color primaryDark = Color(0xFF088B89); // Darker teal
  static const Color primaryLight = Color(0xFF4DD0CE); // Light teal

  // Accent Colors
  static const Color accentGreen = Color(0xFF66BB6A); // Success green
  static const Color accentOrange = Color(0xFFFF9F43); // Warning/attention
  static const Color accentPurple = Color(0xFF9C88FF); // Premium purple
  static const Color accentPink = Color(0xFFFF6B9D); // Friendly pink

  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color warningOrange = Color(0xFFFF9800);
  static const Color errorRed = Color(0xFFEF5350);
  static const Color infoBlue = Color(0xFF42A5F5);

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFF1F5F9);

  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);

  // Text Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFF8FAFC);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0BA9A7), Color(0xFF4DD0CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [Color(0xFFFF9F43), Color(0xFFFFB74D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF9C88FF), Color(0xFFB39DDB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF8AB0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Time-of-day specific colors
  static const Color morningColor = Color(0xFFFFB74D); // Warm morning
  static const Color afternoonColor = Color(0xFF42A5F5); // Clear afternoon blue
  static const Color eveningColor = Color(0xFF9C88FF); // Evening purple
  static const Color nightColor = Color(0xFF5C6BC0); // Night indigo

  // Glassmorphism colors
  static Color glassWhite = Colors.white.withOpacity(0.2);
  static Color glassBlack = Colors.black.withOpacity(0.1);
}
