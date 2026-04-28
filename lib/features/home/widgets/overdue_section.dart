import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/features/home/widgets/dose_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Pinned section showing overdue (missed/snoozed) doses above the timeline.
///
/// Renders nothing when there are no overdue doses.
class OverdueSection extends ConsumerWidget {
  const OverdueSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overdue = ref.watch(overdueDosesProvider);
    if (overdue.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.errorContainer.withOpacity(0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.error.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.overdue.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: cs.error,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${overdue.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: cs.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...overdue.map(
              (d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: DoseCard(dose: d),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
