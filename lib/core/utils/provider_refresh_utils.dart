import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/features/analytics/providers/analytics_providers.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/features/stock/providers/stock_providers.dart';

/// Utility class for refreshing providers after data changes
/// This ensures UI updates properly after CRUD operations
class ProviderRefreshUtils {
  ProviderRefreshUtils._();

  /// Refresh all medication-related providers
  /// Call this after adding, editing, or deleting medications
  static void refreshAllMedicationProviders(WidgetRef ref) {
    // Core medication providers
    ref.invalidate(medicationsProvider);
    ref.invalidate(todaysMedicationsProvider);
    ref.invalidate(medicationsWithRemindersProvider);
    ref.invalidate(hasMedicationsProvider);
    ref.invalidate(medicationCountProvider);
    ref.invalidate(lowStockMedicationsProvider);

    // Stock providers
    ref.invalidate(medicationsStockProvider);
    ref.invalidate(criticalStockProvider);
    ref.invalidate(lowStockProvider);
    ref.invalidate(stockStatisticsProvider);

    // Home providers
    ref.invalidate(todayDosesProvider);
    ref.invalidate(adherenceSummaryProvider);
    ref.invalidate(groupedDosesProvider);

    // Analytics providers
    ref.invalidate(todayAdherenceProvider);
    ref.invalidate(weekAdherenceProvider);
    ref.invalidate(monthAdherenceProvider);
    ref.invalidate(streakInfoProvider);
    ref.invalidate(medicationInsightsProvider);
    ref.invalidate(weeklyAdherenceProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(overallStatsProvider);
  }

  /// Refresh all stock-related providers
  /// Call this after adjusting stock levels
  static void refreshStockProviders(WidgetRef ref) {
    ref.invalidate(medicationsStockProvider);
    ref.invalidate(criticalStockProvider);
    ref.invalidate(lowStockProvider);
    ref.invalidate(stockStatisticsProvider);
    ref.invalidate(expiringMedicationsProvider);
    ref.invalidate(expiredMedicationsProvider);
    ref.invalidate(medicationsProvider); // Stock changes affect medications list
    ref.invalidate(lowStockMedicationsProvider);
  }

  /// Refresh all dose history providers
  /// Call this after recording doses (taken/skipped/missed)
  static void refreshDoseHistoryProviders(WidgetRef ref) {
    // Note: These are family providers, invalidating without params invalidates all instances
    // Cannot use ref.invalidate on family providers without params in current Riverpod
    // Instead, we refresh the related non-family providers and let them cascade

    // Refresh analytics since dose history affects them
    ref.invalidate(todayAdherenceProvider);
    ref.invalidate(weekAdherenceProvider);
    ref.invalidate(monthAdherenceProvider);
    ref.invalidate(streakInfoProvider);
    ref.invalidate(medicationInsightsProvider);
    ref.invalidate(weeklyAdherenceProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(overallStatsProvider);

    // Refresh home providers
    ref.invalidate(todayDosesProvider);
    ref.invalidate(adherenceSummaryProvider);
    ref.invalidate(groupedDosesProvider);
  }

  /// Refresh a specific medication detail
  /// Call this when editing a single medication
  static void refreshMedicationDetail(WidgetRef ref, int medicationId) {
    // Invalidate the specific medication
    ref.invalidate(medicationByIdProvider(medicationId));

    // Also refresh all lists since the medication appears in them
    refreshAllMedicationProviders(ref);
  }

  /// Refresh all providers (nuclear option)
  /// Use sparingly, only when you're not sure which providers need refresh
  static void refreshAll(WidgetRef ref) {
    refreshAllMedicationProviders(ref);
    refreshDoseHistoryProviders(ref);
  }
}
