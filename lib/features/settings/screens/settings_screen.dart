import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/settings/providers/settings_provider.dart';
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
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Theme Section
          _buildSectionHeader(theme, l10n.appearance, Icons.palette),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.brightness_6, color: colorScheme.primary),
                  title: Text(l10n.themeMode),
                  subtitle: Text(_getThemeModeLabel(settings.themeMode, l10n)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showThemeDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          _buildSectionHeader(theme, l10n.notifications, Icons.notifications),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.notifications_active,
                      color: colorScheme.primary),
                  title: Text(l10n.enableNotifications),
                  subtitle: Text(l10n.receiveMedicationReminders),
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateNotificationsEnabled(value);
                  },
                ),
                if (settings.notificationsEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(Icons.volume_up, color: colorScheme.primary),
                    title: Text(l10n.sound),
                    subtitle: Text(l10n.playSoundForNotifications),
                    value: settings.soundEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateSoundEnabled(value);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(Icons.vibration, color: colorScheme.primary),
                    title: Text(l10n.vibration),
                    subtitle: Text(l10n.vibrateForNotifications),
                    value: settings.vibrationEnabled,
                    onChanged: (value) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateVibrationEnabled(value);
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.snooze, color: colorScheme.primary),
                    title: Text(l10n.snoozeDuration),
                    subtitle: Text('${settings.snoozeDuration} ${l10n.minutes}'),
                    trailing: SizedBox(
                      width: 150,
                      child: Slider(
                        value: settings.snoozeDuration.toDouble(),
                        min: 5,
                        max: 60,
                        divisions: 11,
                        label: '${settings.snoozeDuration} min',
                        onChanged: (value) {
                          ref
                              .read(settingsProvider.notifier)
                              .updateSnoozeDuration(value.round());
                        },
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.bug_report, color: Colors.orange),
                    title: Text(l10n.troubleshootNotifications),
                    subtitle: Text(l10n.testAndFix),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.push('/diagnostics/notifications');
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Alerts Section
          _buildSectionHeader(theme, l10n.alerts, Icons.warning),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.inventory_2, color: colorScheme.primary),
                  title: Text(l10n.lowStockAlerts),
                  subtitle: Text(l10n.notifyWhenLow),
                  value: settings.showLowStockAlerts,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateShowLowStockAlerts(value);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary:
                      Icon(Icons.calendar_today, color: colorScheme.primary),
                  title: Text(l10n.expiryAlerts),
                  subtitle: Text(l10n.notifyWhenExpiring),
                  value: settings.showExpiryAlerts,
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateShowExpiryAlerts(value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language Section
          _buildSectionHeader(theme, l10n.language, Icons.language),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.translate, color: colorScheme.primary),
              title: Text(l10n.appLanguage),
              subtitle: Text(_getLanguageLabel(settings.languageCode, l10n)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageDialog(context),
            ),
          ),
          const SizedBox(height: 24),

          // Data & Reset Section
          _buildSectionHeader(theme, l10n.data, Icons.storage),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.backup, color: colorScheme.primary),
                  title: Text(l10n.backupRestore ?? 'Backup & Restore'),
                  subtitle: Text(l10n.backupRestoreSubtitle ?? 'Save or restore your data'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/settings/backup');
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.restore, color: Colors.orange),
                  title: Text(l10n.resetToDefaults),
                  subtitle: Text(l10n.restoreAllSettings),
                  onTap: () => _showResetDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(theme, l10n.about, Icons.info),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.apps, color: colorScheme.primary),
                  title: Text(l10n.appName),
                  subtitle: Text(_packageInfo?.appName ?? 'Med Assist'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.info_outline, color: colorScheme.primary),
                  title: Text(l10n.version),
                  subtitle: Text(_packageInfo?.version ?? '1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.build, color: colorScheme.primary),
                  title: Text(l10n.buildNumber),
                  subtitle: Text(_packageInfo?.buildNumber ?? '1'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Info Card
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.settingsAutoSaved,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getThemeModeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  String _getLanguageLabel(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.english;
      case 'ar':
        return l10n.arabic;
      default:
        return l10n.english;
    }
  }

  void _showThemeDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.light),
              subtitle: Text(l10n.alwaysLight),
              value: ThemeMode.light,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.dark),
              subtitle: Text(l10n.alwaysDark),
              value: ThemeMode.dark,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemDefault),
              subtitle: Text(l10n.followSystem),
              value: ThemeMode.system,
              groupValue: settings.themeMode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.english),
              subtitle: Text(l10n.english),
              value: 'en',
              groupValue: settings.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguageCode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.arabic),
              subtitle: Text(l10n.arabic),
              value: 'ar',
              groupValue: settings.languageCode,
              onChanged: (value) {
                if (value != null) {
                  ref.read(settingsProvider.notifier).updateLanguageCode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetSettings),
        content: Text(l10n.resetSettingsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await ref.read(settingsProvider.notifier).resetToDefaults();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.settingsReset),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }
}
