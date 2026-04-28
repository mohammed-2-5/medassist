import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/settings/providers/settings_provider.dart';
import 'package:med_assist/features/settings/widgets/settings_section_header.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Dedicated subpage for all notification & alert preferences.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        flexibleSpace: _GradientBar(),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SettingsSectionHeader(
            title: l10n.notifications,
            icon: Icons.notifications_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.notifications_active,
                    color: cs.primary,
                  ),
                  title: Text(l10n.enableNotifications),
                  subtitle: Text(l10n.receiveMedicationReminders),
                  value: settings.notificationsEnabled,
                  onChanged: notifier.updateNotificationsEnabled,
                ),
                if (settings.notificationsEnabled) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(Icons.volume_up, color: cs.primary),
                    title: Text(l10n.sound),
                    subtitle: Text(l10n.playSoundForNotifications),
                    value: settings.soundEnabled,
                    onChanged: notifier.updateSoundEnabled,
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: Icon(Icons.vibration, color: cs.primary),
                    title: Text(l10n.vibration),
                    subtitle: Text(l10n.vibrateForNotifications),
                    value: settings.vibrationEnabled,
                    onChanged: notifier.updateVibrationEnabled,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.snooze, color: cs.primary),
                    title: Text(l10n.snoozeDuration),
                    subtitle: Text(
                      '${settings.snoozeDuration} ${l10n.minutes}',
                    ),
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
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          SettingsSectionHeader(
            title: l10n.alerts,
            icon: Icons.warning_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(Icons.inventory_2, color: cs.primary),
                  title: Text(l10n.lowStockAlerts),
                  subtitle: Text(l10n.notifyWhenLow),
                  value: settings.showLowStockAlerts,
                  onChanged: notifier.updateShowLowStockAlerts,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Icon(Icons.calendar_today, color: cs.primary),
                  title: Text(l10n.expiryAlerts),
                  subtitle: Text(l10n.notifyWhenExpiring),
                  value: settings.showExpiryAlerts,
                  onChanged: notifier.updateShowExpiryAlerts,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SettingsSectionHeader(
            title: l10n.troubleshootNotifications,
            icon: Icons.build_outlined,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.bug_report, color: Colors.orange),
              title: Text(l10n.troubleshootNotifications),
              subtitle: Text(l10n.testAndFix),
              trailing: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
              ),
              onTap: () => context.push('/diagnostics/notifications'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _GradientBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cs.primary, cs.secondary],
        ),
      ),
    );
  }
}
