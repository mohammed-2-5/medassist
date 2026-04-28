import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Times-per-day chip selector with soft warning for high frequency.
class SmartScheduleTimesPerDay extends ConsumerStatefulWidget {
  const SmartScheduleTimesPerDay({required this.timesPerDay, super.key});

  final int timesPerDay;

  @override
  ConsumerState<SmartScheduleTimesPerDay> createState() =>
      _SmartScheduleTimesPerDayState();
}

class _SmartScheduleTimesPerDayState
    extends ConsumerState<SmartScheduleTimesPerDay> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final selected = widget.timesPerDay;
    final showExtra = _expanded || selected >= 5;
    final count = showExtra ? 6 : 4;
    final isHigh = selected >= 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.howManyTimesPerDay,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...List.generate(count, (index) {
              final times = index + 1;
              final isSelected = selected == times;
              return _TimesChip(
                times: times,
                isSelected: isSelected,
                onTap: () => ref
                    .read(medicationFormProvider.notifier)
                    .setTimesPerDay(times),
              );
            }),
            if (!showExtra)
              TextButton.icon(
                onPressed: () => setState(() => _expanded = true),
                icon: const Icon(Icons.expand_more, size: 18),
                label: Text(l10n.showMore),
              )
            else if (selected < 5)
              TextButton.icon(
                onPressed: () => setState(() => _expanded = false),
                icon: const Icon(Icons.expand_less, size: 18),
                label: Text(l10n.showLess),
              ),
          ],
        ),
        if (isHigh) ...[
          const SizedBox(height: 10),
          _HighFreqWarning(message: l10n.highFrequencyWarning),
        ],
      ],
    );
  }
}

class _TimesChip extends StatelessWidget {
  const _TimesChip({
    required this.times,
    required this.isSelected,
    required this.onTap,
  });

  final int times;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          '$times',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isSelected ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _HighFreqWarning extends StatelessWidget {
  const _HighFreqWarning({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
