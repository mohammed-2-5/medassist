import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';

/// Centralized factory methods for generating deterministic test data.
class TestDataFactory {
  const TestDataFactory._();

  /// Creates a medication data row with sensible defaults.
  static Medication medication({
    int id = 1,
    String name = 'Aspirin',
    int stockQuantity = 30,
    double dosePerTime = 1,
    int timesPerDay = 2,
    bool isActive = true,
    DateTime? startDate,
    DateTime? expiryDate,
  }) {
    final now = DateTime.now();
    return Medication(
      id: id,
      medicineType: 'pill',
      medicineName: name,
      strength: '500',
      unit: 'mg',
      isScanned: false,
      timesPerDay: timesPerDay,
      dosePerTime: dosePerTime,
      doseUnit: 'tablet',
      durationDays: 30,
      startDate: startDate ?? DateTime(now.year, now.month, now.day),
      repetitionPattern: 'daily',
      specificDaysOfWeek: '1,2,3,4,5,6,7',
      stockQuantity: stockQuantity,
      remindBeforeRunOut: true,
      reminderDaysBeforeRunOut: 3,
      expiryDate: expiryDate,
      reminderDaysBeforeExpiry: 30,
      maxSnoozesPerDay: 3,
      enableRecurringReminders: false,
      recurringReminderInterval: 30,
      createdAt: now,
      updatedAt: now,
      isActive: isActive,
    );
  }

  /// Creates a stock entry based on a [Medication].
  static MedicationStock medicationStock({
    Medication? medication,
    int currentStock = 30,
    double daysRemaining = 10,
    StockLevel stockLevel = StockLevel.good,
    bool isExpired = false,
    bool isExpiringSoon = false,
    DateTime? expiryDate,
    int? daysUntilExpiry,
  }) {
    final med =
        medication ??
        TestDataFactory.medication(
          id: 99,
          stockQuantity: currentStock,
          expiryDate: expiryDate,
        );

    return MedicationStock(
      medication: med,
      currentStock: currentStock,
      daysRemaining: daysRemaining,
      stockLevel: stockLevel,
      expiryDate: expiryDate,
      daysUntilExpiry: daysUntilExpiry,
      isExpired: isExpired,
      isExpiringSoon: isExpiringSoon,
    );
  }

  /// Creates a dose event for home timeline tests.
  static DoseEvent doseEvent({
    String id = 'dose-1',
    String medicationId = '1',
    String medicationName = 'Aspirin',
    String dosage = '1 tablet',
    String time = '08:00 AM',
    DoseStatus status = DoseStatus.pending,
    int? stockRemaining = 28,
  }) {
    return DoseEvent(
      id: id,
      medicationId: medicationId,
      medicationName: medicationName,
      dosage: dosage,
      time: time,
      status: status,
      stockRemaining: stockRemaining,
    );
  }

  /// Generates a series of hourly adherence data for analytics widgets.
  static List<HourlyAdherenceData> hourlyAdherenceSeries({
    double peakPercentage = 95,
  }) {
    return List.generate(24, (index) {
      final total = index.isEven ? 4 : 2;
      final taken = (total * (peakPercentage / 100)).clamp(0, total).round();
      return HourlyAdherenceData(
        hour: index,
        totalDoses: total,
        takenDoses: taken,
        missedDoses: total - taken,
      );
    });
  }

  /// Convenience helper for analytics adherence stats.
  static AdherenceStats adherenceStats({
    int totalDoses = 12,
    int takenDoses = 10,
    int missedDoses = 1,
    int skippedDoses = 1,
    int snoozedDoses = 0,
  }) {
    return AdherenceStats(
      totalDoses: totalDoses,
      takenDoses: takenDoses,
      missedDoses: missedDoses,
      skippedDoses: skippedDoses,
      snoozedDoses: snoozedDoses,
    );
  }
}
