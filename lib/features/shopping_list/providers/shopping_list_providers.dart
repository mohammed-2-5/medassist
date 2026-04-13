import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/repositories/medication_repository.dart';
import 'package:med_assist/features/shopping_list/models/shopping_list_item.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';

enum ShoppingListGroup { urgentRefill, expiringSoon }

final shoppingListItemsProvider = FutureProvider<List<ShoppingListItem>>((
  ref,
) async {
  final lowStockItems = await ref.watch(lowStockProvider.future);
  final expiringItems = await ref.watch(expiringMedicationsProvider.future);
  final expiredItems = await ref.watch(expiredMedicationsProvider.future);

  final merged = <int, ShoppingListItem>{};

  for (final stock in lowStockItems) {
    final dailyUsage = MedicationRepository.effectiveDailyUsage(
      stock.medication,
    );
    final weeklyTarget = (dailyUsage * 7).ceil();
    final suggestedQuantity = weeklyTarget > stock.currentStock
        ? weeklyTarget - stock.currentStock
        : 1;

    merged[stock.medication.id] = ShoppingListItem(
      medication: stock.medication,
      currentStock: stock.currentStock,
      suggestedQuantity: suggestedQuantity,
      daysRemaining: stock.daysRemaining,
      isCriticalStock: stock.stockLevel == StockLevel.critical,
      isLowStock: true,
      isExpiringSoon: stock.isExpiringSoon,
      isExpired: stock.isExpired,
      daysUntilExpiry: stock.daysUntilExpiry,
    );
  }

  for (final stock in [...expiringItems, ...expiredItems]) {
    final existing = merged[stock.medication.id];
    merged[stock.medication.id] = ShoppingListItem(
      medication: stock.medication,
      currentStock: stock.currentStock,
      suggestedQuantity: existing?.suggestedQuantity ?? 1,
      daysRemaining: stock.daysRemaining,
      isCriticalStock:
          existing?.isCriticalStock ?? stock.stockLevel == StockLevel.critical,
      isLowStock: existing?.isLowStock ?? false,
      isExpiringSoon: stock.isExpiringSoon,
      isExpired: stock.isExpired,
      daysUntilExpiry: stock.daysUntilExpiry,
    );
  }

  return merged.values.toList();
});

final shoppingListGroupsProvider =
    FutureProvider<Map<ShoppingListGroup, List<ShoppingListItem>>>((ref) async {
      final items = await ref.watch(shoppingListItemsProvider.future);

      final urgent = items.where((item) => item.isLowStock).toList()
        ..sort((a, b) {
          final criticalComparison = (b.isCriticalStock ? 1 : 0).compareTo(
            a.isCriticalStock ? 1 : 0,
          );
          if (criticalComparison != 0) return criticalComparison;
          return a.daysRemaining.compareTo(b.daysRemaining);
        });

      final expiring =
          items.where((item) => item.isExpiringSoon || item.isExpired).toList()
            ..sort((a, b) {
              const noExpiry = 365 * 100;
              final aDays = a.daysUntilExpiry ?? noExpiry;
              final bDays = b.daysUntilExpiry ?? noExpiry;
              return aDays.compareTo(bDays);
            });

      return {
        ShoppingListGroup.urgentRefill: urgent,
        ShoppingListGroup.expiringSoon: expiring,
      };
    });
