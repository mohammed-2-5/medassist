import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/medications/providers/medications_filter_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Premium Filter Chips for Medications List
///
/// Features:
/// - Status filters (Active, Paused)
/// - Alert filters (Low Stock, Expiring, Expired)
/// - Medicine type filter with popup menu
/// - Cyan-themed with scale animations
/// - Adaptive dark/light mode
class MedicationsFilterChips extends ConsumerWidget {
  const MedicationsFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final filter = ref.watch(medicationFilterProvider);
    final medicineTypesAsync = ref.watch(medicineTypesProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Active filter
          _FilterChip(
            label: l10n.active,
            selected: filter.isActive ?? false,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateIsActive(selected ? true : null);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),

          // Paused filter
          _FilterChip(
            label: l10n.paused,
            selected: filter.isActive == false,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateIsActive(selected ? false : null);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),

          // Low Stock filter
          _FilterChip(
            label: l10n.lowStock,
            icon: Icons.inventory,
            selected: filter.showLowStock,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateShowLowStock(selected);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),

          // Expiring filter
          _FilterChip(
            label: l10n.expiring,
            icon: Icons.warning_amber,
            selected: filter.showExpiring,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateShowExpiring(selected);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),

          // Expired filter
          _FilterChip(
            label: l10n.expired,
            icon: Icons.error,
            selected: filter.showExpired,
            onSelected: (selected) {
              ref.read(medicationFilterProvider.notifier).updateShowExpired(selected);
            },
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),

          // Medicine type filter
          medicineTypesAsync.when(
            data: (types) {
              if (types.isEmpty) return const SizedBox.shrink();
              return _MedicineTypeChip(types: types, filter: filter, colorScheme: colorScheme);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// Individual Filter Chip Widget
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    required this.colorScheme,
    this.icon,
  });

  final String label;
  final bool selected;
  final Function(bool) onSelected;
  final ColorScheme colorScheme;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final chipColor = selected ? const Color(0xFF00BCD4) : colorScheme.surfaceContainerHigh;
    final labelColor = selected ? colorScheme.onPrimary : colorScheme.onSurface;
    final borderColor = selected
        ? const Color(0xFF00BCD4)
        : colorScheme.outline.withOpacity(0.3);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
        avatar: icon != null
            ? Icon(icon, size: 18, color: labelColor)
            : null,
        selected: selected,
        onSelected: onSelected,
        backgroundColor: chipColor,
        selectedColor: chipColor,
        side: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        elevation: selected ? 2 : 0,
        shadowColor: colorScheme.primary.withOpacity(0.3),
      ).animate(target: selected ? 1 : 0)
       .scale(
         begin: const Offset(1, 1),
         end: const Offset(1.05, 1.05),
         duration: const Duration(milliseconds: 200),
       ),
    );
  }
}

/// Medicine Type Popup Chip
class _MedicineTypeChip extends ConsumerWidget {
  const _MedicineTypeChip({
    required this.types,
    required this.filter,
    required this.colorScheme,
  });

  final List<String> types;
  final MedicationFilter filter;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = filter.medicineType != null;
    final chipColor = isSelected ? colorScheme.primary : colorScheme.surfaceContainerHigh;
    final labelColor = isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: PopupMenuButton<String?>(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Chip(
          label: Text(
            filter.medicineType ?? l10n.type,
            style: TextStyle(
              color: labelColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
          avatar: Icon(
            Icons.medication,
            size: 18,
            color: labelColor,
          ),
          backgroundColor: chipColor,
          side: BorderSide(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withOpacity(0.3),
            width: 1.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          elevation: isSelected ? 2 : 0,
          shadowColor: colorScheme.primary.withOpacity(0.3),
        ).animate(target: isSelected ? 1 : 0)
         .scale(
           begin: const Offset(1, 1),
           end: const Offset(1.05, 1.05),
           duration: const Duration(milliseconds: 200),
         ),
        itemBuilder: (context) => [
          PopupMenuItem<String?>(
            child: Text(l10n.allTypes),
          ),
          ...types.map((type) => PopupMenuItem<String?>(
            value: type,
            child: Text(type),
          )),
        ],
        onSelected: (String? value) {
          ref.read(medicationFilterProvider.notifier).updateMedicineType(value);
        },
      ),
    );
  }
}
