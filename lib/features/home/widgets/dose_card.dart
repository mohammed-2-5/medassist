import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/models/dose_result.dart';
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

    final card = Container(
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
          // Main content — tappable to view medication details
          InkWell(
            onTap: () => context.push('/medication/${dose.medicationId}'),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
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
          ),

          // Action buttons based on status
          _buildActions(context, ref),
        ],
      ),
    );

    // Swipe gestures only for pending doses
    if (dose.status != DoseStatus.pending) return card;

    final notifier = ref.read(todayDosesProvider.notifier);
    return Dismissible(
      key: ValueKey(dose.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          final result = await notifier.markAsTaken(dose.id);
          if (context.mounted && result is DoseOperationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: colorScheme.error,
              ),
            );
            return false;
          }
          return false; // Don't remove from list; state update handles UI
        } else {
          final result = await notifier.skipDose(dose.id);
          if (context.mounted && result is DoseOperationFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: colorScheme.error,
              ),
            );
          }
          return false;
        }
      },
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: colorScheme.secondary,
        icon: Icons.check_circle_outline,
        label: 'Take',
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: colorScheme.errorContainer,
        icon: Icons.close,
        label: 'Skip',
        iconColor: colorScheme.onErrorContainer,
        labelColor: colorScheme.onErrorContainer,
      ),
      child: card,
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(todayDosesProvider.notifier);

    switch (dose.status) {
      case DoseStatus.pending:
        return PendingActions(
          onTake: () async {
            final result = await notifier.markAsTaken(dose.id);
            if (context.mounted && result is DoseOperationFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
          onSnooze: () => notifier.snoozeDose(dose.id),
          onSkip: () async {
            final result = await notifier.skipDose(dose.id);
            if (context.mounted && result is DoseOperationFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        );

      case DoseStatus.taken:
        return TakenStatus(
          onUndo: () => notifier.undoDose(dose.id),
        );

      case DoseStatus.missed:
        return MissedStatus(
          onLogNow: () async {
            final result = await notifier.logMissedDose(dose.id);
            if (context.mounted && result is DoseOperationFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        );

      case DoseStatus.skipped:
        return SkippedStatus(
          onUndo: () => notifier.undoDose(dose.id),
        );

      case DoseStatus.snoozed:
        return SnoozedStatus(
          onTakeNow: () async {
            final result = await notifier.markAsTaken(dose.id);
            if (context.mounted && result is DoseOperationFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result.message),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            }
          },
        );
    }
  }
}

/// Background shown behind the card during a swipe gesture.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
    required this.label,
    this.iconColor,
    this.labelColor,
  });

  final Alignment alignment;
  final Color color;
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Colors.white;
    final effectiveLabelColor = labelColor ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: effectiveIconColor, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: effectiveLabelColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
