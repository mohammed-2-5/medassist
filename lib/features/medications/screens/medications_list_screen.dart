import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/core/widgets/empty_state_widget.dart';
import 'package:med_assist/core/widgets/enhanced_search_bar.dart';
import 'package:med_assist/core/widgets/skeleton_loader.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/features/medications/widgets/medication_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

/// Modern Medications List Screen with filters and search
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
    final medicineTypes = ref.watch(medicineTypesProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(theme, colorScheme, l10n),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(theme, colorScheme, l10n),

          // Filter chips
          _buildFilterChips(theme, colorScheme, medicineTypes, l10n),

          // Medications list
          Expanded(
            child: medicationsAsync.when(
              data: (medications) {
                if (medications.isEmpty) {
                  // Check if filters are active
                  final filter = ref.read(medicationFilterProvider);
                  final hasSearchFilter = filter.searchQuery != null && filter.searchQuery!.isNotEmpty;
                  final hasTypeFilter = filter.medicineType != null;
                  final hasStatusFilter = filter.isActive != null;
                  final hasFilters = hasSearchFilter ||
                      hasTypeFilter ||
                      hasStatusFilter ||
                      filter.showLowStock ||
                      filter.showExpiring ||
                      filter.showExpired;

                  if (hasFilters) {
                    return _buildNoResultsState(theme, colorScheme, l10n);
                  }
                  return _buildEmptyState(theme, colorScheme, l10n);
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
                        child: _isSelectionMode
                            ? _buildSelectableCard(med, isSelected, theme, colorScheme)
                            : MedicationCard(
                                medication: med,
                                onTap: () => _navigateToDetail(med.id),
                                onEdit: () => _editMedication(med.id),
                                onDelete: () => _deleteMedication(med.id),
                                onToggleActive: () => _toggleActive(med),
                              ),
                      );
                    },
                  ),
                );
              },
              loading: () => SkeletonLoader.list(context: context),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.errorMessage(error.toString()),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton.extended(
        onPressed: () => context.push('/add-medication'),
        icon: const Icon(Icons.add),
        label: Text(l10n.addMedicine),
      ),
      bottomNavigationBar: _isSelectionMode ? _buildSelectionBar(theme, colorScheme, l10n) : null,
    );
  }

  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    if (_isSelectionMode) {
      return AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _isSelectionMode = false;
              _selectedMedicationIds.clear();
            });
          },
        ),
        title: Text('${_selectedMedicationIds.length} ${l10n.selected ?? 'selected'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            tooltip: l10n.selectAll ?? 'Select all',
            onPressed: _selectAll,
          ),
        ],
      );
    }

    return AppBar(
      title: Text(l10n.myMedications),
      actions: [
        IconButton(
          icon: const Icon(Icons.checklist),
          tooltip: l10n.selectMedications ?? 'Select medications',
          onPressed: () {
            setState(() {
              _isSelectionMode = true;
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.sort),
          tooltip: l10n.sortBy,
          onPressed: () => _showSortOptions(l10n),
        ),
      ],
    );
  }

  Widget _buildSearchBar(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    const lightBlueBg = Color(0xFFE3F2FD);   // خلفية فاتحة
    const lightBlueBorder = Color(0xFFB3C7DB); // إطار أزرق رمادي لطيف
    final focusedBorderColor = colorScheme.primary; // لون الإطار عند التركيز

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: lightBlueBg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: lightBlueBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: lightBlueBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: focusedBorderColor, width: 2),
            ),
            // لو عايز لون أيقونة البحث/التلميح أغمق شوية:
            prefixIconColor: colorScheme.onSurface.withOpacity(0.75),
            hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
        ),
        child: EnhancedSearchBar(
          hintText: l10n.searchMedications,
          controller: _searchController,
          onChanged: (value) {
            ref.read(medicationFilterProvider.notifier).updateSearchQuery(value.toLowerCase());
          },
          onClear: () {
            ref.read(medicationFilterProvider.notifier).updateSearchQuery('');
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, ColorScheme colorScheme, AsyncValue<List<String>> medicineTypesAsync, AppLocalizations l10n) {
    final filter = ref.watch(medicationFilterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Status filters
          _buildFilterChip(
            label: l10n.active,
            selected: filter.isActive ?? false,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateIsActive(selected ? true : null);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.paused,
            selected: filter.isActive == false,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateIsActive(selected ? false : null);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),

          // Stock filter
          _buildFilterChip(
            label: l10n.lowStock,
            icon: Icons.inventory,
            selected: filter.showLowStock,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateShowLowStock(selected);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),

          // Expiry filters
          _buildFilterChip(
            label: l10n.expiring,
            icon: Icons.warning_amber,
            selected: filter.showExpiring,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateShowExpiring(selected);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          _buildFilterChip(
            label: l10n.expired,
            icon: Icons.error,
            selected: filter.showExpired,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateShowExpired(selected);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),

          // Medicine type filter (if types are loaded)
          medicineTypesAsync.when(
            data: (types) {
              if (types.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                child: Chip(
                  label: Text(filter.medicineType ?? l10n.type),
                  avatar: const Icon(Icons.medication, size: 18),
                  backgroundColor: (filter.medicineType != null)
                      ? const Color(0xFFBBDEFB)  // selected
                      : const Color(0xFFE3F2FD), // unselected
                  // backgroundColor: filter.medicineType != null
                  //     ? colorScheme.primaryContainer
                  //     : colorScheme.surfaceContainerHighest,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text(l10n.allTypes),
                  ),
                  ...types.map((type) => PopupMenuItem(
                    value: type,
                    child: Text(type),
                  )),
                ],
                onSelected: (String? value) {
                  ref.read(medicationFilterProvider.notifier).updateMedicineType(value);
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
    required ColorScheme colorScheme,
    IconData? icon,

  }) {
    const unselectedBg = Color(0xFFE3F2FD); // Light blue 50
    const selectedBg   = Color(0xFFBBDEFB); // Light blue 100
    final labelColor   = colorScheme.onSurface;

    return FilterChip(
      label: Text(label, style: TextStyle(color: labelColor)),
      avatar: icon != null ? Icon(icon, size: 18, color: labelColor) : null,
      // label: Text(label),
      // avatar: icon != null ? Icon(icon, size: 18) : null,
      selected: selected,
      onSelected: onSelected,
      backgroundColor: unselectedBg,
      selectedColor: selectedBg,
      //
      // backgroundColor: colorScheme.surfaceContainerHighest,
      // selectedColor: colorScheme.primaryContainer,
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return EmptyStateWidget(
      icon: Icons.medication_outlined,
      title: l10n.noMedicationsYet,
      subtitle: l10n.startByAdding,
      actionLabel: l10n.addMedication,
      onAction: () {
        HapticService.light();
        context.push('/add-medication');
      },
    );
  }

  Widget _buildNoResultsState(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: l10n.noResultsFound,
      subtitle: l10n.tryAdjusting,
    );
  }

  void _navigateToDetail(int medicationId) {
    context.push('/medication/$medicationId');
  }

  void _editMedication(int medicationId) {
    context.push('/medication/$medicationId/edit');
  }

  Future<void> _deleteMedication(int medicationId) async {
    final l10n = AppLocalizations.of(context)!;
    HapticService.warning();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedicationQuestion),
        content: Text(l10n.deleteMedicationConfirm),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.pop(context, false);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              HapticService.delete();
              Navigator.pop(context, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed ?? false && mounted) {
      try {
        final repository = ref.read(medicationRepositoryProvider);
        await repository.deleteMedication(medicationId);

        if (mounted) {
          HapticService.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.medicationDeleted),
              backgroundColor: Colors.green,
            ),
          );
        }

        // Refresh all medication providers
        ProviderRefreshUtils.refreshAllMedicationProviders(ref);
      } catch (e) {
        if (mounted) {
          HapticService.error();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorDeletingMedication(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
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

      if (mounted) {
        HapticService.success();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              medication.isActive
                  ? l10n.medicationPaused
                  : l10n.medicationResumed,
            ),
          ),
        );
      }

      ProviderRefreshUtils.refreshMedicationDetail(ref, medication.id);
    } catch (e) {
      if (mounted) {
        HapticService.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSortOptions(AppLocalizations l10n) {
    final currentSort = ref.read(medicationSortProvider);

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.sortBy,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text(l10n.nameAZ),
                trailing: currentSort == MedicationSortOption.nameAsc
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  ref.read(medicationSortProvider.notifier).updateSort(
                      MedicationSortOption.nameAsc);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.sort_by_alpha),
                title: Text(l10n.nameZA),
                trailing: currentSort == MedicationSortOption.nameDesc
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  ref.read(medicationSortProvider.notifier).updateSort(
                      MedicationSortOption.nameDesc);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(l10n.dateAddedNewest),
                trailing: currentSort == MedicationSortOption.dateNewest
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  ref.read(medicationSortProvider.notifier).updateSort(
                      MedicationSortOption.dateNewest);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(l10n.dateAddedOldest),
                trailing: currentSort == MedicationSortOption.dateOldest
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  ref.read(medicationSortProvider.notifier).updateSort(
                      MedicationSortOption.dateOldest);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(l10n.stockLowToHigh),
                trailing: currentSort == MedicationSortOption.stockLow
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  ref.read(medicationSortProvider.notifier).updateSort(
                      MedicationSortOption.stockLow);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.inventory),
                title: Text(l10n.stockHighToLow),
                trailing: currentSort == MedicationSortOption.stockHigh
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  ref.read(medicationSortProvider.notifier).updateSort(
                      MedicationSortOption.stockHigh);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Bulk selection methods
  void _selectAll() {
    final medications = ref.read(filteredMedicationsProvider).value;
    if (medications != null) {
      setState(() {
        _selectedMedicationIds.addAll(medications.map((m) => m.id));
      });
    }
  }

  Widget _buildSelectableCard(
    Medication medication,
    bool isSelected,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _selectedMedicationIds.remove(medication.id);
            } else {
              _selectedMedicationIds.add(medication.id);
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedMedicationIds.add(medication.id);
                    } else {
                      _selectedMedicationIds.remove(medication.id);
                    }
                  });
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.medicineName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medication.medicineType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBar(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: _selectedMedicationIds.isEmpty ? null : _bulkDelete,
            icon: const Icon(Icons.delete),
            label: Text(l10n.delete),
          ),
          TextButton.icon(
            onPressed: _selectedMedicationIds.isEmpty ? null : _bulkPause,
            icon: const Icon(Icons.pause),
            label: Text(l10n.pause),
          ),
          TextButton.icon(
            onPressed: _selectedMedicationIds.isEmpty ? null : _bulkResume,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.resume),
          ),
        ],
      ),
    );
  }

  Future<void> _bulkDelete() async {
    final l10n = AppLocalizations.of(context)!;
    HapticService.warning();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedicationQuestion),
        content: Text(l10n.deleteMedicationConfirm),
        actions: [
          TextButton(
            onPressed: () {
              HapticService.light();
              Navigator.pop(context, false);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              HapticService.delete();
              Navigator.pop(context, true);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed ?? false && mounted) {
      try {
        final repository = ref.read(medicationRepositoryProvider);
        for (final id in _selectedMedicationIds) {
          await repository.deleteMedication(id);
        }

        if (mounted) {
          HapticService.success();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedMedicationIds.length} ${l10n.medicationsDeleted ?? 'medication(s) deleted'}'),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          _isSelectionMode = false;
          _selectedMedicationIds.clear();
        });

        ProviderRefreshUtils.refreshAllMedicationProviders(ref);
      } catch (e) {
        if (mounted) {
          HapticService.error();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorDeletingMedication(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _bulkPause() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final database = ref.read(appDatabaseProvider);
      final medications = ref.read(filteredMedicationsProvider).value;

      if (medications != null) {
        for (final id in _selectedMedicationIds) {
          final med = medications.firstWhere((m) => m.id == id);
          final updated = med.copyWith(isActive: false);
          await database.updateMedication(updated);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedMedicationIds.length} ${l10n.medicationsPaused ?? 'medication(s) paused'}'),
            ),
          );
        }

        setState(() {
          _isSelectionMode = false;
          _selectedMedicationIds.clear();
        });

        ProviderRefreshUtils.refreshAllMedicationProviders(ref);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _bulkResume() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final database = ref.read(appDatabaseProvider);
      final medications = ref.read(filteredMedicationsProvider).value;

      if (medications != null) {
        for (final id in _selectedMedicationIds) {
          final med = medications.firstWhere((m) => m.id == id);
          final updated = med.copyWith(isActive: true);
          await database.updateMedication(updated);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedMedicationIds.length} ${l10n.medicationsResumed ?? 'medication(s) resumed'}'),
            ),
          );
        }

        setState(() {
          _isSelectionMode = false;
          _selectedMedicationIds.clear();
        });

        ProviderRefreshUtils.refreshAllMedicationProviders(ref);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorMessage(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
