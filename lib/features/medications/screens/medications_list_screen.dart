import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/core/widgets/empty_state_widget.dart';
import 'package:med_assist/core/widgets/skeleton_loader.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/features/medications/widgets/medication_card.dart';
import 'package:med_assist/features/medications/widgets/medications_filter_chips.dart';
import 'package:med_assist/features/medications/widgets/medications_search_bar.dart';
import 'package:med_assist/features/medications/widgets/medication_selection_app_bar.dart';
import 'package:med_assist/features/medications/widgets/medication_selection_bottom_bar.dart';
import 'package:med_assist/features/medications/widgets/medication_selectable_card.dart';
import 'package:med_assist/features/medications/utils/medication_bulk_actions.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

/// Modern Medications List Screen (Refactored)
///
/// Clean architecture with extracted components:
/// - MedicationsSearchBar
/// - MedicationsFilterChips
/// - MedicationSelectionAppBar
/// - MedicationSelectionBottomBar
/// - MedicationSelectableCard
/// - MedicationBulkActions
class MedicationsListScreen extends ConsumerStatefulWidget {
  const MedicationsListScreen({super.key});

  @override
  ConsumerState<MedicationsListScreen> createState() =>
      _MedicationsListScreenState();
}

class _MedicationsListScreenState extends ConsumerState<MedicationsListScreen> {
  final _searchController = TextEditingController();
  bool _isSelectionMode = false;
  final Set<int> _selectedMedicationIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final medicationsAsync = ref.watch(filteredMedicationsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _isSelectionMode
          ? MedicationSelectionAppBar(
              selectedCount: _selectedMedicationIds.length,
              onClose: _exitSelectionMode,
              onSelectAll: _selectAll,
            )
          : null,
      body: Column(
        children: [
          MedicationsSearchBar(controller: _searchController),
          const MedicationsFilterChips(),
          Expanded(
            child: medicationsAsync.when(
              data: (medications) => _buildMedicationsList(medications, theme, colorScheme, l10n),
              loading: () => SkeletonLoader.list(context: context),
              error: (error, stack) => _buildErrorState(error, theme, colorScheme, l10n),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isSelectionMode
          ? MedicationSelectionBottomBar(
              hasSelection: _selectedMedicationIds.isNotEmpty,
              onDelete: _bulkDelete,
              onPause: _bulkPause,
              onResume: _bulkResume,
            )
          : null,
    );
  }

  Widget _buildMedicationsList(
    List<Medication> medications,
    ThemeData theme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    if (medications.isEmpty) {
      return _buildEmptyOrNoResults(l10n);
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(filteredMedicationsProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: medications.length,
        itemBuilder: (context, index) {
          final med = medications[index];
          final isSelected = _selectedMedicationIds.contains(med.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: (_isSelectionMode
                    ? MedicationSelectableCard(
                        medication: med,
                        isSelected: isSelected,
                        onToggle: () => _toggleSelection(med.id),
                      )
                    : MedicationCard(
                        medication: med,
                        onTap: () => context.push('/medication/${med.id}'),
                        onEdit: () => context.push('/medication/${med.id}/edit'),
                        onDelete: () => _deleteSingleMedication(med.id),
                        onToggleActive: () => _toggleActive(med),
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

  Widget _buildEmptyOrNoResults(AppLocalizations l10n) {
    final filter = ref.read(medicationFilterProvider);
    final hasFilters = filter.searchQuery != null && filter.searchQuery!.isNotEmpty ||
        filter.medicineType != null ||
        filter.isActive != null ||
        filter.showLowStock ||
        filter.showExpiring ||
        filter.showExpired;

    return EmptyStateWidget(
      icon: hasFilters ? Icons.search_off : Icons.medication_outlined,
      title: hasFilters ? l10n.noResultsFound : l10n.noMedicationsYet,
      subtitle: hasFilters ? l10n.tryAdjusting : l10n.startByAdding,
    );
  }

  Widget _buildErrorState(Object error, ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(l10n.errorMessage(error.toString()), style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(error.toString(), style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // Selection Actions

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMedicationIds.clear();
    });
  }

  void _selectAll() {
    final medications = ref.read(filteredMedicationsProvider).value;
    if (medications != null) {
      setState(() {
        _selectedMedicationIds.addAll(medications.map((m) => m.id));
      });
    }
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedMedicationIds.contains(id)) {
        _selectedMedicationIds.remove(id);
      } else {
        _selectedMedicationIds.add(id);
      }
    });
  }

  // Single Medication Actions

  Future<void> _deleteSingleMedication(int medicationId) async {
    final l10n = AppLocalizations.of(context)!;
    HapticService.warning();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedicationQuestion),
        content: Text(l10n.deleteMedicationConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        final repository = ref.read(medicationRepositoryProvider);
        await repository.deleteMedication(medicationId);
        if (context.mounted) {
          HapticService.success();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.medicationDeleted), backgroundColor: Colors.green));
        }
        ProviderRefreshUtils.refreshAllMedicationProviders(ref);
      } catch (e) {
        if (context.mounted) {
          HapticService.error();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorDeletingMedication(e.toString())), backgroundColor: Colors.red));
        }
      }
    }
  }

  Future<void> _toggleActive(Medication medication) async {
    final l10n = AppLocalizations.of(context)!;
    HapticService.medium();

    try {
      final database = ref.read(appDatabaseProvider);
      final updated = medication.copyWith(isActive: !medication.isActive);
      await database.updateMedication(updated);

      if (context.mounted) {
        HapticService.success();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(medication.isActive ? l10n.medicationPaused : l10n.medicationResumed)),
        );
      }

      ProviderRefreshUtils.refreshMedicationDetail(ref, medication.id);
    } catch (e) {
      if (context.mounted) {
        HapticService.error();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.errorMessage(e.toString())), backgroundColor: Colors.red));
      }
    }
  }

  // Bulk Actions

  Future<void> _bulkDelete() async {
    final medications = ref.read(filteredMedicationsProvider).value ?? [];
    final actions = MedicationBulkActions(
      context: context,
      ref: ref,
      selectedIds: _selectedMedicationIds,
      medications: medications,
      onComplete: _exitSelectionMode,
    );
    await actions.delete();
  }

  Future<void> _bulkPause() async {
    final medications = ref.read(filteredMedicationsProvider).value ?? [];
    final actions = MedicationBulkActions(
      context: context,
      ref: ref,
      selectedIds: _selectedMedicationIds,
      medications: medications,
      onComplete: _exitSelectionMode,
    );
    await actions.pause();
  }

  Future<void> _bulkResume() async {
    final medications = ref.read(filteredMedicationsProvider).value ?? [];
    final actions = MedicationBulkActions(
      context: context,
      ref: ref,
      selectedIds: _selectedMedicationIds,
      medications: medications,
      onComplete: _exitSelectionMode,
    );
    await actions.resume();
  }
}
