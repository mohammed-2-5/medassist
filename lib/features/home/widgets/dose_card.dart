import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/features/home/widgets/dose_card_components/dose_card_actions.dart';
import 'package:med_assist/features/home/widgets/dose_card_components/dose_card_header.dart';
import 'package:med_assist/features/home/widgets/dose_card_components/dose_card_info.dart';
import 'package:med_assist/features/home/widgets/dose_card_components/dose_card_styles.dart';

/// Dose Card Widget - Displays individual medication dose
class DoseCard extends ConsumerWidget {

  const DoseCard({
    required this.dose,
    super.key,
  });
  final DoseEvent dose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final styles = DoseCardStyles(colorScheme, dose.status);

    return Container(
      decoration: BoxDecoration(
        color: styles.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: styles.borderColor, width: 1.5),
        boxShadow: styles.hasShadow
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with medication info
                DoseCardHeader(
                  dose: dose,
                  iconColor: styles.iconColor,
                  iconBackgroundColor: styles.iconBackgroundColor,
                  textColor: styles.textColor,
                  timeBadgeColor: styles.timeBadgeColor,
                  timeBadgeTextColor: styles.timeBadgeTextColor,
                ),

                // Instructions
                if (dose.instructions != null) ...[
                  const SizedBox(height: 12),
                  DoseInstructions(instructions: dose.instructions!),
                ],

                // Low stock warning
                if (dose.stockRemaining != null && dose.stockRemaining! <= 3) ...[
                  const SizedBox(height: 12),
                  LowStockWarning(stockRemaining: dose.stockRemaining!),
                ],
              ],
            ),
          ),

          // Action buttons based on status
          _buildActions(ref),
        ],
      ),
    );
  }

  Widget _buildActions(WidgetRef ref) {
    final notifier = ref.read(todayDosesProvider.notifier);

    switch (dose.status) {
      case DoseStatus.pending:
        return PendingActions(
          onTake: () => notifier.markAsTaken(dose.id),
          onSnooze: () => notifier.snoozeDose(dose.id),
          onSkip: () => notifier.skipDose(dose.id),
        );

      case DoseStatus.taken:
        return TakenStatus(
          onUndo: () => notifier.undoDose(dose.id),
        );

      case DoseStatus.missed:
        return MissedStatus(
          onLogNow: () => notifier.logMissedDose(dose.id),
        );

      case DoseStatus.skipped:
        return SkippedStatus(
          onUndo: () => notifier.undoDose(dose.id),
        );

      case DoseStatus.snoozed:
        return SnoozedStatus(
          onTakeNow: () => notifier.markAsTaken(dose.id),
        );
    }
  }
}
