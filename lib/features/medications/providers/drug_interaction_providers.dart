import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';
import 'package:med_assist/services/health/persisted_interaction_service.dart';

final drugInteractionServiceProvider = Provider<DrugInteractionService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DrugInteractionService(database);
});

final persistedInteractionServiceProvider =
    Provider<PersistedInteractionService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return PersistedInteractionService(database);
});

final medicationInteractionsProvider =
    FutureProvider.family<List<InteractionWarning>, int>((ref, medId) async {
  final service = ref.watch(persistedInteractionServiceProvider);
  return service.forMedication(medId);
});

final allInteractionsProvider = FutureProvider<List<InteractionWarning>>((
  ref,
) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.checkAllInteractions();
});

final hasSevereInteractionsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.hasSevereInteractions();
});

final interactionCountsProvider = FutureProvider<Map<InteractionSeverity, int>>(
  (ref) async {
    final service = ref.watch(drugInteractionServiceProvider);
    return service.getInteractionCounts();
  },
);

class NewMedicationCheckParams {
  const NewMedicationCheckParams({
    required this.name,
    this.activeIngredients,
    this.drugCategory,
    this.strength,
    this.dosePerTime,
    this.timesPerDay,
    this.reminderMinutes,
  });
  final String name;
  final String? activeIngredients;
  final String? drugCategory;
  final String? strength;
  final double? dosePerTime;
  final int? timesPerDay;
  final List<int>? reminderMinutes;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewMedicationCheckParams &&
          name == other.name &&
          activeIngredients == other.activeIngredients &&
          drugCategory == other.drugCategory &&
          strength == other.strength &&
          dosePerTime == other.dosePerTime &&
          timesPerDay == other.timesPerDay &&
          _listEquals(reminderMinutes, other.reminderMinutes);

  @override
  int get hashCode => Object.hash(
    name,
    activeIngredients,
    drugCategory,
    strength,
    dosePerTime,
    timesPerDay,
    Object.hashAll(reminderMinutes ?? const []),
  );
}

bool _listEquals(List<int>? a, List<int>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

final checkNewMedicationProvider =
    FutureProvider.family<List<InteractionWarning>, NewMedicationCheckParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(drugInteractionServiceProvider);
      return service.checkNewMedication(
        params.name,
        activeIngredients: params.activeIngredients,
        drugCategory: params.drugCategory,
        strength: params.strength,
        dosePerTime: params.dosePerTime,
        timesPerDay: params.timesPerDay,
        reminderMinutes: params.reminderMinutes,
      );
    });
