import 'package:med_assist/features/reminders/models/reminder.dart';

class ReminderRepository {
  // TODO: Implement with Drift database

  Future<List<Reminder>> getAllReminders() async {
    // TODO: Fetch from database
    return [];
  }

  Future<Reminder?> getReminderById(String id) async {
    // TODO: Fetch from database
    return null;
  }

  Future<void> createReminder(Reminder reminder) async {
    // TODO: Insert into database
    // TODO: Schedule notification
  }

  Future<void> updateReminder(Reminder reminder) async {
    // TODO: Update in database
    // TODO: Update notification
  }

  Future<void> deleteReminder(String id) async {
    // TODO: Delete from database
    // TODO: Cancel notification
  }

  Future<void> toggleReminderActive(String id) async {
    // TODO: Toggle active status
    // TODO: Enable/disable notification
  }
}
