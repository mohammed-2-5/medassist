import 'package:med_assist/core/database/app_database.dart';

class ShoppingListItem {
  ShoppingListItem({
    required this.medication,
    required this.currentStock,
    required this.suggestedQuantity,
    required this.daysRemaining,
    required this.isCriticalStock,
    required this.isLowStock,
    required this.isExpiringSoon,
    required this.isExpired,
    this.daysUntilExpiry,
  });

  final Medication medication;
  final int currentStock;
  final int suggestedQuantity;
  final double daysRemaining;
  final bool isCriticalStock;
  final bool isLowStock;
  final bool isExpiringSoon;
  final bool isExpired;
  final int? daysUntilExpiry;
}
