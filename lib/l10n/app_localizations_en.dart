// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MedAssist';

  @override
  String get home => 'Home';

  @override
  String get medications => 'Medications';

  @override
  String get reminders => 'Reminders';

  @override
  String get reports => 'Reports';

  @override
  String get settings => 'Settings';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get editMedication => 'Edit Medication';

  @override
  String get deleteMedication => 'Delete Medication';

  @override
  String get medicationDetails => 'Medication Details';

  @override
  String get medicineName => 'Medicine Name';

  @override
  String get medicineType => 'Medicine Type';

  @override
  String get strength => 'Strength';

  @override
  String get dosage => 'Dosage';

  @override
  String get frequency => 'Frequency';

  @override
  String get duration => 'Duration';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get notes => 'Notes';

  @override
  String get tablet => 'Tablet';

  @override
  String get capsule => 'Capsule';

  @override
  String get syrup => 'Syrup';

  @override
  String get injection => 'Injection';

  @override
  String get drops => 'Drops';

  @override
  String get inhaler => 'Inhaler';

  @override
  String get cream => 'Cream';

  @override
  String get other => 'Other';

  @override
  String get timesPerDay => 'Times Per Day';

  @override
  String get dosePerTime => 'Dose Per Time';

  @override
  String get durationDays => 'Duration (Days)';

  @override
  String get stockQuantity => 'Stock Quantity';

  @override
  String get lowStockAlert => 'Low stock! Time to refill soon.';

  @override
  String get enableLowStockAlert => 'Enable Low Stock Alert';

  @override
  String get remindBeforeRunOut => 'Remind Before Run Out';

  @override
  String get daysBeforeRunOut => 'Days Before Run Out';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get addReminderTime => 'Add Reminder Time';

  @override
  String get editReminderTime => 'Edit Reminder Time';

  @override
  String get deleteReminderTime => 'Delete Reminder Time';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsEnabled => 'Notifications Enabled';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get sound => 'Sound';

  @override
  String get vibration => 'Vibration';

  @override
  String get snoozeDuration => 'Snooze Duration';

  @override
  String get minutes => 'Minutes';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get systemDefault => 'System Default';

  @override
  String get language => 'Language';

  @override
  String get appLanguage => 'App Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية (Arabic)';

  @override
  String get alerts => 'Alerts';

  @override
  String get lowStockAlerts => 'Low Stock Alerts';

  @override
  String get expiryAlerts => 'Expiry Alerts';

  @override
  String get notifyWhenMedicationRunningLow =>
      'Notify when medication is running low';

  @override
  String get notifyWhenMedicationExpiringSoon =>
      'Notify when medication is expiring soon';

  @override
  String get about => 'About';

  @override
  String get appName => 'App Name';

  @override
  String get version => 'Version';

  @override
  String get buildNumber => 'Build Number';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get ok => 'OK';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sortBy => 'Sort by';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this item? This action cannot be undone.';

  @override
  String get itemDeleted => 'Item deleted successfully';

  @override
  String get itemSaved => 'Item saved successfully';

  @override
  String get noMedications => 'No medications found';

  @override
  String get noReminders => 'No reminders set';

  @override
  String get addYourFirstMedication =>
      'Add your first medication to get started';

  @override
  String get takeNow => 'Take Now';

  @override
  String get snooze => 'Snooze';

  @override
  String get skip => 'Skip';

  @override
  String get taken => 'Taken';

  @override
  String get missed => 'Missed';

  @override
  String timeToTake(String medicationName) {
    return 'Time to take $medicationName';
  }

  @override
  String takeDoseNow(String dose) {
    return 'Take $dose now';
  }

  @override
  String daysOfStockRemaining(int days) {
    return 'Only $days day(s) of stock remaining. Time to refill!';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String get mealTiming => 'Meal Timing';

  @override
  String get anytime => 'Anytime';

  @override
  String get beforeMeal => 'Before Meal';

  @override
  String get withMeal => 'With Meal';

  @override
  String get afterMeal => 'After Meal';

  @override
  String get beforeMealDescription => 'Take 30-60 minutes before eating';

  @override
  String get withMealDescription => 'Take during or immediately after eating';

  @override
  String get afterMealDescription => 'Take 1-2 hours after eating';

  @override
  String get troubleshootNotifications => 'Troubleshoot Notifications';

  @override
  String get notificationDiagnostics => 'Notification Diagnostics';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get sendTestNotification => 'Send Test Notification (Now)';

  @override
  String get scheduleTestNotification => 'Schedule Test (1 Minute)';

  @override
  String get requestPermissions => 'Request Permissions';

  @override
  String get exactAlarmSettings => 'Exact Alarm Settings';

  @override
  String get disableBatteryOptimization => 'Disable Battery Optimization';

  @override
  String get enableExactAlarms => 'Enable Exact Alarms (REQUIRED)';

  @override
  String get notificationSoundSettings => 'Notification Sound Settings';

  @override
  String get setTimezoneManually => 'Set Timezone Manually';

  @override
  String get appNotificationSettings => 'App Notification Settings';

  @override
  String get status => 'Status';

  @override
  String get exactAlarmsPermission => 'Exact Alarms Permission';

  @override
  String get pendingNotifications => 'Pending Notifications';

  @override
  String get timezone => 'Timezone';

  @override
  String get deviceTime => 'Device Time';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get troubleshootingTips => 'Troubleshooting Tips';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsConfirmation =>
      'Are you sure you want to reset all settings to their default values? This action cannot be undone.';

  @override
  String get settingsResetSuccessfully => 'Settings reset to defaults';

  @override
  String get data => 'Data';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get backup => 'Backup';

  @override
  String get restore => 'Restore';

  @override
  String get welcomeTitle => 'Welcome to MedAssist';

  @override
  String get welcomeDescription =>
      'Your personal medication companion that helps you stay on track with your health journey';

  @override
  String get neverMissTitle => 'Never Miss a Dose';

  @override
  String get neverMissDescription =>
      'Smart reminders ensure you take your medications on time, every time';

  @override
  String get trackProgressTitle => 'Track Your Progress';

  @override
  String get trackProgressDescription =>
      'Monitor your adherence, manage stock levels, and view detailed health insights';

  @override
  String get stayHealthyTitle => 'Stay Healthy & Organized';

  @override
  String get stayHealthyDescription =>
      'Keep all your medications organized in one beautiful, easy-to-use app';

  @override
  String get getStarted => 'Get Started';

  @override
  String get step1Of3 => 'Step 1 of 3';

  @override
  String get step2Of3 => 'Step 2 of 3';

  @override
  String get step3Of3 => 'Step 3 of 3';

  @override
  String get basicInformation => 'Basic Information';

  @override
  String get scheduleAndDuration => 'Schedule & Duration';

  @override
  String get stockAndReminder => 'Stock & Reminder';

  @override
  String get selectMedicineType => 'Select medicine type';

  @override
  String get enterBasicDetails =>
      'Enter the basic details about your medication';

  @override
  String get setSchedule => 'Set up your medication schedule';

  @override
  String get configureDosing => 'Configure your dosing frequency';

  @override
  String get manageStock => 'Manage your medication stock';

  @override
  String get setupReminders => 'Set up low stock reminders';

  @override
  String get almostDone => 'Almost done! Just a few more details';

  @override
  String get chooseMedicineType => 'Choose Medicine Type *';

  @override
  String get strengthAndUnit => 'Strength & Unit';

  @override
  String get medicinePhoto => 'Medicine Photo';

  @override
  String get tellUsAboutMedicine => 'Tell us about your medicine';

  @override
  String get readyToContinue => 'Ready to continue to scheduling!';

  @override
  String get pleaseEnterMedicineName => 'Please enter medicine name';

  @override
  String get pleaseSelectMedicineType =>
      'Please select medicine type and enter name';

  @override
  String get next => 'Next';

  @override
  String get optional => 'Optional';

  @override
  String get insights => 'Insights';

  @override
  String get healthInsights => 'Health Insights';

  @override
  String get aiPoweredAnalysis =>
      'AI-powered analysis of your medication adherence';

  @override
  String get yourHealthJourney => 'Your Health Journey';

  @override
  String get weeklyAdherenceSummary => 'Weekly Adherence Summary';

  @override
  String get adherenceTrend => 'Adherence Trend';

  @override
  String get bestMedication => 'Best Medication';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get bestTimeOfDay => 'Best Time of Day';

  @override
  String get motivationalMessage => 'Motivational Message';

  @override
  String get loadingInsights => 'Loading insights...';

  @override
  String get noInsightsYet => 'No insights yet';

  @override
  String get startTrackingMessage =>
      'Start tracking your medications to see personalized health insights';

  @override
  String excellentAdherence(int percent) {
    return 'Excellent! You took $percent% of your doses this week';
  }

  @override
  String goodAdherence(int percent) {
    return 'Good job! You took $percent% of your doses this week';
  }

  @override
  String needsImprovement(int percent) {
    return 'You took $percent% of doses this week. Let\'s improve!';
  }

  @override
  String get keepUpGreatWork =>
      'Keep up the great work! You\'re doing fantastic!';

  @override
  String get consistencyIsKey =>
      'Consistency is key! You\'re making great progress.';

  @override
  String get youCanDoIt =>
      'You can do it! Every dose counts toward better health.';

  @override
  String get stayMotivated => 'Stay motivated! Your health is worth it.';

  @override
  String get diagnostics => 'Diagnostics';

  @override
  String get systemHealth => 'System Health';

  @override
  String get appDiagnostics => 'App diagnostics and troubleshooting';

  @override
  String get systemInformation => 'System Information';

  @override
  String get permissions => 'Permissions';

  @override
  String get database => 'Database';

  @override
  String get testing => 'Testing';

  @override
  String get granted => 'Granted';

  @override
  String get denied => 'Denied';

  @override
  String get unknown => 'Unknown';

  @override
  String get totalMedications => 'Total Medications';

  @override
  String get activeMedications => 'Active Medications';

  @override
  String get totalDoseHistory => 'Total Dose History';

  @override
  String get databaseSize => 'Database Size';

  @override
  String get sendTestNotificationNow => 'Send Test Notification (Now)';

  @override
  String get scheduleTestIn1Min => 'Schedule Test (1 Minute)';

  @override
  String get requestAllPermissions => 'Request All Permissions';

  @override
  String get openNotificationSettings => 'Open Notification Settings';

  @override
  String get testNotificationSent => 'Test notification sent!';

  @override
  String get testScheduled =>
      'Test notification scheduled for 1 minute from now';

  @override
  String get permissionsRequested => 'Permission request sent';

  @override
  String get troubleshootingGuide => 'Troubleshooting Guide';

  @override
  String get notificationsTroubleshoot => 'If notifications aren\'t working:';

  @override
  String get enableNotificationsStep =>
      '1. Enable notifications in app settings';

  @override
  String get grantExactAlarmStep =>
      '2. Grant \'Exact Alarm\' permission (Android 12+)';

  @override
  String get disableBatteryOptStep =>
      '3. Disable battery optimization for this app';

  @override
  String get checkDoNotDisturbStep => '4. Check Do Not Disturb settings';

  @override
  String get reinstallIfNeededStep => '5. Reinstall the app if issues persist';

  @override
  String get searchMedications => 'Search medications...';

  @override
  String get allTypes => 'All Types';

  @override
  String get active => 'Active';

  @override
  String get paused => 'Paused';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get expiring => 'Expiring';

  @override
  String get expired => 'Expired';

  @override
  String get noMedicationsYet => 'No medications yet';

  @override
  String get startByAdding =>
      'Start by adding your first medication\nto keep track of your health';

  @override
  String get noResultsFound => 'No results found';

  @override
  String get tryAdjusting => 'Try adjusting your search or filters';

  @override
  String get deleteMedicationQuestion => 'Delete Medication?';

  @override
  String get deleteMedicationConfirm =>
      'Are you sure you want to delete this medication? This action cannot be undone.';

  @override
  String get medicationDeleted => 'Medication deleted';

  @override
  String errorDeletingMedication(String error) {
    return 'Error deleting medication: $error';
  }

  @override
  String get medicationPaused => 'Medication paused';

  @override
  String get medicationResumed => 'Medication resumed';

  @override
  String get nameAZ => 'Name (A-Z)';

  @override
  String get nameZA => 'Name (Z-A)';

  @override
  String get dateAddedNewest => 'Date Added (Newest)';

  @override
  String get dateAddedOldest => 'Date Added (Oldest)';

  @override
  String get stockLowToHigh => 'Stock (Low to High)';

  @override
  String get stockHighToLow => 'Stock (High to Low)';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String bulkDelete(int count) {
    return 'Delete $count medications?';
  }

  @override
  String bulkPause(int count) {
    return 'Pause $count medications?';
  }

  @override
  String bulkResume(int count) {
    return 'Resume $count medications?';
  }

  @override
  String get medicationNotFound => 'Medication Not Found';

  @override
  String get perDose => 'Per Dose';

  @override
  String get schedule => 'Schedule';

  @override
  String get started => 'Started';

  @override
  String get ends => 'Ends';

  @override
  String get stockStatus => 'Stock Status';

  @override
  String get available => 'Available';

  @override
  String get remaining => 'Remaining';

  @override
  String get history => 'History';

  @override
  String get noDoseHistoryYet => 'No dose history yet';

  @override
  String get noRemindersSet => 'No reminders set';

  @override
  String dose(int number) {
    return 'Dose $number';
  }

  @override
  String get failedToLoad => 'Failed to load medication';

  @override
  String get retry => 'Retry';

  @override
  String get discardChanges => 'Discard Changes?';

  @override
  String get discardChangesConfirm =>
      'Are you sure you want to discard your changes?';

  @override
  String get discard => 'Discard';

  @override
  String get type => 'Type';

  @override
  String get stock => 'Stock';

  @override
  String get back => 'Back';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get medicationUpdated => 'Medication updated successfully!';

  @override
  String get failedToUpdate => 'Failed to update medication';

  @override
  String get analytics => 'Analytics';

  @override
  String get exportData => 'Export Data';

  @override
  String get week => 'Week';

  @override
  String get month => 'Month';

  @override
  String get adherenceRate => 'Adherence Rate';

  @override
  String get takenDoses => 'Taken';

  @override
  String get missedDoses => 'Missed';

  @override
  String get skippedDoses => 'Skipped';

  @override
  String get totalDoses => 'Total';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String daysStreak(int days) {
    return '$days days';
  }

  @override
  String get noMedicationData => 'No medication data yet';

  @override
  String dosesProgress(int taken, int total) {
    return '$taken of $total doses taken';
  }

  @override
  String get bestTimeForAdherence => 'Best Time for Adherence';

  @override
  String get reportsAndExport => 'Reports & Export';

  @override
  String get exportYourData => 'Export your data as CSV or PDF';

  @override
  String get medicationsCSV => 'Medications CSV';

  @override
  String get adherencePDF => 'Adherence PDF';

  @override
  String get dataExported => 'Data exported successfully!';

  @override
  String errorExporting(String error) {
    return 'Error exporting data: $error';
  }

  @override
  String get medicationHistory => 'Medication History';

  @override
  String get goToToday => 'Go to today';

  @override
  String errorLoadingHistory(String error) {
    return 'Error loading history: $error';
  }

  @override
  String get noMedicationHistory => 'No medication history';

  @override
  String get noDosesScheduled => 'No doses were scheduled for this date';

  @override
  String get stockOverview => 'Stock Overview';

  @override
  String get refreshStock => 'Refresh stock';

  @override
  String get stockSummary => 'Stock Summary';

  @override
  String get total => 'Total';

  @override
  String get critical => 'Critical';

  @override
  String get low => 'Low';

  @override
  String get good => 'Good';

  @override
  String errorLoadingStock(String error) {
    return 'Error loading stock: $error';
  }

  @override
  String get addMedicationsToTrack =>
      'Add medications to track their stock levels';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get alwaysHereToHelp => 'Always here to help';

  @override
  String get clearChat => 'Clear Chat';

  @override
  String get aiWelcomeMessage =>
      'Hello! I\'m your medication assistant. I can help you with:\n\n• Medication information\n• Dosage schedules\n• Side effects\n• General health questions\n\nHow can I assist you today?';

  @override
  String get aiErrorMessage =>
      'I apologize, but I\'m having trouble responding right now. Please try again in a moment.';

  @override
  String get chatCleared => 'Chat cleared! How can I help you today?';

  @override
  String get aiThinking => 'AI is thinking...';

  @override
  String get suggestedQuestions => 'Suggested questions:';

  @override
  String get quickTips => 'Quick Tips';

  @override
  String get suggestQuestions => 'Suggest Questions';

  @override
  String get giveMeTips => 'Give me medication tips';

  @override
  String get askAboutMedications => 'Ask about medications...';

  @override
  String get moreOptions => 'More options';

  @override
  String get send => 'Send';

  @override
  String get receiveMedicationReminders => 'Receive medication reminders';

  @override
  String get playSoundForNotifications => 'Play sound for notifications';

  @override
  String get vibrateForNotifications => 'Vibrate for notifications';

  @override
  String get testAndFix => 'Test and fix notification issues';

  @override
  String get notifyWhenLow => 'Notify when medication is running low';

  @override
  String get notifyWhenExpiring => 'Notify when medication is expiring soon';

  @override
  String get restoreAllSettings => 'Restore all settings to default values';

  @override
  String get settingsAutoSaved =>
      'Settings are automatically saved and will be applied immediately';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get alwaysLight => 'Always use light theme';

  @override
  String get alwaysDark => 'Always use dark theme';

  @override
  String get followSystem => 'Follow system theme settings';

  @override
  String get chooseLanguage => 'Choose Language / اختر اللغة';

  @override
  String get resetSettingsConfirm =>
      'Are you sure you want to reset all settings to their default values? This action cannot be undone.';

  @override
  String get settingsReset => 'Settings reset to defaults';

  @override
  String get reset => 'Reset';

  @override
  String get testNotificationMessage =>
      'Test notification sent! Check your notification tray.';

  @override
  String errorMessage(String error) {
    return 'Error: $error';
  }

  @override
  String get notificationScheduled =>
      'Notification scheduled for 1 minute from now! Wait and see if it appears.';

  @override
  String get openingSettings =>
      'Opening settings. Please enable \"Alarms & reminders\" for MedAssist.';

  @override
  String get permissionsGranted =>
      'Permissions granted! If exact alarms still shows NO, tap the red button below.';

  @override
  String get someDenied =>
      'Some permissions denied. Please enable in settings.';

  @override
  String get selectTimezone => 'Select Your Timezone';

  @override
  String get scheduleTest => 'Schedule Test (1 Minute)';

  @override
  String get statusLabel => 'Status';

  @override
  String get criticalExactAlarms =>
      'CRITICAL: Exact Alarms permission is OFF! Scheduled notifications will NOT work. Enable it below.';

  @override
  String get timezoneUTC =>
      'Timezone is UTC! Notifications may not work correctly. Set your timezone below.';

  @override
  String get tip1 =>
      '1. Make sure notifications are enabled in system settings';

  @override
  String get tip2 => '2. Grant \'Exact Alarms\' permission (Android 12+)';

  @override
  String get tip3 => '3. Disable battery optimization for this app';

  @override
  String get tip4 =>
      '4. Check \'Do Not Disturb\' is not blocking notifications';

  @override
  String get tip5 => '5. Ensure the app has background permissions';

  @override
  String get tip6 => '6. Try rebooting your device';

  @override
  String get tip7 =>
      '7. Clear app cache (Settings > Apps > MedAssist > Storage)';

  @override
  String get tip8 => '8. Reinstall the app if issues persist';

  @override
  String get tip9 => '9. Check if timezone is set correctly';

  @override
  String get tip10 => '10. Verify notification sound is not muted';

  @override
  String get addMedicine => 'Add Medicine';

  @override
  String get myMedications => 'My Medications';

  @override
  String get takeDose => 'Take Dose';

  @override
  String get viewStats => 'View Stats';

  @override
  String get askAI => 'Ask AI';

  @override
  String get trendsInsights => 'Trends & Insights';

  @override
  String get medicationInsights => 'Medication Insights';

  @override
  String get chatbotWelcomeMessage =>
      'Hello! I\'m your medication assistant. I can help you with:\n\n• Medication information\n• Dosage schedules\n• Side effects\n• General health questions\n\nHow can I assist you today?';

  @override
  String get chatbotErrorMessage =>
      'I apologize, but I\'m having trouble responding right now. Please try again in a moment.';

  @override
  String get failedToLoadMedication => 'Failed to load medication';

  @override
  String get failedToUpdateMedication => 'Failed to update medication';

  @override
  String get medicationUpdatedSuccessfully =>
      'Medication updated successfully!';

  @override
  String get selectMedications => 'Select medications';

  @override
  String get selectAll => 'Select all';

  @override
  String get selected => 'selected';

  @override
  String get medicationsPaused => 'Medication(s) paused';

  @override
  String get medicationsResumed => 'Medication(s) resumed';

  @override
  String get medicationsDeleted => 'Medication(s) deleted';

  @override
  String get noDosesScheduledForDate => 'No doses were scheduled for this date';

  @override
  String get chatClearedMessage => 'Chat cleared! How can I help you today?';

  @override
  String get giveMeMedicationTips => 'Give me medication tips';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String dosesTakenOf(int taken, int total) {
    return '$taken of $total doses taken';
  }

  @override
  String get errorLoadingStats => 'Error loading stats';

  @override
  String get errorLoadingStreak => 'Error loading streak';

  @override
  String get noMedicationDataYet => 'No medication data yet';

  @override
  String get errorLoadingInsights => 'Error loading insights';

  @override
  String get loading => 'Loading...';

  @override
  String get medicationAdherenceReport => 'Medication Adherence Report';

  @override
  String get dataExportedSuccessfully => 'Data exported successfully!';

  @override
  String get skipped => 'Skipped';

  @override
  String get reportsExport => 'Reports & Export';

  @override
  String get exportYourDataDescription => 'Export your data as CSV or PDF';

  @override
  String get medicationsCsv => 'Medications CSV';

  @override
  String get adherencePdf => 'Adherence PDF';

  @override
  String errorExportingData(Object error) {
    return 'Error exporting data';
  }

  @override
  String get discardChangesConfirmation =>
      'Are you sure you want to discard your changes?';

  @override
  String get error => 'Error';

  @override
  String get aiIsThinking => 'AI is thinking...';

  @override
  String get addMedicationsToTrackStock =>
      'Add medications to track their stock levels';

  @override
  String get notificationsDisabled => 'Notifications disabled';

  @override
  String get turnOnReminders => 'Turn on reminders to never miss a dose';

  @override
  String get enable => 'Enable';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get notificationPermissionRequested =>
      'Notification permission requested';

  @override
  String get howMedAssistWorks => 'How Med Assist Works';

  @override
  String get smartReminders => 'Smart Reminders';

  @override
  String get smartRemindersDescription => 'Get timely alerts even when offline';

  @override
  String get privateData => '100% Private';

  @override
  String get privateDataDescription => 'All data stays on your device';

  @override
  String get flexibleSnoozing => 'Flexible Snoozing';

  @override
  String get flexibleSnoozingDescription =>
      'Snooze reminders when you\'re busy';

  @override
  String get notificationSound => 'Notification Sound';

  @override
  String get selectNotificationSound => 'Select Notification Sound';

  @override
  String get soundDefault => 'Default';

  @override
  String get soundDefaultDescription => 'System default notification sound';

  @override
  String get soundNotification => 'Notification';

  @override
  String get soundNotificationDescription => 'Standard notification tone';

  @override
  String get soundReminder => 'Reminder';

  @override
  String get soundReminderDescription => 'Reminder notification';

  @override
  String get soundAlert => 'Alert';

  @override
  String get soundAlertDescription => 'Alert notification';

  @override
  String get previewSound => 'Preview Sound';

  @override
  String get soundPreview => 'Sound Preview';

  @override
  String get customSound => 'Custom Sound';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get reminderSettings => 'Reminder Settings';

  @override
  String get allSoundsUseSystemDefault =>
      'All sounds use your device\'s notification tone';

  @override
  String get smartSnooze => 'Smart Snooze';

  @override
  String get snoozeOptions => 'Snooze Options';

  @override
  String snoozeRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count snoozes left',
      one: '1 snooze left',
      zero: 'No snoozes left',
    );
    return '$_temp0';
  }

  @override
  String get snoozeLimitReached => 'Snooze limit reached today';

  @override
  String get snoozeLimitMessage =>
      'You\'ve reached the maximum number of snoozes for today. Please take your medication now or skip this dose.';

  @override
  String get maxSnoozesPerDay => 'Max Snoozes Per Day';

  @override
  String get smartSnoozeDescription =>
      'Intelligent snooze suggestions based on your schedule';

  @override
  String get snoozeHistory => 'Snooze History';

  @override
  String get timesSnoozed => 'Times Snoozed';

  @override
  String get averagePerDay => 'Average Per Day';

  @override
  String get snoozeStats => 'Snooze Statistics';

  @override
  String get scanBarcode => 'Scan Barcode';

  @override
  String get scanBarcodeInstructions =>
      'Position the barcode within the frame\nIt will scan automatically';

  @override
  String get medicationNotFoundMessage =>
      'Could not find medication information for this barcode.\n\nWould you like to enter the medication details manually?';

  @override
  String get enterManually => 'Enter Manually';

  @override
  String get errorScanningBarcode =>
      'An error occurred while scanning the barcode';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get backupRestore => 'Backup & Restore';

  @override
  String get backupRestoreSubtitle => 'Save or restore your data';

  @override
  String get backupInfoMessage =>
      'Backup stores all your medications, history, and settings. You can restore it anytime.';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get createBackupDescription =>
      'Export all your data to a file that you can save or share';

  @override
  String get saveToDevice => 'Save to Device';

  @override
  String get share => 'Share';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get restoreDescription =>
      'Import data from a backup file. This will replace all current data.';

  @override
  String get restoreWarning => 'Warning: Current data will be erased';

  @override
  String get selectBackupFile => 'Select Backup File';
}
