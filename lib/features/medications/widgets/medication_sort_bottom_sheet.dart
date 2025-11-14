import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Medication Sort Options Bottom Sheet
///
/// Shows sorting options for medications list:
/// - Name (A-Z, Z-A)
/// - Date Added (Newest, Oldest)
/// - Stock (Low to High, High to Low)
class MedicationSortBottomSheet extends ConsumerWidget {
  const MedicationSortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentSort = ref.watch(medicationSortProvider);

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
          _buildSortOption(
            context,
            ref,
            icon: Icons.sort_by_alpha,
            title: l10n.nameAZ,
            option: MedicationSortOption.nameAsc,
            isSelected: currentSort == MedicationSortOption.nameAsc,
          ),
          _buildSortOption(
            context,
            ref,
            icon: Icons.sort_by_alpha,
            title: l10n.nameZA,
            option: MedicationSortOption.nameDesc,
            isSelected: currentSort == MedicationSortOption.nameDesc,
          ),
          _buildSortOption(
            context,
            ref,
            icon: Icons.access_time,
            title: l10n.dateAddedNewest,
            option: MedicationSortOption.dateNewest,
            isSelected: currentSort == MedicationSortOption.dateNewest,
          ),
          _buildSortOption(
            context,
            ref,
            icon: Icons.access_time,
            title: l10n.dateAddedOldest,
            option: MedicationSortOption.dateOldest,
            isSelected: currentSort == MedicationSortOption.dateOldest,
          ),
          _buildSortOption(
            context,
            ref,
            icon: Icons.inventory,
            title: l10n.stockLowToHigh,
            option: MedicationSortOption.stockLow,
            isSelected: currentSort == MedicationSortOption.stockLow,
          ),
          _buildSortOption(
            context,
            ref,
            icon: Icons.inventory,
            title: l10n.stockHighToLow,
            option: MedicationSortOption.stockHigh,
            isSelected: currentSort == MedicationSortOption.stockHigh,
          ),
        ],
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String title,
    required MedicationSortOption option,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check) : null,
      onTap: () {
        ref.read(medicationSortProvider.notifier).updateSort(option);
        Navigator.pop(context);
      },
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const MedicationSortBottomSheet(),
    );
  }
}
