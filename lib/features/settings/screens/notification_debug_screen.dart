import 'dart:async';

import 'package:flutter/material.dart';
import 'package:med_assist/features/settings/widgets/notification_action_panel.dart';
import 'package:med_assist/features/settings/widgets/notification_debug_status_card.dart';
import 'package:med_assist/features/settings/widgets/notification_debug_tips_card.dart';
import 'package:med_assist/features/settings/widgets/notification_log_view.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// Debug screen for testing and troubleshooting notifications
class NotificationDebugScreen extends StatefulWidget {
  const NotificationDebugScreen({super.key});

  @override
  State<NotificationDebugScreen> createState() =>
      _NotificationDebugScreenState();
}

class _NotificationDebugScreenState extends State<NotificationDebugScreen> {
  final _notificationService = NotificationService();
  Map<String, dynamic>? _diagnostics;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDiagnostics());
  }

  Future<void> _loadDiagnostics() async {
    setState(() => _loading = true);
    try {
      final diagnostics = await _notificationService.getDiagnostics();
      if (!mounted) return;
      setState(() {
        _diagnostics = diagnostics;
        _loading = false;
      });
    } on Object catch (e) {
      debugPrint('Error loading diagnostics: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _sendTestNotification() async {
    await _runAction(
      action: _notificationService.showTestNotification,
      successMessage: AppLocalizations.of(context)!.testNotificationMessage,
      successColor: Colors.green,
    );
  }

  Future<void> _scheduleTestNotification() async {
    await _runAction(
      action: _notificationService.scheduleTestNotificationIn1Minute,
      successMessage: AppLocalizations.of(context)!.notificationScheduled,
      successColor: Colors.orange,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _requestPermissions() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final granted = await _notificationService.requestPermissions();
      _showSnackBar(
        granted ? l10n.permissionsGranted : l10n.someDenied,
        granted ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 5),
      );
      await _loadDiagnostics();
    } on Object catch (e) {
      _showError(e);
    }
  }

  Future<void> _requestExactAlarmsPermission() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final granted = await _notificationService.requestExactAlarmsPermission();

      if (!granted) {
        _showSnackBar(
          l10n.openingSettings,
          Colors.orange,
          duration: const Duration(seconds: 5),
        );
        await _notificationService.openExactAlarmSettings();
      }

      await Future<void>.delayed(const Duration(seconds: 2));
      await _loadDiagnostics();
    } on Object catch (e) {
      _showError(e);
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
                  NotificationDebugStatusCard(
                    diagnostics: _diagnostics,
                    l10n: l10n,
                  ),
                  const SizedBox(height: 16),
                  NotificationActionPanel(
                    l10n: l10n,
                    onSendTestNotification: _sendTestNotification,
                    onScheduleTestNotification: _scheduleTestNotification,
                    onRequestPermissions: _requestPermissions,
                    onRequestExactAlarmsPermission:
                        _requestExactAlarmsPermission,
                    onRequestBatteryOptimizationExemption: _notificationService
                        .requestBatteryOptimizationExemption,
                    onOpenAppNotificationSettings:
                        _notificationService.openAppNotificationSettings,
                    onShowTimezoneSelector: _showTimezoneSelector,
                    onOpenSoundSettings: _notificationService
                        .openMedicationReminderSoundSettings,
                  ),
                  const SizedBox(height: 16),

                  // Pending Notifications
                  NotificationLogView(
                    l10n: l10n,
                    pending:
                        (_diagnostics?['pendingNotifications']
                                    as List<dynamic>? ??
                                [])
                            .whereType<Map<String, dynamic>>()
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  NotificationDebugTipsCard(l10n: l10n),
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
      _showSnackBar(
        success
            ? '${l10nContext.timezone} $selected'
            : l10nContext.errorMessage('Failed to set timezone'),
        success ? Colors.green : Colors.red,
      );
      if (success) await _loadDiagnostics();
    }
  }

  Future<void> _runAction({
    required Future<void> Function() action,
    required String successMessage,
    required Color successColor,
    Duration? duration,
  }) async {
    try {
      await action();
      _showSnackBar(successMessage, successColor, duration: duration);
      await _loadDiagnostics();
    } on Object catch (e) {
      _showError(e);
    }
  }

  void _showSnackBar(String message, Color color, {Duration? duration}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration ?? const Duration(seconds: 4),
      ),
    );
  }

  void _showError(Object error) {
    final l10n = AppLocalizations.of(context)!;
    _showSnackBar(l10n.errorMessage(error.toString()), Colors.red);
  }
}
