import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class NotificationDebugStatusCard extends StatelessWidget {
  const NotificationDebugStatusCard({
    required this.diagnostics,
    required this.l10n,
    super.key,
  });

  final Map<String, dynamic>? diagnostics;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsEnabled =
        (diagnostics?['notificationsEnabled'] as bool?) ?? false;
    final canScheduleExact =
        (diagnostics?['canScheduleExactAlarms'] as bool?) ?? false;
    final pendingCount =
        (diagnostics?['pendingNotificationsCount'] as int?) ?? 0;
    final timezone =
        (diagnostics?['timezoneConfigured'] as String?) ?? 'Unknown';
    final deviceTimeHour = (diagnostics?['deviceTimeHour'] as int?) ?? 0;
    final deviceTimeMinute = (diagnostics?['deviceTimeMinute'] as int?) ?? 0;
    final isTimezoneUTC = timezone == 'UTC';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statusLabel,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _StatusRow(
              label: l10n.notificationsEnabled,
              status: notificationsEnabled,
              l10n: l10n,
            ),
            const SizedBox(height: 8),
            _StatusRow(
              label: l10n.exactAlarmsPermission,
              status: canScheduleExact,
              l10n: l10n,
            ),
            const SizedBox(height: 8),
            _InfoRow(label: l10n.pendingNotifications, value: '$pendingCount'),
            const SizedBox(height: 8),
            _InfoRow(
              label: l10n.deviceTime,
              value:
                  '${deviceTimeHour.toString().padLeft(2, '0')}:'
                  '${deviceTimeMinute.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 8),
            _TimezoneRow(
              label: l10n.timezone,
              timezone: timezone,
              isTimezoneUTC: isTimezoneUTC,
            ),
            if (!canScheduleExact) ...[
              const SizedBox(height: 8),
              _WarningBox(
                icon: Icons.error,
                color: theme.colorScheme.error,
                backgroundColor: theme.colorScheme.errorContainer,
                textColor: theme.colorScheme.onErrorContainer,
                text: l10n.criticalExactAlarms,
                isBold: true,
              ),
            ],
            if (isTimezoneUTC) ...[
              const SizedBox(height: 8),
              _WarningBox(
                icon: Icons.warning,
                color: theme.colorScheme.tertiary,
                backgroundColor: theme.colorScheme.tertiaryContainer,
                textColor: theme.colorScheme.onTertiaryContainer,
                text: l10n.timezoneUTC,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.status,
    required this.l10n,
  });

  final String label;
  final bool status;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final color = status ? Colors.green : Colors.red;
    return Row(
      children: [
        Icon(status ? Icons.check_circle : Icons.error, color: color, size: 20),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(
          status ? l10n.yes : l10n.no,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _TimezoneRow extends StatelessWidget {
  const _TimezoneRow({
    required this.label,
    required this.timezone,
    required this.isTimezoneUTC,
  });

  final String label;
  final String timezone;
  final bool isTimezoneUTC;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const Spacer(),
        if (isTimezoneUTC)
          const Icon(Icons.warning, color: Colors.orange, size: 18),
        if (isTimezoneUTC) const SizedBox(width: 4),
        Text(
          timezone,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isTimezoneUTC ? Colors.orange : null,
          ),
        ),
      ],
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox({
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.textColor,
    required this.text,
    this.isBold = false,
  });

  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final Color textColor;
  final String text;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
