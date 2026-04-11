import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/settings/providers/settings_provider.dart';
import 'package:med_assist/features/settings/widgets/settings_dialogs.dart';
import 'package:med_assist/features/settings/widgets/settings_screen_body.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Settings screen for app preferences
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    unawaited(_loadPackageInfo());
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        flexibleSpace: _SettingsAppBarGradient(),
      ),
      body: SettingsScreenBody(
        packageInfo: _packageInfo,
        onShowThemeDialog: () => _showThemeDialog(context),
        onShowLanguageDialog: () => _showLanguageDialog(context),
        onShowResetDialog: () => _showResetDialog(context),
      ),
    );
  }

  void _showThemeDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);
    unawaited(showThemeDialog(
      context: context,
      selectedThemeMode: settings.themeMode,
      onThemeChanged: (value) {
        return ref.read(settingsProvider.notifier).updateThemeMode(value);
      },
    ));
  }

  void _showLanguageDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);
    unawaited(showLanguageDialog(
      context: context,
      selectedLanguageCode: settings.languageCode,
      onLanguageChanged: (value) {
        return ref.read(settingsProvider.notifier).updateLanguageCode(value);
      },
    ));
  }

  void _showResetDialog(BuildContext context) {
    unawaited(showResetDialog(
      context: context,
      onReset: () {
        return ref.read(settingsProvider.notifier).resetToDefaults();
      },
    ));
  }
}

class _SettingsAppBarGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
      ),
    );
  }
}
