import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/settings/models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _settingsKey = 'app_settings';

/// Settings notifier with persistence
class SettingsNotifier extends Notifier<AppSettings> {
  SharedPreferences? _prefs;

  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final settingsJson = _prefs?.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        final json = jsonDecode(settingsJson) as Map<String, dynamic>;
        state = AppSettings.fromJson(json);
      } catch (e) {
        // If loading fails, keep default settings
        state = const AppSettings();
      }
    }
  }

  Future<void> _saveSettings() async {
    _prefs ??= await SharedPreferences.getInstance();
    final settingsJson = jsonEncode(state.toJson());
    await _prefs!.setString(_settingsKey, settingsJson);
  }

  // Theme Mode
  Future<void> updateThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _saveSettings();
  }

  // Notifications
  Future<void> updateNotificationsEnabled(bool enabled) async {
    state = state.copyWith(notificationsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateSnoozeDuration(int duration) async {
    state = state.copyWith(snoozeDuration: duration);
    await _saveSettings();
  }

  // Alerts
  Future<void> updateShowLowStockAlerts(bool enabled) async {
    state = state.copyWith(showLowStockAlerts: enabled);
    await _saveSettings();
  }

  Future<void> updateShowExpiryAlerts(bool enabled) async {
    state = state.copyWith(showExpiryAlerts: enabled);
    await _saveSettings();
  }

  // Language
  Future<void> updateLanguageCode(String languageCode) async {
    state = state.copyWith(languageCode: languageCode);
    await _saveSettings();
  }

  // Onboarding
  Future<void> markOnboardingComplete() async {
    state = state.copyWith(hasSeenOnboarding: true);
    await _saveSettings();
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    state = const AppSettings();
    await _saveSettings();
  }
}

/// Settings provider
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
