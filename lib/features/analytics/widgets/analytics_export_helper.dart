import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/analytics/screens/analytics_dashboard_screen.dart' show AnalyticsDashboardScreen;
import 'package:med_assist/features/analytics/services/analytics_export_service.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

/// Stateless helpers for the analytics export actions.
///
/// Extracted to keep [AnalyticsDashboardScreen] under 250 lines.
/// All methods require a [BuildContext] (for snackbars) and a [WidgetRef]
/// (to read providers) — these are passed in rather than captured, so the
/// screen state remains the single source of truth.
abstract final class AnalyticsExportHelper {
  static Future<void> exportToPdf({
    required BuildContext context,
    required WidgetRef ref,
    required int selectedPeriod,
    required DateTime? customStartDate,
    required DateTime? customEndDate,
    required AnalyticsExportService exportService,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text(l10n.generatingPdfReport),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      final provider = selectedPeriod == 0
          ? todayAdherenceProvider
          : selectedPeriod == 1
              ? weekAdherenceProvider
              : selectedPeriod == 2
                  ? monthAdherenceProvider
                  : yearAdherenceProvider;

      final stats = await ref.read(provider.future);
      final medications = await ref.read(medicationInsightsProvider.future);
      final streak = await ref.read(streakInfoProvider.future);
      final trendData = await ref.read(analyticsProvider).getAdherenceTrend(30);

      final now = DateTime.now();
      final startDate =
          customStartDate ?? now.subtract(const Duration(days: 30));
      final endDate = customEndDate ?? now;
      final hourlyData = await ref
          .read(analyticsProvider)
          .getHourlyAdherenceData(startDate, endDate);

      final pdfFile = await exportService.exportToPdf(
        stats: stats,
        medications: medications,
        streak: streak,
        trendData: trendData,
        hourlyData: hourlyData,
        startDate: startDate,
        endDate: endDate,
      );

      await exportService.sharePdfReport(pdfFile);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pdfReportGenerated),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorGeneratingPdf(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<void> exportData({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final csvData = await ref.read(analyticsProvider).exportAdherenceCSV(
            thirtyDaysAgo,
            now,
          );

      // fileName kept for future use (e.g. XFile-based sharing).
      // ignore: unused_local_variable
      final fileName =
          'medication_adherence_${DateFormat('yyyy-MM-dd').format(now)}.csv';

      await Share.share(
        csvData,
        subject: l10n.medicationAdherenceReport,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dataExportedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.errorExportingData}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
