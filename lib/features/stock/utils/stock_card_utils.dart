import 'package:flutter/material.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';
import 'package:med_assist/l10n/app_localizations.dart';

Color getStockLevelColor(StockLevel level) {
  switch (level) {
    case StockLevel.critical:
      return Colors.red;
    case StockLevel.low:
      return Colors.orange;
    case StockLevel.medium:
      return Colors.yellow.shade700;
    case StockLevel.good:
      return Colors.green;
  }
}

String getStockLevelLabel(StockLevel level, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (level) {
    case StockLevel.critical:
      return l10n.stockLevelCritical;
    case StockLevel.low:
      return l10n.stockLevelLow;
    case StockLevel.medium:
      return l10n.stockLevelMedium;
    case StockLevel.good:
      return l10n.stockLevelGood;
  }
}

String getStockWarningMessage(StockLevel level, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (level) {
    case StockLevel.critical:
      return l10n.stockWarningCritical;
    case StockLevel.low:
      return l10n.stockWarningLow;
    default:
      return '';
  }
}

double getStockProgressValue(double daysRemaining) {
  if (daysRemaining >= 14) return 1;
  return (daysRemaining / 14).clamp(0.0, 1.0);
}

String formatExpiryDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String getExpiryStatusText(bool isExpired, int? daysUntilExpiry, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  if (isExpired) return l10n.expired;
  final days = daysUntilExpiry;
  if (days == null) return l10n.expiryStatusGood;
  if (days == 0) return l10n.expiryStatusToday;
  if (days == 1) return l10n.expiryStatusTomorrow;
  return l10n.expiryStatusInDays(days);
}
