import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/services/health/drug_interaction_service.dart';
import 'package:riverpod/src/providers/future_provider.dart';

/// Provider for DrugInteractionService
final drugInteractionServiceProvider = Provider<DrugInteractionService>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DrugInteractionService(database);
});

/// Provider for all drug interaction warnings
final allInteractionsProvider = FutureProvider<List<InteractionWarning>>((ref) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.checkAllInteractions();
});

/// Provider for checking if severe interactions exist
final hasSevereInteractionsProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.hasSevereInteractions();
});

/// Provider for interaction counts by severity
final interactionCountsProvider =
    FutureProvider<Map<InteractionSeverity, int>>((ref) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.getInteractionCounts();
});

/// Provider for checking a new medication against existing ones
final FutureProviderFamily<List<InteractionWarning>, String> checkNewMedicationProvider =
    FutureProvider.family<List<InteractionWarning>, String>((ref, medicationName) async {
  final service = ref.watch(drugInteractionServiceProvider);
  return service.checkNewMedication(medicationName);
});
