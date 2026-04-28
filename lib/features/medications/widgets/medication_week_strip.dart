import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/repetition_pattern_utils.dart';

/// 7-day strip showing which upcoming days the medication is scheduled.
///
/// Active dose-days get a filled primary pill; off-days are muted.
/// Today is ringed. Weekday initials derived from current locale.
class MedicationWeekStrip extends StatelessWidget {
  const MedicationWeekStrip({required this.medication, super.key});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final localeName = Localizations.localeOf(context).languageCode;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < days.length; i++)
            _DayPill(
              date: days[i],
              isDoseDay: _isDoseDay(days[i]),
              isToday: i == 0,
              label: DateFormat.E(localeName).format(days[i]),
              theme: theme,
              cs: cs,
            ),
        ],
      ),
    );
  }

  bool _isDoseDay(DateTime date) {
    return RepetitionPatternUtils.isDoseDay(
      pattern: medication.repetitionPattern,
      specificDaysOfWeek: medication.specificDaysOfWeek,
      startDate: medication.startDate,
      date: date,
      intervalDays: medication.intervalDays,
      intervalWeeks: medication.intervalWeeks,
      intervalMonths: medication.intervalMonths,
      dayOfMonth: medication.dayOfMonth,
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.date,
    required this.isDoseDay,
    required this.isToday,
    required this.label,
    required this.theme,
    required this.cs,
  });

  final DateTime date;
  final bool isDoseDay;
  final bool isToday;
  final String label;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final bg = isDoseDay
        ? cs.primary
        : cs.surfaceContainerHighest.withValues(alpha: 0.6);
    final fg = isDoseDay ? cs.onPrimary : cs.onSurfaceVariant;
    return Container(
      width: 40,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: cs.primary, width: 2)
            : Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            label.isNotEmpty ? label.substring(0, 1).toUpperCase() : '',
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${date.day}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
