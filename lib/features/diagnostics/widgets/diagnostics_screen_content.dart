import 'package:flutter/material.dart';
import 'package:med_assist/features/diagnostics/widgets/diagnostics_action_buttons.dart';
import 'package:med_assist/features/diagnostics/widgets/diagnostics_device_info_card.dart';
import 'package:med_assist/features/diagnostics/widgets/diagnostics_permission_card.dart';
import 'package:med_assist/features/diagnostics/widgets/diagnostics_section_header.dart';
import 'package:med_assist/features/diagnostics/widgets/diagnostics_stats_grid.dart';
import 'package:med_assist/features/diagnostics/widgets/diagnostics_troubleshooting.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class DiagnosticsScreenContent extends StatelessWidget {
  const DiagnosticsScreenContent({
    required this.loading,
    required this.diagnostics,
    required this.dbStats,
    required this.onSendTestNotification,
    required this.onScheduleTestNotification,
    required this.onRequestPermissions,
    super.key,
  });

  final bool loading;
  final Map<String, dynamic>? diagnostics;
  final Map<String, int>? dbStats;
  final Future<void> Function() onSendTestNotification;
  final Future<void> Function() onScheduleTestNotification;
  final Future<void> Function() onRequestPermissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiagnosticsSectionHeader(
              title: l10n.systemStatus,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(height: 12),
            DiagnosticsPermissionCard(
              title: l10n.notificationPermission,
              isGranted: diagnostics?['notification_permission'] == true,
              description: l10n.requiredForReminders,
              index: 0,
            ),
            const SizedBox(height: 12),
            DiagnosticsPermissionCard(
              title: l10n.exactAlarms,
              isGranted: diagnostics?['exact_alarms'] == true,
              description: l10n.requiredForPreciseTiming,
              index: 1,
            ),
            const SizedBox(height: 32),
            DiagnosticsSectionHeader(
              title: l10n.databaseStatistics,
              icon: Icons.storage_rounded,
            ),
            const SizedBox(height: 12),
            DiagnosticsStatsGrid(dbStats: dbStats),
            const SizedBox(height: 32),
            DiagnosticsSectionHeader(
              title: l10n.deviceInformation,
              icon: Icons.phone_android_rounded,
            ),
            const SizedBox(height: 12),
            DiagnosticsDeviceInfoCard(
              title: l10n.timezone,
              value: (diagnostics?['timezone'] as String?) ?? 'Unknown',
              icon: Icons.public_rounded,
              index: 2,
            ),
            const SizedBox(height: 12),
            DiagnosticsDeviceInfoCard(
              title: l10n.pluginVersion,
              value: (diagnostics?['plugin_version'] as String?) ?? 'N/A',
              icon: Icons.extension_rounded,
              index: 3,
            ),
            const SizedBox(height: 32),
            DiagnosticsSectionHeader(
              title: l10n.testingAndActions,
              icon: Icons.build_rounded,
            ),
            const SizedBox(height: 12),
            DiagnosticsActionButtons(
              onSendTestNotification: onSendTestNotification,
              onScheduleTestNotification: onScheduleTestNotification,
              onRequestPermissions: onRequestPermissions,
            ),
            const SizedBox(height: 32),
            const DiagnosticsTroubleshooting(),
          ],
        ),
      ),
    );
  }
}
