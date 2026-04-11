// Preserves the original troubleshooting text exactly as shown to users.
// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class NotificationDebugTipsCard extends StatelessWidget {
  const NotificationDebugTipsCard({required this.l10n, super.key});

  final AppLocalizations l10n;

  static const List<String> _tips = [
    '1. CRITICAL: If "Exact Alarms Permission" shows red NO, tap the red "Enable Exact Alarms" button and turn ON "Alarms & reminders" for MedAssist. WITHOUT THIS, SCHEDULED NOTIFICATIONS WILL NEVER WORK!',
    '2. After enabling exact alarms, test if scheduled notifications work: Tap "Schedule Test (1 Minute)" and wait 1 minute',
    '3. If timezone shows "UTC", tap "Set Timezone Manually" and select your timezone (e.g., Africa/Cairo for Egypt)',
    '4. To enable notification sound, tap "Notification Sound Settings" and ensure Sound is ON',
    '5. Disable battery optimization: Tap "Disable Battery Optimization" and select "Don\'t optimize"',
    '6. For Samsung devices: Also check Settings > Device care > Battery > Background usage limits and remove MedAssist from "Sleeping apps"',
    '7. Make sure notifications are enabled in your system settings',
    '8. Check if Do Not Disturb mode is enabled (this blocks notifications)',
    '9. After fixing permissions, delete and re-add your medications to reschedule notifications',
    "10. If notifications still don't work, restart your device and try the 1-minute test again",
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  l10n.troubleshootingTips,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final tip in _tips) _TipItem(text: tip),
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  const _TipItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
