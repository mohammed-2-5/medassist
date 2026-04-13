import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/widgets/skeleton_loader.dart';
import 'package:med_assist/features/medications/providers/medication_selection_provider.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/features/medications/widgets/medications_bulk_action_bar.dart';
import 'package:med_assist/features/medications/widgets/medications_error_state.dart';
import 'package:med_assist/features/medications/widgets/medications_filter_chips.dart';
import 'package:med_assist/features/medications/widgets/medications_list.dart';
import 'package:med_assist/features/medications/widgets/medications_search_bar.dart';
import 'package:med_assist/features/medications/widgets/medications_selection_app_bar.dart';

/// Modern Medications List Screen
class MedicationsListScreen extends ConsumerStatefulWidget {
  const MedicationsListScreen({super.key});

  @override
  ConsumerState<MedicationsListScreen> createState() =>
      _MedicationsListScreenState();
}

class _MedicationsListScreenState
    extends ConsumerState<MedicationsListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = ref.watch(medicationSelectionProvider);
    final medicationsAsync = ref.watch(filteredMedicationsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: selection.isSelectionMode
          ? MedicationsSelectionAppBar(
              selectedCount: selection.selectedIds.length,
              onClose: () =>
                  ref.read(medicationSelectionProvider.notifier).exit(),
              onSelectAll: () {
                final ids = medicationsAsync.value?.map((m) => m.id).toList()
                    ?? [];
                ref
                    .read(medicationSelectionProvider.notifier)
                    .selectAll(ids);
              },
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            MedicationsSearchBar(controller: _searchController),
            const MedicationsFilterChips(),
            Expanded(
              child: medicationsAsync.when(
                data: (medications) => MedicationsList(
                  medications: medications,
                  isSelectionMode: selection.isSelectionMode,
                  selectedIds: selection.selectedIds,
                  onToggleSelection: (id) => ref
                      .read(medicationSelectionProvider.notifier)
                      .toggle(id),
                ),
                loading: () => SkeletonLoader.list(context: context),
                error: (error, _) => MedicationsErrorState(error: error),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: selection.isSelectionMode
          ? MedicationsBulkActionBar(
              selectedIds: selection.selectedIds,
              onExit: () =>
                  ref.read(medicationSelectionProvider.notifier).exit(),
            )
          : null,
    );
  }
}
