import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/widgets/empty_state_widget.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/features/medications/utils/medication_actions.dart';
import 'package:med_assist/features/medications/widgets/medication_card.dart';
import 'package:med_assist/features/medications/widgets/medication_selectable_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Scrollable list of medications with selection mode support.
class MedicationsList extends ConsumerWidget {
  const MedicationsList({
    required this.medications,
    required this.isSelectionMode,
    required this.selectedIds,
    required this.onToggleSelection,
    super.key,
  });

  final List<Medication> medications;
  final bool isSelectionMode;
  final Set<int> selectedIds;
  final void Function(int id) onToggleSelection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (medications.isEmpty) {
      return _buildEmpty(context, ref);
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(filteredMedicationsProvider),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final med = medications[index];
          final isSelected = selectedIds.contains(med.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child:
                (isSelectionMode
                        ? MedicationSelectableCard(
                            medication: med,
                            isSelected: isSelected,
                            onToggle: () => onToggleSelection(med.id),
                          )
                        : MedicationCard(
                            medication: med,
                            onTap: () => context.push('/medication/${med.id}'),
                            onEdit: () =>
                                context.push('/medication/${med.id}/edit'),
                            onDelete: () => MedicationActions.delete(
                              context: context,
                              ref: ref,
                              medicationId: med.id,
                            ),
                            onToggleActive: () =>
                                MedicationActions.toggleActive(
                                  context: context,
                                  ref: ref,
                                  medication: med,
                                ),
                          ))
                    .animate()
                    .fadeIn(
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 50 * index),
                    )
                    .slideY(
                      begin: 0.2,
                      end: 0,
                      duration: const Duration(milliseconds: 400),
                      delay: Duration(milliseconds: 50 * index),
                      curve: Curves.easeOutCubic,
                    ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.read(medicationFilterProvider);
    final hasFilters =
        (filter.searchQuery?.isNotEmpty ?? false) ||
        filter.medicineType != null ||
        filter.isActive != null ||
        filter.showLowStock ||
        filter.showExpiring ||
        filter.showExpired;

    return EmptyStateWidget(
      icon: hasFilters ? Icons.search_off : Icons.medication_outlined,
      title: hasFilters ? l10n.noResultsFound : l10n.noMedicationsYet,
      subtitle: hasFilters ? l10n.tryAdjusting : l10n.startByAdding,
      actionLabel: hasFilters ? null : l10n.addMedicine,
      onAction: hasFilters ? null : () => context.push('/add-reminder'),
    );
  }
}
