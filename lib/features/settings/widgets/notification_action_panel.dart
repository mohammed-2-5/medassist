import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class NotificationActionPanel extends StatelessWidget {
  const NotificationActionPanel({
    required this.l10n,
    required this.onSendTestNotification,
    required this.onScheduleTestNotification,
    required this.onRequestPermissions,
    required this.onRequestExactAlarmsPermission,
    required this.onRequestBatteryOptimizationExemption,
    required this.onOpenAppNotificationSettings,
    required this.onShowTimezoneSelector,
    required this.onOpenSoundSettings,
    super.key,
  });

  final AppLocalizations l10n;
  final VoidCallback onSendTestNotification;
  final VoidCallback onScheduleTestNotification;
  final VoidCallback onRequestPermissions;
  final VoidCallback onRequestExactAlarmsPermission;
  final VoidCallback onRequestBatteryOptimizationExemption;
  final VoidCallback onOpenAppNotificationSettings;
  final VoidCallback onShowTimezoneSelector;
  final VoidCallback onOpenSoundSettings;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onSendTestNotification,
              icon: const Icon(Icons.notifications_active),
              label: Text(l10n.sendTestNotification),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onScheduleTestNotification,
              icon: const Icon(Icons.schedule),
              label: Text(l10n.scheduleTest),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRequestPermissions,
              icon: const Icon(Icons.security),
              label: Text(l10n.requestPermissions),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: onRequestExactAlarmsPermission,
              icon: const Icon(Icons.alarm),
              label: Text(l10n.enableExactAlarms),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRequestBatteryOptimizationExemption,
              icon: const Icon(Icons.battery_saver),
              label: Text(l10n.disableBatteryOptimization),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onOpenAppNotificationSettings,
              icon: const Icon(Icons.settings),
              label: Text(l10n.appNotificationSettings),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onShowTimezoneSelector,
              icon: const Icon(Icons.public),
              label: Text(l10n.setTimezoneManually),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onOpenSoundSettings,
              icon: const Icon(Icons.volume_up),
              label: Text(l10n.notificationSoundSettings),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
