import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/widgets/empty_state_widget.dart';
import 'package:med_assist/core/widgets/skeleton_loader.dart';
import 'package:med_assist/features/history/providers/history_providers.dart';
import 'package:med_assist/features/history/widgets/dose_history_card.dart';
import 'package:med_assist/features/history/widgets/monthly_stats_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';
import 'package:table_calendar/table_calendar.dart';

/// History & Calendar Screen - Shows medication history with calendar view
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedDate = ref.watch(selectedDateProvider);
    final doseHistoryAsync = ref.watch(doseHistoryForDateProvider(selectedDate));
    final monthlyStatsAsync = ref.watch(monthlyAdherenceProvider(_focusedDay));
    final datesWithDosesAsync = ref.watch(datesWithDosesProvider(_focusedDay));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.medicationHistory),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: l10n.goToToday,
            onPressed: () {
              HapticService.light();
              setState(() {
                _focusedDay = DateTime.now();
              });
              ref.read(selectedDateProvider.notifier).setDate(DateTime.now());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(doseHistoryForDateProvider);
          ref.invalidate(monthlyAdherenceProvider);
          ref.invalidate(datesWithDosesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Monthly stats card
            monthlyStatsAsync.when(
              data: (stats) => MonthlyStatsCard(
                stats: stats,
                month: DateFormat('MMMM yyyy').format(_focusedDay),
              ),
              loading: () => SkeletonLoader.statsCard(context: context),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 16),

            // Calendar
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: datesWithDosesAsync.when(
                  data: (datesWithDoses) => TableCalendar(
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      HapticService.selection();
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                      ref.read(selectedDateProvider.notifier).setDate(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      markerDecoration: BoxDecoration(
                        color: colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      markersMaxCount: 1,
                    ),
                    headerStyle: HeaderStyle(
                      titleCentered: true,
                      titleTextStyle: theme.textTheme.titleLarge!,
                    ),
                    eventLoader: (day) {
                      // Show marker if day has doses
                      final dayOnly = DateTime(day.year, day.month, day.day);
                      return datesWithDoses.contains(dayOnly) ? [day] : [];
                    },
                  ),
                  loading: () => TableCalendar(
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      HapticService.selection();
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                      ref.read(selectedDateProvider.notifier).setDate(selectedDay);
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                  error: (_, __) => TableCalendar(
                    firstDay: DateTime.utc(2020),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(selectedDate, day),
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      HapticService.selection();
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                      ref.read(selectedDateProvider.notifier).setDate(selectedDay);
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Selected date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                _formatSelectedDate(selectedDate, l10n),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Dose history for selected date
            doseHistoryAsync.when(
              data: (history) {
                if (history.isEmpty) {
                  return _buildEmptyState(theme, colorScheme, l10n);
                }

                return Column(
                  children: history.map((dose) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DoseHistoryCard(dose: dose),
                    );
                  }).toList(),
                );
              },
              loading: () => Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: SkeletonLoader.list(context: context, itemCount: 3),
              ),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                      const SizedBox(height: 16),
                      Text('${l10n.errorLoadingHistory}: $error'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: EmptyStateWidget(
        icon: Icons.history,
        title: l10n.noMedicationHistory,
        subtitle: l10n.noDosesScheduledForDate,
      ),
    );
  }

  String _formatSelectedDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '${l10n.today} - ${DateFormat('MMMM d, yyyy').format(date)}';
    } else if (dateOnly == yesterday) {
      return '${l10n.yesterday} - ${DateFormat('MMMM d, yyyy').format(date)}';
    } else {
      return DateFormat('EEEE, MMMM d, yyyy').format(date);
    }
  }
}
