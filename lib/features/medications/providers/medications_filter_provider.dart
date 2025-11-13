import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';

/// Sort options for medications list
enum MedicationSortOption {
  nameAsc,
  nameDesc,
  dateNewest,
  dateOldest,
  stockLow,
  stockHigh,
}

/// Filter options for medications list
class MedicationFilter {

  const MedicationFilter({
    this.searchQuery,
    this.medicineType,
    this.isActive,
    this.showLowStock = false,
    this.showExpiring = false,
    this.showExpired = false,
  });
  final String? searchQuery;
  final String? medicineType;
  final bool? isActive;
  final bool showLowStock;
  final bool showExpiring;
  final bool showExpired;

  MedicationFilter copyWith({
    String? searchQuery,
    String? medicineType,
    bool? isActive,
    bool? showLowStock,
    bool? showExpiring,
    bool? showExpired,
  }) {
    return MedicationFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      medicineType: medicineType ?? this.medicineType,
      isActive: isActive ?? this.isActive,
      showLowStock: showLowStock ?? this.showLowStock,
      showExpiring: showExpiring ?? this.showExpiring,
      showExpired: showExpired ?? this.showExpired,
    );
  }
}

/// State notifier for medication filter
class MedicationFilterNotifier extends Notifier<MedicationFilter> {
  @override
  MedicationFilter build() => const MedicationFilter();

  void updateFilter(MedicationFilter filter) {
    state = filter;
  }

  void updateSearchQuery(String? query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateMedicineType(String? type) {
    state = state.copyWith(medicineType: type);
  }

  void updateIsActive(bool? isActive) {
    state = state.copyWith(isActive: isActive);
  }

  void updateShowLowStock(bool show) {
    state = state.copyWith(showLowStock: show);
  }

  void updateShowExpiring(bool show) {
    state = state.copyWith(showExpiring: show);
  }

  void updateShowExpired(bool show) {
    state = state.copyWith(showExpired: show);
  }
}

/// State notifier for medication sort
class MedicationSortNotifier extends Notifier<MedicationSortOption> {
  @override
  MedicationSortOption build() => MedicationSortOption.nameAsc;

  void updateSort(MedicationSortOption sortOption) {
    state = sortOption;
  }
}

/// Provider for current filter state
final medicationFilterProvider = NotifierProvider<MedicationFilterNotifier, MedicationFilter>(
  MedicationFilterNotifier.new,
);

/// Provider for current sort option
final medicationSortProvider = NotifierProvider<MedicationSortNotifier, MedicationSortOption>(
  MedicationSortNotifier.new,
);

/// Provider for filtered and sorted medications
final filteredMedicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final allMedications = await ref.watch(medicationsProvider.future);
  final filter = ref.watch(medicationFilterProvider);
  final sortOption = ref.watch(medicationSortProvider);

  // Apply filters
  final filtered = allMedications.where((med) {
    // Search query filter
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!;
      final matchesName = med.medicineName.toLowerCase().contains(query);
      final matchesType = med.medicineType.toLowerCase().contains(query);
      if (!matchesName && !matchesType) return false;
    }

    // Medicine type filter
    if (filter.medicineType != null && filter.medicineType!.isNotEmpty) {
      if (med.medicineType != filter.medicineType) return false;
    }

    // Active status filter
    if (filter.isActive != null) {
      if (med.isActive != filter.isActive!) return false;
    }

    // Low stock filter
    if (filter.showLowStock) {
      final dailyUsage = med.timesPerDay * med.dosePerTime;
      if (dailyUsage > 0) {
        final daysRemaining = med.stockQuantity / dailyUsage;
        if (daysRemaining >= med.reminderDaysBeforeRunOut) return false;
      }
    }

    // Expiring filter
    if (filter.showExpiring) {
      if (med.expiryDate == null) return false;
      final now = DateTime.now();
      final daysUntilExpiry = med.expiryDate!.difference(now).inDays;
      if (daysUntilExpiry < 0 || daysUntilExpiry > med.reminderDaysBeforeExpiry) {
        return false;
      }
    }

    // Expired filter
    if (filter.showExpired) {
      if (med.expiryDate == null) return false;
      final now = DateTime.now();
      if (!med.expiryDate!.isBefore(now)) return false;
    }

    return true;
  }).toList();

  // Apply sorting
  filtered.sort((a, b) {
    switch (sortOption) {
      case MedicationSortOption.nameAsc:
        return a.medicineName.compareTo(b.medicineName);
      case MedicationSortOption.nameDesc:
        return b.medicineName.compareTo(a.medicineName);
      case MedicationSortOption.dateNewest:
        return b.createdAt.compareTo(a.createdAt);
      case MedicationSortOption.dateOldest:
        return a.createdAt.compareTo(b.createdAt);
      case MedicationSortOption.stockLow:
        // Calculate days remaining for sorting
        final aDaysRemaining = a.timesPerDay * a.dosePerTime > 0
            ? a.stockQuantity / (a.timesPerDay * a.dosePerTime)
            : 999.0;
        final bDaysRemaining = b.timesPerDay * b.dosePerTime > 0
            ? b.stockQuantity / (b.timesPerDay * b.dosePerTime)
            : 999.0;
        return aDaysRemaining.compareTo(bDaysRemaining);
      case MedicationSortOption.stockHigh:
        final aDaysRemaining = a.timesPerDay * a.dosePerTime > 0
            ? a.stockQuantity / (a.timesPerDay * a.dosePerTime)
            : 999.0;
        final bDaysRemaining = b.timesPerDay * b.dosePerTime > 0
            ? b.stockQuantity / (b.timesPerDay * b.dosePerTime)
            : 999.0;
        return bDaysRemaining.compareTo(aDaysRemaining);
    }
  });

  return filtered;
});

/// Provider for available medicine types
final medicineTypesProvider = FutureProvider<List<String>>((ref) async {
  final medications = await ref.watch(medicationsProvider.future);
  final types = medications.map((m) => m.medicineType).toSet().toList();
  types.sort();
  return types;
});
