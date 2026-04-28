import 'package:med_assist/features/add_medication/models/medication_form_data.dart';

/// Top-level scheduling mode shown as segmented control in the UI.
enum SmartScheduleMode {
  daily,
  weekly,
  monthly,
  asNeeded;

  static SmartScheduleMode fromPattern(RepetitionPattern pattern) {
    switch (pattern) {
      case RepetitionPattern.daily:
      case RepetitionPattern.everyOtherDay:
      case RepetitionPattern.everyNDays:
        return SmartScheduleMode.daily;
      case RepetitionPattern.weekly:
      case RepetitionPattern.weekdays:
      case RepetitionPattern.weekends:
      case RepetitionPattern.twiceAWeek:
      case RepetitionPattern.thriceAWeek:
      case RepetitionPattern.specificDays:
        return SmartScheduleMode.weekly;
      case RepetitionPattern.monthly:
        return SmartScheduleMode.monthly;
      case RepetitionPattern.asNeeded:
        return SmartScheduleMode.asNeeded;
    }
  }
}
