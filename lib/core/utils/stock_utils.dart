import 'package:med_assist/core/database/app_database.dart';

/// Shared stock calculation logic.
class StockUtils {
  const StockUtils._();

  /// Daily dose usage for a medication.
  static double dailyUsage(Medication med) =>
      (med.timesPerDay * med.dosePerTime).toDouble();

  /// Estimated days of stock remaining, or -1 if usage is zero.
  static int daysRemaining(Medication med) {
    final usage = dailyUsage(med);
    if (usage <= 0) return -1;
    return (med.stockQuantity / usage).floor();
  }
}
