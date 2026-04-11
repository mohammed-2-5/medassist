import 'package:flutter/material.dart';

class AppColorSchemes {
  AppColorSchemes._();

  static const Color _primaryLight = Color(0xFF1976D2);
  static const Color _primaryDark = Color(0xFF42A5F5);
  static const Color _secondaryLight = Color(0xFF43A047);
  static const Color _secondaryDark = Color(0xFF66BB6A);
  static const Color _errorLight = Color(0xFFD32F2F);
  static const Color _errorDark = Color(0xFFEF5350);
  static const Color _surfaceLight = Color(0xFFFAFAFA);

  static ColorScheme light() {
    return ColorScheme.light(
      primary: _primaryLight,
      primaryContainer: const Color(0xFFBBDEFB),
      onPrimaryContainer: const Color(0xFF0D47A1),
      secondary: _secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFE3F2FD),
      onSecondaryContainer: const Color(0xFF0D47A1),
      tertiary: const Color(0xFF6A1B9A),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFF3E5F5),
      onTertiaryContainer: const Color(0xFF4A148C),
      error: _errorLight,
      errorContainer: const Color(0xFFFFEBEE),
      onErrorContainer: const Color(0xFFB71C1C),
      surface: _surfaceLight,
      onSurface: const Color(0xFF1C1B1F),
      surfaceContainerHighest: const Color(0xFFE7E0EC),
      outline: const Color(0xFF79747E),
      outlineVariant: const Color(0xFFCAC4D0),
      shadow: Colors.black.withOpacity(0.1),
      scrim: Colors.black.withOpacity(0.5),
      inverseSurface: const Color(0xFF313033),
      onInverseSurface: const Color(0xFFF4EFF4),
      inversePrimary: _primaryDark,
    );
  }

  static ColorScheme dark() {
    return ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: const Color(0xFF003258),
      primaryContainer: const Color(0xFF1565C0),
      onPrimaryContainer: const Color(0xFFBBDEFB),
      secondary: _secondaryDark,
      onSecondary: const Color(0xFF003258),
      secondaryContainer: const Color(0xFF004881),
      onSecondaryContainer: const Color(0xFFE3F2FD),
      tertiary: const Color(0xFFCE93D8),
      onTertiary: const Color(0xFF38064E),
      tertiaryContainer: const Color(0xFF51216C),
      onTertiaryContainer: const Color(0xFFE1BEE7),
      error: _errorDark,
      onError: const Color(0xFF5F0000),
      errorContainer: const Color(0xFF8C0000),
      onErrorContainer: const Color(0xFFFFDAD6),
      onSurface: const Color(0xFFE6E1E5),
      surfaceContainerHighest: const Color(0xFF36343B),
      outline: const Color(0xFF938F99),
      outlineVariant: const Color(0xFF49454F),
      shadow: Colors.black.withOpacity(0.3),
      scrim: Colors.black.withOpacity(0.7),
      inverseSurface: const Color(0xFFE6E1E5),
      onInverseSurface: const Color(0xFF313033),
      inversePrimary: _primaryLight,
    );
  }
}
