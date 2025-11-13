import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/reminders/models/reminder.dart';
import 'package:med_assist/features/reminders/repositories/reminder_repository.dart';
import 'package:riverpod/src/providers/future_provider.dart';

// Repository provider
final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  return ReminderRepository();
});

// Reminders list provider
final remindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getAllReminders();
});

// Single reminder provider
final FutureProviderFamily<Reminder?, String> reminderProvider = FutureProvider.family<Reminder?, String>((ref, id) async {
  final repository = ref.watch(reminderRepositoryProvider);
  return repository.getReminderById(id);
});

// Reminder controller provider
final reminderControllerProvider = Provider<ReminderController>((ref) {
  return ReminderController(ref.watch(reminderRepositoryProvider));
});

class ReminderController {

  ReminderController(this._repository);
  final ReminderRepository _repository;

  Future<void> createReminder(Reminder reminder) async {
    await _repository.createReminder(reminder);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _repository.updateReminder(reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _repository.deleteReminder(id);
  }

  Future<void> toggleReminderActive(String id) async {
    await _repository.toggleReminderActive(id);
  }
}
