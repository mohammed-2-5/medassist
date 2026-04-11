import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/diagnostics/widgets/diagnostics_screen_app_bar.dart';
import 'package:med_assist/features/diagnostics/widgets/diagnostics_screen_content.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';
import 'package:med_assist/services/notification/notification_service.dart';

/// System Health & Diagnostics Screen
class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  final _notificationService = NotificationService();
  Map<String, dynamic>? _diagnostics;
  Map<String, int>? _dbStats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDiagnostics());
  }

  Future<void> _loadDiagnostics() async {
    setState(() => _loading = true);
    try {
      final diagnostics = await _notificationService.getDiagnostics();
      final database = ref.read(appDatabaseProvider);

      // Get database statistics
      final medications = await database.getAllMedications();
      final allHistory = await database.getAllDoseHistory();

      setState(() {
        _diagnostics = diagnostics;
        _dbStats = {
          'medications': medications.length,
          'doseHistory': allHistory.length,
          'activeMeds': medications.where((m) => m.isActive).length,
        };
        _loading = false;
      });
    } on Object catch (e) {
      debugPrint('Error loading diagnostics: $e');
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          DiagnosticsScreenAppBar(
            title: AppLocalizations.of(context)!.systemHealth,
            subtitle: AppLocalizations.of(context)!.appDiagnostics,
            onRefresh: () {
              HapticService.light();
              _loadDiagnostics();
            },
          ),
          DiagnosticsScreenContent(
            loading: _loading,
            diagnostics: _diagnostics,
            dbStats: _dbStats,
            onSendTestNotification: _sendTestNotificationAction,
            onScheduleTestNotification: _scheduleTestNotificationAction,
            onRequestPermissions: _requestPermissionsAction,
          ),
        ],
      ),
    );
  }

  Future<void> _sendTestNotificationAction() async {
    await HapticService.medium();
    await _notificationService.showTestNotification();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.testNotificationSent),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  Future<void> _scheduleTestNotificationAction() async {
    await HapticService.medium();
    await _notificationService.scheduleTestNotificationIn1Minute();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.testScheduled),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _requestPermissionsAction() async {
    await HapticService.medium();
    final granted = await _notificationService.requestPermissions();
    await _loadDiagnostics();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? AppLocalizations.of(context)!.permissionsGranted
                : AppLocalizations.of(context)!.someDenied,
          ),
          backgroundColor: granted
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.tertiary,
        ),
      );
    }
  }
}
