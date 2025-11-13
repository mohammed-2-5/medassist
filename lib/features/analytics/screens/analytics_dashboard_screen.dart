import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/analytics/services/analytics_export_service.dart';
import 'package:med_assist/features/analytics/widgets/adherence_line_chart.dart';
import 'package:med_assist/features/analytics/widgets/calendar_heatmap.dart';
import 'package:med_assist/features/analytics/widgets/date_range_picker_dialog.dart' show CustomDateRangePickerDialog;
import 'package:med_assist/features/analytics/widgets/medication_bar_chart.dart';
import 'package:med_assist/features/analytics/widgets/status_pie_chart.dart';
import 'package:med_assist/features/analytics/widgets/time_of_day_heatmap.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';
import 'package:share_plus/share_plus.dart';

/// Analytics Dashboard Screen
/// Shows comprehensive medication adherence statistics and insights
class AnalyticsDashboardScreen extends ConsumerStatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  ConsumerState<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends ConsumerState<AnalyticsDashboardScreen> {
  int _selectedPeriod = 1; // 0: Today, 1: Week, 2: Month, 3: Year, 4: Custom
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  final _exportService = AnalyticsExportService();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analytics),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDateRangePicker,
            tooltip: 'Custom Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: _exportToPdf,
            tooltip: 'Export PDF',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _exportData,
            tooltip: l10n.exportData,
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Selector
              _buildPeriodSelector(colorScheme),
              const SizedBox(height: 24),

              // Main Adherence Card
              _buildAdherenceCard(colorScheme),
              const SizedBox(height: 16),

              // Streak Card
              _buildStreakCard(colorScheme),
              const SizedBox(height: 16),

              // Reports & Export Card
              _buildReportsCard(colorScheme)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),
              const SizedBox(height: 24),

              // Charts Section
              Text(
                l10n.trendsInsights,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Line Chart - Adherence Trend
              const AdherenceLineChart(),
              const SizedBox(height: 16),

              // Medication Bar Chart
              const MedicationBarChart(),
              const SizedBox(height: 16),

              // Status Pie Chart
              const StatusPieChart(),
              const SizedBox(height: 16),

              // Calendar Heatmap
              const CalendarHeatmap(),
              const SizedBox(height: 16),

              // Time-of-Day Heatmap (NEW)
              TimeOfDayHeatmap(
                startDate: _customStartDate,
                endDate: _customEndDate,
              ),
              const SizedBox(height: 24),

              // Medication Insights
              Text(
                l10n.medicationInsights,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildMedicationInsights(),
              const SizedBox(height: 16),

              // Best Time Card
              _buildBestTimeCard(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return SegmentedButton<int>(
      segments: [
        ButtonSegment(
          value: 0,
          label: Text(l10n.today),
          icon: const Icon(Icons.today),
        ),
        ButtonSegment(
          value: 1,
          label: Text(l10n.week),
          icon: const Icon(Icons.view_week),
        ),
        ButtonSegment(
          value: 2,
          label: Text(l10n.month),
          icon: const Icon(Icons.calendar_month),
        ),
        const ButtonSegment(
          value: 3,
          label: Text('Year'),
          icon: Icon(Icons.calendar_today),
        ),
      ],
      selected: {_selectedPeriod},
      onSelectionChanged: (Set<int> newSelection) {
        setState(() {
          _selectedPeriod = newSelection.first;
          // Reset custom date range when selecting predefined period
          if (_selectedPeriod != 4) {
            _customStartDate = null;
            _customEndDate = null;
          }
        });
      },
      // 👇 هنا التحكم بالألوان والتصميم
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimaryContainer; // 🔹 الخلفية عند الاختيار
          }
          return colorScheme.surfaceContainerHighest; // 🔸 الخلفية الافتراضية
        }),
        foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // 🔹 لون النص والأيقونة عند الاختيار
          }
          return colorScheme.onSurfaceVariant; // 🔸 لون النص الافتراضي
        }),
        iconColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white; // 🔹 لون الأيقونة عند الاختيار
          }
          return colorScheme.primary; // 🔸 لون الأيقونة الافتراضي
        }),
        side: WidgetStateProperty.resolveWith<BorderSide>((states) {
          if (states.contains(WidgetState.selected)) {
            return BorderSide(color: colorScheme.primary, width: 2);
          }
          return BorderSide(color: colorScheme.outlineVariant);
        }),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildAdherenceCard(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    final provider = _selectedPeriod == 0
        ? todayAdherenceProvider
        : _selectedPeriod == 1
            ? weekAdherenceProvider
            : _selectedPeriod == 2
                ? monthAdherenceProvider
                : yearAdherenceProvider;

    return ref.watch(provider).when(
          data: (stats) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.adherenceRate,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getAdherenceColor(stats.adherencePercentage, colorScheme)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stats.adherencePercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _getAdherenceColor(stats.adherencePercentage, colorScheme),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: stats.adherencePercentage / 100,
                      minHeight: 12,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation(
                        _getAdherenceColor(stats.adherencePercentage, colorScheme),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Stats Grid
                  Row(
                    children: [
                      Expanded(
                        child: _StatItem(
                          label: l10n.taken,
                          value: stats.takenDoses.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: l10n.missed,
                          value: stats.missedDoses.toString(),
                          icon: Icons.cancel,
                          color: Colors.red,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: l10n.skipped,
                          value: stats.skippedDoses.toString(),
                          icon: Icons.remove_circle,
                          color: Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _StatItem(
                          label: l10n.total,
                          value: stats.totalDoses.toString(),
                          icon: Icons.medication,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('${l10n.errorLoadingStats}: $err'),
            ),
          ),
        );
  }

  Widget _buildStreakCard(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return ref.watch(streakInfoProvider).when(
          data: (streak) => Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.orange,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.currentStreak,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.daysCount(streak.currentStreak),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 60,
                    width: 1,
                    color: colorScheme.onPrimaryContainer.withOpacity(0.3),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 28,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                l10n.bestStreak,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.daysCount(streak.bestStreak),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('${l10n.errorLoadingStreak}: $err'),
            ),
          ),
        );
  }

  Widget _buildMedicationInsights() {
    final l10n = AppLocalizations.of(context)!;
    return ref.watch(medicationInsightsProvider).when(
          data: (insights) {
            if (insights.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      l10n.noMedicationDataYet,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: insights.take(5).map((insight) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getAdherenceColor(
                        insight.adherenceRate,
                        Theme.of(context).colorScheme,
                      ).withOpacity(0.2),
                      child: Text(
                        '${insight.adherenceRate.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getAdherenceColor(
                            insight.adherenceRate,
                            Theme.of(context).colorScheme,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      insight.medicationName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      l10n.dosesTakenOf(insight.takenDoses, insight.totalDoses),
                    ),
                    trailing: Icon(
                      insight.adherenceRate >= 80
                          ? Icons.check_circle
                          : insight.adherenceRate >= 50
                              ? Icons.warning
                              : Icons.error,
                      color: _getAdherenceColor(
                        insight.adherenceRate,
                        Theme.of(context).colorScheme,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('${l10n.errorLoadingInsights}: $err'),
            ),
          ),
        );
  }

  Widget _buildBestTimeCard(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<String>(
      future: ref.read(analyticsProvider).getBestTimeOfDay(),
      builder: (context, snapshot) {
        final bestTime = snapshot.data ?? l10n.loading;

        return Card(
          child: ListTile(
            leading: Icon(
              Icons.access_time,
              color: colorScheme.primary,
              size: 32,
            ),
            title: Text(
              l10n.bestTimeForAdherence,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              bestTime,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Icon(
              Icons.info_outline,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportsCard(ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          HapticService.light();
          context.go('/reports');
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colorScheme.secondaryContainer,
                colorScheme.tertiaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.file_download_outlined,
                      size: 32,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.reportsExport,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSecondaryContainer,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.exportYourDataDescription,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer
                                    .withOpacity(0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: colorScheme.onSecondaryContainer,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildQuickExportChip(
                    l10n.medicationsCsv,
                    Icons.medication,
                    colorScheme,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickExportChip(
                    l10n.adherencePDF,
                    Icons.analytics,
                    colorScheme,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickExportChip(
    String label,
    IconData icon,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAdherenceColor(double percentage, ColorScheme colorScheme) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
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
        _selectedPeriod = 4; // Custom period
      });
    }
  }

  Future<void> _exportToPdf() async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 16),
              Text('Generating PDF report...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      // Gather data
      final provider = _selectedPeriod == 0
          ? todayAdherenceProvider
          : _selectedPeriod == 1
              ? weekAdherenceProvider
              : _selectedPeriod == 2
                  ? monthAdherenceProvider
                  : yearAdherenceProvider;

      final stats = await ref.read(provider.future);
      final medications = await ref.read(medicationInsightsProvider.future);
      final streak = await ref.read(streakInfoProvider.future);
      final trendData = await ref.read(analyticsProvider).getAdherenceTrend(30);

      final now = DateTime.now();
      final startDate = _customStartDate ?? now.subtract(const Duration(days: 30));
      final endDate = _customEndDate ?? now;
      final hourlyData = await ref.read(analyticsProvider).getHourlyAdherenceData(startDate, endDate);

      // Generate PDF
      final pdfFile = await _exportService.exportToPdf(
        stats: stats,
        medications: medications,
        streak: streak,
        trendData: trendData,
        hourlyData: hourlyData,
        startDate: startDate,
        endDate: endDate,
      );

      // Share PDF
      await _exportService.sharePdfReport(pdfFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF report generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportData() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final csvData = await ref.read(analyticsProvider).exportAdherenceCSV(
            thirtyDaysAgo,
            now,
          );

      final fileName = 'medication_adherence_${DateFormat('yyyy-MM-dd').format(now)}.csv';

      await Share.share(
        csvData,
        subject: l10n.medicationAdherenceReport,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.dataExportedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
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

/// Stat Item Widget
class _StatItem extends StatelessWidget {

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
