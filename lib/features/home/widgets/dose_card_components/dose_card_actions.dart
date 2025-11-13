import 'package:flutter/material.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

/// Pending status actions
class PendingActions extends StatelessWidget {

  const PendingActions({
    required this.onTake,
    required this.onSnooze,
    required this.onSkip,
    super.key,
  });
  final VoidCallback onTake;
  final VoidCallback onSnooze;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () {
                HapticService.success();
                onTake();
              },
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Take'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticService.light();
                onSnooze();
              },
              icon: const Icon(Icons.snooze, size: 18),
              label: const Text('Snooze'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              HapticService.medium();
              onSkip();
            },
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Skip',
            style: IconButton.styleFrom(
              side: BorderSide(color: colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

/// Taken status display
class TakenStatus extends StatelessWidget {

  const TakenStatus({
    required this.onUndo,
    super.key,
  });
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: colorScheme.secondary.withOpacity(0.3)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: colorScheme.secondary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Taken successfully',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticService.light();
              onUndo();
            },
            child: const Text('Undo'),
          ),
        ],
      ),
    );
  }
}

/// Missed status display
class MissedStatus extends StatelessWidget {

  const MissedStatus({
    required this.onLogNow,
    super.key,
  });
  final VoidCallback onLogNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withOpacity(0.5),
          ),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Missed dose',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: () {
              HapticService.medium();
              onLogNow();
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Log Now'),
          ),
        ],
      ),
    );
  }
}

/// Skipped status display
class SkippedStatus extends StatelessWidget {

  const SkippedStatus({
    required this.onUndo,
    super.key,
  });
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.5)),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.do_not_disturb_on_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Skipped',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticService.light();
              onUndo();
            },
            child: const Text('Undo'),
          ),
        ],
      ),
    );
  }
}

/// Snoozed status display
class SnoozedStatus extends StatelessWidget {

  const SnoozedStatus({
    required this.onTakeNow,
    super.key,
  });
  final VoidCallback onTakeNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        border: Border(top: BorderSide(color: Colors.amber.shade200)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.snooze, color: Colors.amber.shade700, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Snoozed for 15 minutes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticService.success();
              onTakeNow();
            },
            child: const Text('Take Now'),
          ),
        ],
      ),
    );
  }
}
