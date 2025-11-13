import 'package:flutter/material.dart';

/// Application settings model
class AppSettings { // Track if user has completed onboarding

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.snoozeDuration = 10,
    this.showLowStockAlerts = true,
    this.showExpiryAlerts = true,
    this.languageCode = 'en',
    this.hasSeenOnboarding = false,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      snoozeDuration: json['snoozeDuration'] as int? ?? 10,
      showLowStockAlerts: json['showLowStockAlerts'] as bool? ?? true,
      showExpiryAlerts: json['showExpiryAlerts'] as bool? ?? true,
      languageCode: json['languageCode'] as String? ?? 'en',
      hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
    );
  }
  final ThemeMode themeMode;
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final int snoozeDuration; // in minutes
  final bool showLowStockAlerts;
  final bool showExpiryAlerts;
  final String languageCode;
  final bool hasSeenOnboarding;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    int? snoozeDuration,
    bool? showLowStockAlerts,
    bool? showExpiryAlerts,
    String? languageCode,
    bool? hasSeenOnboarding,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
      showLowStockAlerts: showLowStockAlerts ?? this.showLowStockAlerts,
      showExpiryAlerts: showExpiryAlerts ?? this.showExpiryAlerts,
      languageCode: languageCode ?? this.languageCode,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.index,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'snoozeDuration': snoozeDuration,
      'showLowStockAlerts': showLowStockAlerts,
      'showExpiryAlerts': showExpiryAlerts,
      'languageCode': languageCode,
      'hasSeenOnboarding': hasSeenOnboarding,
    };
  }
}
