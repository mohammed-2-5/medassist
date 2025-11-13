import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';

/// Model for medication stock information
class MedicationStock {

  MedicationStock({
    required this.medication,
    required this.currentStock,
    required this.daysRemaining,
    required this.stockLevel,
    required this.isExpired, required this.isExpiringSoon, this.expiryDate,
    this.daysUntilExpiry,
  });
  final Medication medication;
  final int currentStock;
  final double daysRemaining;
  final StockLevel stockLevel;
  final DateTime? expiryDate;
  final int? daysUntilExpiry;
  final bool isExpired;
  final bool isExpiringSoon;
}

/// Stock level categories
enum StockLevel {
  critical, // < 3 days
  low,      // < 7 days
  medium,   // < 14 days
  good,     // >= 14 days
}

/// Provider for all medications with stock information
final medicationsStockProvider = FutureProvider<List<MedicationStock>>((ref) async {
  final database = ref.watch(appDatabaseProvider);

  // Get all active medications
  final medications = await database.getActiveMedications();
  final stockList = <MedicationStock>[];

  for (final medication in medications) {
    // Calculate daily usage: timesPerDay * dosePerTime
    final dailyUsage = medication.timesPerDay * medication.dosePerTime;

    // Calculate days remaining
    final daysRemaining = dailyUsage > 0
        ? medication.stockQuantity / dailyUsage
        : 999.0; // Effectively infinite if no daily usage

    // Determine stock level
    final stockLevel = _determineStockLevel(daysRemaining);

    // Calculate expiry information
    int? daysUntilExpiry;
    var isExpired = false;
    var isExpiringSoon = false;

    if (medication.expiryDate != null) {
      final now = DateTime.now();
      daysUntilExpiry = medication.expiryDate!.difference(now).inDays;

      if (daysUntilExpiry < 0) {
        isExpired = true;
      } else if (daysUntilExpiry <= medication.reminderDaysBeforeExpiry) {
        isExpiringSoon = true;
      }
    }

    stockList.add(MedicationStock(
      medication: medication,
      currentStock: medication.stockQuantity,
      daysRemaining: daysRemaining,
      stockLevel: stockLevel,
      expiryDate: medication.expiryDate,
      daysUntilExpiry: daysUntilExpiry,
      isExpired: isExpired,
      isExpiringSoon: isExpiringSoon,
    ));
  }

  // Sort by stock level (critical first)
  stockList.sort((a, b) {
    final levelComparison = a.stockLevel.index.compareTo(b.stockLevel.index);
    if (levelComparison != 0) return levelComparison;
    // If same level, sort by days remaining
    return a.daysRemaining.compareTo(b.daysRemaining);
  });

  return stockList;
});


/// Determine stock level based on days remaining
StockLevel _determineStockLevel(double daysRemaining) {
  if (daysRemaining < 3) {
    return StockLevel.critical;
  } else if (daysRemaining < 7) {
    return StockLevel.low;
  } else if (daysRemaining < 14) {
    return StockLevel.medium;
  } else {
    return StockLevel.good;
  }
}

/// Provider for critical stock medications (< 3 days)
final criticalStockProvider = FutureProvider<List<MedicationStock>>((ref) async {
  final allStock = await ref.watch(medicationsStockProvider.future);
  return allStock.where((stock) => stock.stockLevel == StockLevel.critical).toList();
});

/// Provider for low stock medications (< 7 days)
final lowStockProvider = FutureProvider<List<MedicationStock>>((ref) async {
  final allStock = await ref.watch(medicationsStockProvider.future);
  return allStock.where((stock) =>
    stock.stockLevel == StockLevel.critical || stock.stockLevel == StockLevel.low
  ).toList();
});

/// Provider for stock statistics
final stockStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final allStock = await ref.watch(medicationsStockProvider.future);

  return {
    'total': allStock.length,
    'critical': allStock.where((s) => s.stockLevel == StockLevel.critical).length,
    'low': allStock.where((s) => s.stockLevel == StockLevel.low).length,
    'medium': allStock.where((s) => s.stockLevel == StockLevel.medium).length,
    'good': allStock.where((s) => s.stockLevel == StockLevel.good).length,
    'expired': allStock.where((s) => s.isExpired).length,
    'expiring_soon': allStock.where((s) => s.isExpiringSoon && !s.isExpired).length,
  };
});

/// Provider for expiring medications
final expiringMedicationsProvider = FutureProvider<List<MedicationStock>>((ref) async {
  final allStock = await ref.watch(medicationsStockProvider.future);
  return allStock.where((stock) => stock.isExpiringSoon && !stock.isExpired).toList();
});

/// Provider for expired medications
final expiredMedicationsProvider = FutureProvider<List<MedicationStock>>((ref) async {
  final allStock = await ref.watch(medicationsStockProvider.future);
  return allStock.where((stock) => stock.isExpired).toList();
});
