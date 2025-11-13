import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/repositories/medication_repository.dart';
import 'package:riverpod/src/providers/future_provider.dart';

/// Provider for the app database instance
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  // Dispose database when provider is disposed
  ref.onDispose(database.close);

  return database;
});

/// Provider for the medication repository
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return MedicationRepository(database);
});

/// Provider to check if any medications exist
final hasMedicationsProvider = FutureProvider<bool>((ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.hasMedications();
});

/// Provider to get all medications
final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getAllMedications();
});

/// Provider to get today's medications
final todaysMedicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getTodaysMedications();
});

/// Provider to get medications with reminders
final medicationsWithRemindersProvider =
    FutureProvider<List<MedicationWithReminders>>((ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getMedicationsWithReminders();
});

/// Provider to get low stock medications
final lowStockMedicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getLowStockMedications();
});

/// Provider to get medication count
final medicationCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getMedicationCount();
});

/// Provider to search medications
final FutureProviderFamily<List<Medication>, String> medicationSearchProvider =
    FutureProvider.family<List<Medication>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.searchMedications(query);
});

/// Provider to get a specific medication by ID
final FutureProviderFamily<Medication?, int> medicationByIdProvider =
    FutureProvider.family<Medication?, int>((ref, id) async {
  final repository = ref.watch(medicationRepositoryProvider);
  return repository.getMedicationById(id);
});
