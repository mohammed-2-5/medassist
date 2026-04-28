import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/smart_schedule/smart_schedule_daily_config.dart';
import 'package:med_assist/features/add_medication/widgets/smart_schedule/smart_schedule_mode.dart';
import 'package:med_assist/features/add_medication/widgets/smart_schedule/smart_schedule_monthly_config.dart';
import 'package:med_assist/features/add_medication/widgets/smart_schedule/smart_schedule_times_per_day.dart';
import 'package:med_assist/features/add_medication/widgets/smart_schedule/smart_schedule_weekly_config.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Unified smart schedule selector — merges times-per-day and repetition
/// pattern into a single segmented UI (Daily / Weekly / Monthly / As Needed).
class SmartScheduleSelector extends ConsumerWidget {
  const SmartScheduleSelector({required this.formData, super.key});

  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final mode = SmartScheduleMode.fromPattern(formData.repetitionPattern);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scheduleSectionTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.scheduleSectionDesc,
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        _ModeSegments(mode: mode, formData: formData),
        const SizedBox(height: 16),
        _ModeConfig(mode: mode, formData: formData),
        if (mode != SmartScheduleMode.asNeeded) ...[
          const SizedBox(height: 20),
          Divider(color: cs.outlineVariant.withValues(alpha: 0.3), height: 1),
          const SizedBox(height: 16),
          SmartScheduleTimesPerDay(timesPerDay: formData.timesPerDay),
        ],
      ],
    );
  }
}

class _ModeSegments extends ConsumerWidget {
  const _ModeSegments({required this.mode, required this.formData});
  final SmartScheduleMode mode;
  final MedicationFormData formData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    return SegmentedButton<SmartScheduleMode>(
      segments: [
        ButtonSegment(
          value: SmartScheduleMode.daily,
          label: _buildSegmentLabel(l10n.modeDaily, labelStyle),
          icon: const Icon(Icons.today, size: 14),
        ),
        ButtonSegment(
          value: SmartScheduleMode.weekly,
          label: _buildSegmentLabel(l10n.modeWeekly, labelStyle),
          icon: const Icon(Icons.view_week, size: 14),
        ),
        ButtonSegment(
          value: SmartScheduleMode.monthly,
          label: _buildSegmentLabel(l10n.modeMonthly, labelStyle),
          icon: const Icon(Icons.calendar_month, size: 14),
        ),
        ButtonSegment(
          value: SmartScheduleMode.asNeeded,
          label: _buildSegmentLabel(l10n.modeAsNeeded, labelStyle),
          icon: const Icon(Icons.healing, size: 14),
        ),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (sel) => _applyMode(ref, sel.first, formData),
    );
  }

  Widget _buildSegmentLabel(String label, TextStyle? style) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        style: style,
        maxLines: 1,
        softWrap: false,
      ),
    );
  }

  void _applyMode(
    WidgetRef ref,
    SmartScheduleMode newMode,
    MedicationFormData formData,
  ) {
    final notifier = ref.read(medicationFormProvider.notifier);
    switch (newMode) {
      case SmartScheduleMode.daily:
        notifier.applySmartSchedule(pattern: RepetitionPattern.daily);
      case SmartScheduleMode.weekly:
        final days = formData.specificDaysOfWeek.isEmpty
            ? [DateTime.now().weekday]
            : formData.specificDaysOfWeek;
        notifier.applySmartSchedule(
          pattern: RepetitionPattern.weekly,
          specificDaysOfWeek: days,
          intervalWeeks: 1,
        );
      case SmartScheduleMode.monthly:
        notifier.applySmartSchedule(
          pattern: RepetitionPattern.monthly,
          dayOfMonth: formData.startDate?.day ?? DateTime.now().day,
          intervalMonths: 1,
        );
      case SmartScheduleMode.asNeeded:
        notifier.applySmartSchedule(pattern: RepetitionPattern.asNeeded);
    }
  }
}

class _ModeConfig extends StatelessWidget {
  const _ModeConfig({required this.mode, required this.formData});
  final SmartScheduleMode mode;
  final MedicationFormData formData;

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case SmartScheduleMode.daily:
        return SmartScheduleDailyConfig(formData: formData);
      case SmartScheduleMode.weekly:
        return SmartScheduleWeeklyConfig(formData: formData);
      case SmartScheduleMode.monthly:
        return SmartScheduleMonthlyConfig(formData: formData);
      case SmartScheduleMode.asNeeded:
        return _AsNeededInfo();
    }
  }
}

class _AsNeededInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: cs.onSecondaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.asNeededInfo,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
