import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Debug screen for testing and troubleshooting notifications
class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() => _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  final _notificationService = NotificationService();
  Map<String, dynamic>? _diagnostics;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() => _loading = true);
    try {
      final diagnostics = await _notificationService.getDiagnostics();
      setState(() {
        _diagnostics = diagnostics;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading diagnostics: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _sendTestNotification() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _notificationService.showTestNotification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.testNotificationMessage),
            backgroundColor: Colors.green,
          ),
        );
      }
      await _loadDiagnostics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _scheduleTestNotification() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _notificationService.scheduleTestNotificationIn1Minute();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.notificationScheduled),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      await _loadDiagnostics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestPermissions() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final granted = await _notificationService.requestPermissions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(granted
                ? l10n.permissionsGranted
                : l10n.someDenied),
            backgroundColor: granted ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      await _loadDiagnostics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _requestExactAlarmsPermission() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      // First try to request it directly
      final granted = await _notificationService.requestExactAlarmsPermission();

      if (!granted) {
        // If not granted, open settings
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.openingSettings),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        await _notificationService.openExactAlarmSettings();
      }

      await Future.delayed(const Duration(seconds: 2));
      await _loadDiagnostics();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationDiagnostics),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDiagnostics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  _buildStatusCard(l10n),
                  const SizedBox(height: 16),

                  // Quick Actions
                  _buildQuickActions(l10n),
                  const SizedBox(height: 16),

                  // Pending Notifications
                  _buildPendingNotifications(l10n),
                  const SizedBox(height: 16),

                  // Troubleshooting Tips
                  _buildTroubleshootingTips(l10n),
                ],
              ),
            ),
    );
  }

  Widget _buildStatusCard(AppLocalizations l10n) {
    final notificationsEnabled = (_diagnostics?['notificationsEnabled'] as bool?) ?? false;
    final canScheduleExact = (_diagnostics?['canScheduleExactAlarms'] as bool?) ?? false;
    final pendingCount = (_diagnostics?['pendingNotificationsCount'] as int?) ?? 0;
    final timezone = (_diagnostics?['timezoneConfigured'] as String?) ?? 'Unknown';
    final deviceTimeHour = (_diagnostics?['deviceTimeHour'] as int?) ?? 0;
    final deviceTimeMinute = (_diagnostics?['deviceTimeMinute'] as int?) ?? 0;
    final isTimezoneUTC = timezone == 'UTC';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.statusLabel,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildStatusRow(
              l10n.notificationsEnabled,
              notificationsEnabled,
              notificationsEnabled ? Icons.check_circle : Icons.error,
              notificationsEnabled ? Colors.green : Colors.red,
              l10n,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              l10n.exactAlarmsPermission,
              canScheduleExact,
              canScheduleExact ? Icons.check_circle : Icons.error,
              canScheduleExact ? Colors.green : Colors.red,
              l10n,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.pendingNotifications, '$pendingCount'),
            const SizedBox(height: 8),
            _buildInfoRow(l10n.deviceTime, '${deviceTimeHour.toString().padLeft(2, '0')}:${deviceTimeMinute.toString().padLeft(2, '0')}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  l10n.timezone,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                if (isTimezoneUTC)
                  const Icon(Icons.warning, color: Colors.orange, size: 18),
                if (isTimezoneUTC)
                  const SizedBox(width: 4),
                Text(
                  timezone,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isTimezoneUTC ? Colors.orange : null,
                  ),
                ),
              ],
            ),
            if (!canScheduleExact) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.criticalExactAlarms,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (isTimezoneUTC) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.timezoneUTC,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool status, IconData icon, Color color, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const Spacer(),
        Text(
          status ? l10n.yes : l10n.no,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
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
              onPressed: _sendTestNotification,
              icon: const Icon(Icons.notifications_active),
              label: Text(l10n.sendTestNotification),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _scheduleTestNotification,
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
              onPressed: _requestPermissions,
              icon: const Icon(Icons.security),
              label: Text(l10n.requestPermissions),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _requestExactAlarmsPermission,
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
              onPressed: _notificationService.requestBatteryOptimizationExemption,
              icon: const Icon(Icons.battery_saver),
              label: Text(l10n.disableBatteryOptimization),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _notificationService.openAppNotificationSettings,
              icon: const Icon(Icons.settings),
              label: Text(l10n.appNotificationSettings),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _showTimezoneSelector,
              icon: const Icon(Icons.public),
              label: Text(l10n.setTimezoneManually),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _notificationService.openMedicationReminderSoundSettings,
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

  Future<void> _showTimezoneSelector() async {
    final l10n = AppLocalizations.of(context)!;
    final timezones = _notificationService.getCommonTimezones();

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTimezone),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: timezones.length,
            itemBuilder: (context, index) {
              final tz = timezones[index];
              return ListTile(
                title: Text(tz),
                onTap: () => Navigator.of(context).pop(tz),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      final l10nContext = AppLocalizations.of(context)!;
      final success = await _notificationService.setTimezone(selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? '${l10nContext.timezone} $selected'
                : l10nContext.errorMessage('Failed to set timezone')),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          await _loadDiagnostics();
        }
      }
    }
  }

  Widget _buildPendingNotifications(AppLocalizations l10n) {
    final pending = _diagnostics?['pendingNotifications'] as List<dynamic>? ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.pendingNotifications} (${pending.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            if (pending.isEmpty)
              Text(
                l10n.noRemindersSet,
                style: const TextStyle(color: Colors.grey),
              )
            else
              ...pending.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ID: ${p['id'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (p['title'] as String?) ?? 'No title',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            (p['body'] as String?) ?? 'No body',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildTroubleshootingTips(AppLocalizations l10n) {
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
            _buildTipItem(
              '1. CRITICAL: If "Exact Alarms Permission" shows red NO, tap the red "Enable Exact Alarms" button and turn ON "Alarms & reminders" for MedAssist. WITHOUT THIS, SCHEDULED NOTIFICATIONS WILL NEVER WORK!',
            ),
            _buildTipItem(
              '2. After enabling exact alarms, test if scheduled notifications work: Tap "Schedule Test (1 Minute)" and wait 1 minute',
            ),
            _buildTipItem(
              '3. If timezone shows "UTC", tap "Set Timezone Manually" and select your timezone (e.g., Africa/Cairo for Egypt)',
            ),
            _buildTipItem(
              '4. To enable notification sound, tap "Notification Sound Settings" and ensure Sound is ON',
            ),
            _buildTipItem(
              '5. Disable battery optimization: Tap "Disable Battery Optimization" and select "Don\'t optimize"',
            ),
            _buildTipItem(
              '6. For Samsung devices: Also check Settings > Device care > Battery > Background usage limits and remove MedAssist from "Sleeping apps"',
            ),
            _buildTipItem(
              '7. Make sure notifications are enabled in your system settings',
            ),
            _buildTipItem(
              '8. Check if Do Not Disturb mode is enabled (this blocks notifications)',
            ),
            _buildTipItem(
              '9. After fixing permissions, delete and re-add your medications to reschedule notifications',
            ),
            _buildTipItem(
              "10. If notifications still don't work, restart your device and try the 1-minute test again",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
