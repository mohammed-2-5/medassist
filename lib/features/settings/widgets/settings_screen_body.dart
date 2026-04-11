import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/settings/models/app_settings.dart';
import 'package:med_assist/features/settings/providers/settings_provider.dart';
import 'package:med_assist/features/settings/widgets/settings_section_header.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreenBody extends ConsumerWidget {
  const SettingsScreenBody({
    required this.packageInfo,
    required this.onShowThemeDialog,
    required this.onShowLanguageDialog,
    required this.onShowResetDialog,
    super.key,
  });

  final PackageInfo? packageInfo;
  final VoidCallback onShowThemeDialog;
  final VoidCallback onShowLanguageDialog;
  final VoidCallback onShowResetDialog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SettingsSectionHeader(title: l10n.appearance, icon: Icons.palette),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Icons.brightness_6, color: colorScheme.primary),
            title: Text(l10n.themeMode),
            subtitle: Text(_themeModeLabel(settings.themeMode, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: onShowThemeDialog,
          ),
        ),
        const SizedBox(height: 24),
        SettingsSectionHeader(
          title: l10n.notifications,
          icon: Icons.notifications,
        ),
        const SizedBox(height: 8),
        _NotificationSection(settings: settings, notifier: notifier),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: l10n.alerts, icon: Icons.warning),
        const SizedBox(height: 8),
        _AlertsSection(settings: settings, notifier: notifier),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: l10n.language, icon: Icons.language),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: Icon(Icons.translate, color: colorScheme.primary),
            title: Text(l10n.appLanguage),
            subtitle: Text(_languageLabel(settings.languageCode, l10n)),
            trailing: const Icon(Icons.chevron_right),
            onTap: onShowLanguageDialog,
          ),
        ),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: l10n.data, icon: Icons.storage),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.backup, color: colorScheme.primary),
                title: Text(l10n.backupRestore),
                subtitle: Text(l10n.backupRestoreSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/backup'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.restore, color: Colors.orange),
                title: Text(l10n.resetToDefaults),
                subtitle: Text(l10n.restoreAllSettings),
                onTap: onShowResetDialog,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SettingsSectionHeader(title: l10n.about, icon: Icons.info),
        const SizedBox(height: 8),
        _AboutSection(packageInfo: packageInfo),
        const SizedBox(height: 32),
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer),
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
    );
  }

  String _themeModeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  String _languageLabel(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.english;
      case 'ar':
        return l10n.arabic;
      default:
        return l10n.english;
    }
  }
}

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({required this.settings, required this.notifier});

  final AppSettings settings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              Icons.notifications_active,
              color: colorScheme.primary,
            ),
            title: Text(l10n.enableNotifications),
            subtitle: Text(l10n.receiveMedicationReminders),
            value: settings.notificationsEnabled,
            onChanged: notifier.updateNotificationsEnabled,
          ),
          if (settings.notificationsEnabled) ...[
            const Divider(height: 1),
            SwitchListTile(
              secondary: Icon(Icons.volume_up, color: colorScheme.primary),
              title: Text(l10n.sound),
              subtitle: Text(l10n.playSoundForNotifications),
              value: settings.soundEnabled,
              onChanged: notifier.updateSoundEnabled,
            ),
            const Divider(height: 1),
            SwitchListTile(
              secondary: Icon(Icons.vibration, color: colorScheme.primary),
              title: Text(l10n.vibration),
              subtitle: Text(l10n.vibrateForNotifications),
              value: settings.vibrationEnabled,
              onChanged: notifier.updateVibrationEnabled,
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
                  onChanged: (value) =>
                      notifier.updateSnoozeDuration(value.round()),
                ),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: Text(l10n.troubleshootNotifications),
              subtitle: Text(l10n.testAndFix),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/diagnostics/notifications'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertsSection extends StatelessWidget {
  const _AlertsSection({required this.settings, required this.notifier});

  final AppSettings settings;
  final SettingsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(Icons.inventory_2, color: colorScheme.primary),
            title: Text(l10n.lowStockAlerts),
            subtitle: Text(l10n.notifyWhenLow),
            value: settings.showLowStockAlerts,
            onChanged: notifier.updateShowLowStockAlerts,
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Icon(Icons.calendar_today, color: colorScheme.primary),
            title: Text(l10n.expiryAlerts),
            subtitle: Text(l10n.notifyWhenExpiring),
            value: settings.showExpiryAlerts,
            onChanged: notifier.updateShowExpiryAlerts,
          ),
        ],
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.packageInfo});

  final PackageInfo? packageInfo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.apps, color: colorScheme.primary),
            title: Text(l10n.appName),
            subtitle: Text(packageInfo?.appName ?? 'Med Assist'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.info_outline, color: colorScheme.primary),
            title: Text(l10n.version),
            subtitle: Text(packageInfo?.version ?? '1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.build, color: colorScheme.primary),
            title: Text(l10n.buildNumber),
            subtitle: Text(packageInfo?.buildNumber ?? '1'),
          ),
        ],
      ),
    );
  }
}
