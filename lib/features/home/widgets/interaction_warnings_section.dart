import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/medications/providers/drug_interaction_providers.dart';
import 'package:med_assist/features/medications/widgets/interaction_warning_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

/// Shows a summary card for drug interaction warnings on the Home screen.
/// Tapping opens a full list dialog.
class InteractionWarningsSection extends ConsumerWidget {
  const InteractionWarningsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionsAsync = ref.watch(allInteractionsProvider);

    return interactionsAsync.when(
      data: (warnings) {
        if (warnings.isEmpty) return const SizedBox.shrink();
        final mostSevere = warnings.first;
        final l10n = AppLocalizations.of(context)!;
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Card(
            elevation: 4,
            color: colorScheme.errorContainer,
            child: InkWell(
              onTap: () => _showAllInteractionsDialog(context, warnings),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.error,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.warning,
                        color: colorScheme.onError,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            warnings.length == 1
                                ? l10n.drugInteractionDetected
                                : l10n.drugInteractionsDetected(warnings.length),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${mostSevere.medication1} + ${mostSevere.medication2}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.tapToViewDetails,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: colorScheme.onErrorContainer,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  void _showAllInteractionsDialog(
    BuildContext context,
    List<InteractionWarning> warnings,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: colorScheme.error),
            const SizedBox(width: 8),
            Text(l10n.drugInteractions),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: warnings.length,
            itemBuilder: (context, index) => InteractionWarningCard(
              warning: warnings[index],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/medications');
            },
            child: Text(l10n.viewMedications),
          ),
        ],
      ),
    );
  }
}
