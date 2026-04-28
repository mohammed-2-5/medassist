import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/analytics/services/analytics_export_service.dart';
import 'package:med_assist/features/analytics/widgets/adherence_line_chart.dart';
import 'package:med_assist/features/analytics/widgets/analytics_adherence_card.dart';
import 'package:med_assist/features/analytics/widgets/analytics_best_time_card.dart';
import 'package:med_assist/features/analytics/widgets/analytics_export_helper.dart';
import 'package:med_assist/features/analytics/widgets/analytics_medication_insights.dart';
import 'package:med_assist/features/analytics/widgets/analytics_period_selector.dart';
import 'package:med_assist/features/analytics/widgets/analytics_reports_card.dart';
import 'package:med_assist/features/analytics/widgets/analytics_story_cards.dart';
import 'package:med_assist/features/analytics/widgets/calendar_heatmap.dart';
import 'package:med_assist/features/analytics/widgets/date_range_picker_dialog.dart'
    show CustomDateRangePickerDialog;
import 'package:med_assist/features/analytics/widgets/medication_bar_chart.dart';
import 'package:med_assist/features/analytics/widgets/status_pie_chart.dart';
import 'package:med_assist/features/analytics/widgets/time_of_day_heatmap.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Analytics Dashboard Screen
/// Shows comprehensive medication adherence statistics and insights
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState
    extends ConsumerState<AnalyticsDashboardScreen> {
  int _selectedPeriod = 1; // 0: Today, 1: Week, 2: Month, 3: Year, 4: Custom
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  final _exportService = AnalyticsExportService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push('/history'),
            tooltip: l10n.history,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
            tooltip: l10n.customDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
            tooltip: l10n.exportPdf,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayAdherenceProvider);
          ref.invalidate(weekAdherenceProvider);
          ref.invalidate(monthAdherenceProvider);
          ref.invalidate(yearAdherenceProvider);
          ref.invalidate(streakInfoProvider);
          ref.invalidate(medicationInsightsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnalyticsPeriodSelector(
                selectedPeriod: _selectedPeriod,
                onSelectionChanged: (value) {
                  setState(() {
                    _selectedPeriod = value;
                    if (_selectedPeriod != 4) {
                      _customStartDate = null;
                      _customEndDate = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 24),
              AnalyticsAdherenceCard(selectedPeriod: _selectedPeriod),
              const SizedBox(height: 16),
              const AnalyticsStoryCards(),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: _exportToPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(l10n.exportPdf),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AnalyticsReportsCard(
                onNavigateToReports: () => context.go('/reports'),
                onExportPdf: _exportToPdf,
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),
              Text(
                l10n.trendsInsights,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const AdherenceLineChart(),
              const SizedBox(height: 16),
              const MedicationBarChart(),
              const SizedBox(height: 16),
              const StatusPieChart(),
              const SizedBox(height: 16),
              const CalendarHeatmap(),
              const SizedBox(height: 16),
              TimeOfDayHeatmap(
                startDate: _customStartDate,
                endDate: _customEndDate,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.medicationInsights,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const AnalyticsMedicationInsights(),
              const SizedBox(height: 16),
              const AnalyticsBestTimeCard(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final range = await CustomDateRangePickerDialog.show(
      context,
      initialStartDate: _customStartDate,
      initialEndDate: _customEndDate,
    );
    if (range != null) {
      setState(() {
        _customStartDate = range.start;
        _customEndDate = range.end;
        _selectedPeriod = 4;
      });
    }
  }

  Future<void> _exportToPdf() => AnalyticsExportHelper.exportToPdf(
    context: context,
    ref: ref,
    selectedPeriod: _selectedPeriod,
    customStartDate: _customStartDate,
    customEndDate: _customEndDate,
    exportService: _exportService,
  );
}
