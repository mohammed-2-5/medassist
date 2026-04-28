import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/medications/providers/drug_interaction_providers.dart';
import 'package:med_assist/features/medications/widgets/interaction_warning_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Renders interaction warnings persisted against a medication (warnings the
/// user accepted when adding a conflicting med). Empty if none.
class MedicationPersistedInteractions extends ConsumerWidget {
  const MedicationPersistedInteractions({
    required this.medicationId,
    super.key,
  });

  final int medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(medicationInteractionsProvider(medicationId));
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return async.when(
      data: (warnings) {
        if (warnings.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.drugInteractions,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            for (final w in warnings) InteractionWarningCard(warning: w),
            const SizedBox(height: 16),
            Divider(color: theme.colorScheme.outlineVariant),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
