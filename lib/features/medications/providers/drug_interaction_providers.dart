import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';

final drugInteractionServiceProvider = Provider<DrugInteractionService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DrugInteractionService(database);
});

final allInteractionsProvider =
    FutureProvider<List<InteractionWarning>>((ref) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.checkAllInteractions();
});

final hasSevereInteractionsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.hasSevereInteractions();
});

final interactionCountsProvider =
    FutureProvider<Map<InteractionSeverity, int>>((ref) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.getInteractionCounts();
});

class NewMedicationCheckParams {
  const NewMedicationCheckParams({
    required this.name,
    this.activeIngredients,
    this.drugCategory,
  });
  final String name;
  final String? activeIngredients;
  final String? drugCategory;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NewMedicationCheckParams &&
          name == other.name &&
          activeIngredients == other.activeIngredients &&
          drugCategory == other.drugCategory;

  @override
  int get hashCode => Object.hash(name, activeIngredients, drugCategory);
}

final checkNewMedicationProvider = FutureProvider.family<
    List<InteractionWarning>, NewMedicationCheckParams>((ref, params) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.checkNewMedication(
    params.name,
    activeIngredients: params.activeIngredients,
    drugCategory: params.drugCategory,
  );
});
