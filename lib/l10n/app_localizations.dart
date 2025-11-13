import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'MedAssist'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @editMedication.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get editMedication;

  /// No description provided for @deleteMedication.
  ///
  /// In en, this message translates to:
  /// **'Delete Medication'**
  String get deleteMedication;

  /// No description provided for @medicationDetails.
  ///
  /// In en, this message translates to:
  /// **'Medication Details'**
  String get medicationDetails;

  /// No description provided for @medicineName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get medicineName;

  /// No description provided for @medicineType.
  ///
  /// In en, this message translates to:
  /// **'Medicine Type'**
  String get medicineType;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @frequency.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @tablet.
  ///
  /// In en, this message translates to:
  /// **'Tablet'**
  String get tablet;

  /// No description provided for @capsule.
  ///
  /// In en, this message translates to:
  /// **'Capsule'**
  String get capsule;

  /// No description provided for @syrup.
  ///
  /// In en, this message translates to:
  /// **'Syrup'**
  String get syrup;

  /// No description provided for @injection.
  ///
  /// In en, this message translates to:
  /// **'Injection'**
  String get injection;

  /// No description provided for @drops.
  ///
  /// In en, this message translates to:
  /// **'Drops'**
  String get drops;

  /// No description provided for @inhaler.
  ///
  /// In en, this message translates to:
  /// **'Inhaler'**
  String get inhaler;

  /// No description provided for @cream.
  ///
  /// In en, this message translates to:
  /// **'Cream'**
  String get cream;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @timesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Times Per Day'**
  String get timesPerDay;

  /// No description provided for @dosePerTime.
  ///
  /// In en, this message translates to:
  /// **'Dose Per Time'**
  String get dosePerTime;

  /// No description provided for @durationDays.
  ///
  /// In en, this message translates to:
  /// **'Duration (Days)'**
  String get durationDays;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low stock! Time to refill soon.'**
  String get lowStockAlert;

  /// No description provided for @enableLowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Enable Low Stock Alert'**
  String get enableLowStockAlert;

  /// No description provided for @remindBeforeRunOut.
  ///
  /// In en, this message translates to:
  /// **'Remind Before Run Out'**
  String get remindBeforeRunOut;

  /// No description provided for @daysBeforeRunOut.
  ///
  /// In en, this message translates to:
  /// **'Days Before Run Out'**
  String get daysBeforeRunOut;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @addReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder Time'**
  String get addReminderTime;

  /// No description provided for @editReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder Time'**
  String get editReminderTime;

  /// No description provided for @deleteReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Delete Reminder Time'**
  String get deleteReminderTime;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsEnabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications Enabled'**
  String get notificationsEnabled;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @snoozeDuration.
  ///
  /// In en, this message translates to:
  /// **'Snooze Duration'**
  String get snoozeDuration;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية (Arabic)'**
  String get arabic;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get alerts;

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlerts;

  /// No description provided for @expiryAlerts.
  ///
  /// In en, this message translates to:
  /// **'Expiry Alerts'**
  String get expiryAlerts;

  /// No description provided for @notifyWhenMedicationRunningLow.
  ///
  /// In en, this message translates to:
  /// **'Notify when medication is running low'**
  String get notifyWhenMedicationRunningLow;

  /// No description provided for @notifyWhenMedicationExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Notify when medication is expiring soon'**
  String get notifyWhenMedicationExpiringSoon;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'App Name'**
  String get appName;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @buildNumber.
  ///
  /// In en, this message translates to:
  /// **'Build Number'**
  String get buildNumber;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item? This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted successfully'**
  String get itemDeleted;

  /// No description provided for @itemSaved.
  ///
  /// In en, this message translates to:
  /// **'Item saved successfully'**
  String get itemSaved;

  /// No description provided for @noMedications.
  ///
  /// In en, this message translates to:
  /// **'No medications found'**
  String get noMedications;

  /// No description provided for @noReminders.
  ///
  /// In en, this message translates to:
  /// **'No reminders set'**
  String get noReminders;

  /// No description provided for @addYourFirstMedication.
  ///
  /// In en, this message translates to:
  /// **'Add your first medication to get started'**
  String get addYourFirstMedication;

  /// No description provided for @takeNow.
  ///
  /// In en, this message translates to:
  /// **'Take Now'**
  String get takeNow;

  /// No description provided for @snooze.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snooze;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @timeToTake.
  ///
  /// In en, this message translates to:
  /// **'Time to take {medicationName}'**
  String timeToTake(String medicationName);

  /// No description provided for @takeDoseNow.
  ///
  /// In en, this message translates to:
  /// **'Take {dose} now'**
  String takeDoseNow(String dose);

  /// No description provided for @daysOfStockRemaining.
  ///
  /// In en, this message translates to:
  /// **'Only {days} day(s) of stock remaining. Time to refill!'**
  String daysOfStockRemaining(int days);

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @mealTiming.
  ///
  /// In en, this message translates to:
  /// **'Meal Timing'**
  String get mealTiming;

  /// No description provided for @anytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get anytime;

  /// No description provided for @beforeMeal.
  ///
  /// In en, this message translates to:
  /// **'Before Meal'**
  String get beforeMeal;

  /// No description provided for @withMeal.
  ///
  /// In en, this message translates to:
  /// **'With Meal'**
  String get withMeal;

  /// No description provided for @afterMeal.
  ///
  /// In en, this message translates to:
  /// **'After Meal'**
  String get afterMeal;

  /// No description provided for @beforeMealDescription.
  ///
  /// In en, this message translates to:
  /// **'Take 30-60 minutes before eating'**
  String get beforeMealDescription;

  /// No description provided for @withMealDescription.
  ///
  /// In en, this message translates to:
  /// **'Take during or immediately after eating'**
  String get withMealDescription;

  /// No description provided for @afterMealDescription.
  ///
  /// In en, this message translates to:
  /// **'Take 1-2 hours after eating'**
  String get afterMealDescription;

  /// No description provided for @troubleshootNotifications.
  ///
  /// In en, this message translates to:
  /// **'Troubleshoot Notifications'**
  String get troubleshootNotifications;

  /// No description provided for @notificationDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Notification Diagnostics'**
  String get notificationDiagnostics;

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @sendTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification (Now)'**
  String get sendTestNotification;

  /// No description provided for @scheduleTestNotification.
  ///
  /// In en, this message translates to:
  /// **'Schedule Test (1 Minute)'**
  String get scheduleTestNotification;

  /// No description provided for @requestPermissions.
  ///
  /// In en, this message translates to:
  /// **'Request Permissions'**
  String get requestPermissions;

  /// No description provided for @exactAlarmSettings.
  ///
  /// In en, this message translates to:
  /// **'Exact Alarm Settings'**
  String get exactAlarmSettings;

  /// No description provided for @disableBatteryOptimization.
  ///
  /// In en, this message translates to:
  /// **'Disable Battery Optimization'**
  String get disableBatteryOptimization;

  /// No description provided for @enableExactAlarms.
  ///
  /// In en, this message translates to:
  /// **'Enable Exact Alarms (REQUIRED)'**
  String get enableExactAlarms;

  /// No description provided for @notificationSoundSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound Settings'**
  String get notificationSoundSettings;

  /// No description provided for @setTimezoneManually.
  ///
  /// In en, this message translates to:
  /// **'Set Timezone Manually'**
  String get setTimezoneManually;

  /// No description provided for @appNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'App Notification Settings'**
  String get appNotificationSettings;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @exactAlarmsPermission.
  ///
  /// In en, this message translates to:
  /// **'Exact Alarms Permission'**
  String get exactAlarmsPermission;

  /// No description provided for @pendingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Pending Notifications'**
  String get pendingNotifications;

  /// No description provided for @timezone.
  ///
  /// In en, this message translates to:
  /// **'Timezone'**
  String get timezone;

  /// No description provided for @deviceTime.
  ///
  /// In en, this message translates to:
  /// **'Device Time'**
  String get deviceTime;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @troubleshootingTips.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting Tips'**
  String get troubleshootingTips;

  /// No description provided for @resetToDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// No description provided for @resetSettings.
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// No description provided for @resetSettingsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their default values? This action cannot be undone.'**
  String get resetSettingsConfirmation;

  /// No description provided for @settingsResetSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetSuccessfully;

  /// No description provided for @data.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get data;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MedAssist'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personal medication companion that helps you stay on track with your health journey'**
  String get welcomeDescription;

  /// No description provided for @neverMissTitle.
  ///
  /// In en, this message translates to:
  /// **'Never Miss a Dose'**
  String get neverMissTitle;

  /// No description provided for @neverMissDescription.
  ///
  /// In en, this message translates to:
  /// **'Smart reminders ensure you take your medications on time, every time'**
  String get neverMissDescription;

  /// No description provided for @trackProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Your Progress'**
  String get trackProgressTitle;

  /// No description provided for @trackProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'Monitor your adherence, manage stock levels, and view detailed health insights'**
  String get trackProgressDescription;

  /// No description provided for @stayHealthyTitle.
  ///
  /// In en, this message translates to:
  /// **'Stay Healthy & Organized'**
  String get stayHealthyTitle;

  /// No description provided for @stayHealthyDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep all your medications organized in one beautiful, easy-to-use app'**
  String get stayHealthyDescription;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @step1Of3.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 3'**
  String get step1Of3;

  /// No description provided for @step2Of3.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 3'**
  String get step2Of3;

  /// No description provided for @step3Of3.
  ///
  /// In en, this message translates to:
  /// **'Step 3 of 3'**
  String get step3Of3;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @scheduleAndDuration.
  ///
  /// In en, this message translates to:
  /// **'Schedule & Duration'**
  String get scheduleAndDuration;

  /// No description provided for @stockAndReminder.
  ///
  /// In en, this message translates to:
  /// **'Stock & Reminder'**
  String get stockAndReminder;

  /// No description provided for @selectMedicineType.
  ///
  /// In en, this message translates to:
  /// **'Select medicine type'**
  String get selectMedicineType;

  /// No description provided for @enterBasicDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter the basic details about your medication'**
  String get enterBasicDetails;

  /// No description provided for @setSchedule.
  ///
  /// In en, this message translates to:
  /// **'Set up your medication schedule'**
  String get setSchedule;

  /// No description provided for @configureDosing.
  ///
  /// In en, this message translates to:
  /// **'Configure your dosing frequency'**
  String get configureDosing;

  /// No description provided for @manageStock.
  ///
  /// In en, this message translates to:
  /// **'Manage your medication stock'**
  String get manageStock;

  /// No description provided for @setupReminders.
  ///
  /// In en, this message translates to:
  /// **'Set up low stock reminders'**
  String get setupReminders;

  /// No description provided for @almostDone.
  ///
  /// In en, this message translates to:
  /// **'Almost done! Just a few more details'**
  String get almostDone;

  /// No description provided for @chooseMedicineType.
  ///
  /// In en, this message translates to:
  /// **'Choose Medicine Type *'**
  String get chooseMedicineType;

  /// No description provided for @strengthAndUnit.
  ///
  /// In en, this message translates to:
  /// **'Strength & Unit'**
  String get strengthAndUnit;

  /// No description provided for @medicinePhoto.
  ///
  /// In en, this message translates to:
  /// **'Medicine Photo'**
  String get medicinePhoto;

  /// No description provided for @tellUsAboutMedicine.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your medicine'**
  String get tellUsAboutMedicine;

  /// No description provided for @readyToContinue.
  ///
  /// In en, this message translates to:
  /// **'Ready to continue to scheduling!'**
  String get readyToContinue;

  /// No description provided for @pleaseEnterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Please enter medicine name'**
  String get pleaseEnterMedicineName;

  /// No description provided for @pleaseSelectMedicineType.
  ///
  /// In en, this message translates to:
  /// **'Please select medicine type and enter name'**
  String get pleaseSelectMedicineType;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @healthInsights.
  ///
  /// In en, this message translates to:
  /// **'Health Insights'**
  String get healthInsights;

  /// No description provided for @aiPoweredAnalysis.
  ///
  /// In en, this message translates to:
  /// **'AI-powered analysis of your medication adherence'**
  String get aiPoweredAnalysis;

  /// No description provided for @yourHealthJourney.
  ///
  /// In en, this message translates to:
  /// **'Your Health Journey'**
  String get yourHealthJourney;

  /// No description provided for @weeklyAdherenceSummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Adherence Summary'**
  String get weeklyAdherenceSummary;

  /// No description provided for @adherenceTrend.
  ///
  /// In en, this message translates to:
  /// **'Adherence Trend'**
  String get adherenceTrend;

  /// No description provided for @bestMedication.
  ///
  /// In en, this message translates to:
  /// **'Best Medication'**
  String get bestMedication;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @bestTimeOfDay.
  ///
  /// In en, this message translates to:
  /// **'Best Time of Day'**
  String get bestTimeOfDay;

  /// No description provided for @motivationalMessage.
  ///
  /// In en, this message translates to:
  /// **'Motivational Message'**
  String get motivationalMessage;

  /// No description provided for @loadingInsights.
  ///
  /// In en, this message translates to:
  /// **'Loading insights...'**
  String get loadingInsights;

  /// No description provided for @noInsightsYet.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get noInsightsYet;

  /// No description provided for @startTrackingMessage.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your medications to see personalized health insights'**
  String get startTrackingMessage;

  /// No description provided for @excellentAdherence.
  ///
  /// In en, this message translates to:
  /// **'Excellent! You took {percent}% of your doses this week'**
  String excellentAdherence(int percent);

  /// No description provided for @goodAdherence.
  ///
  /// In en, this message translates to:
  /// **'Good job! You took {percent}% of your doses this week'**
  String goodAdherence(int percent);

  /// No description provided for @needsImprovement.
  ///
  /// In en, this message translates to:
  /// **'You took {percent}% of doses this week. Let\'s improve!'**
  String needsImprovement(int percent);

  /// No description provided for @keepUpGreatWork.
  ///
  /// In en, this message translates to:
  /// **'Keep up the great work! You\'re doing fantastic!'**
  String get keepUpGreatWork;

  /// No description provided for @consistencyIsKey.
  ///
  /// In en, this message translates to:
  /// **'Consistency is key! You\'re making great progress.'**
  String get consistencyIsKey;

  /// No description provided for @youCanDoIt.
  ///
  /// In en, this message translates to:
  /// **'You can do it! Every dose counts toward better health.'**
  String get youCanDoIt;

  /// No description provided for @stayMotivated.
  ///
  /// In en, this message translates to:
  /// **'Stay motivated! Your health is worth it.'**
  String get stayMotivated;

  /// No description provided for @diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get diagnostics;

  /// No description provided for @systemHealth.
  ///
  /// In en, this message translates to:
  /// **'System Health'**
  String get systemHealth;

  /// No description provided for @appDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'App diagnostics and troubleshooting'**
  String get appDiagnostics;

  /// No description provided for @systemInformation.
  ///
  /// In en, this message translates to:
  /// **'System Information'**
  String get systemInformation;

  /// No description provided for @permissions.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissions;

  /// No description provided for @database.
  ///
  /// In en, this message translates to:
  /// **'Database'**
  String get database;

  /// No description provided for @testing.
  ///
  /// In en, this message translates to:
  /// **'Testing'**
  String get testing;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @denied.
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get denied;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @totalMedications.
  ///
  /// In en, this message translates to:
  /// **'Total Medications'**
  String get totalMedications;

  /// No description provided for @activeMedications.
  ///
  /// In en, this message translates to:
  /// **'Active Medications'**
  String get activeMedications;

  /// No description provided for @totalDoseHistory.
  ///
  /// In en, this message translates to:
  /// **'Total Dose History'**
  String get totalDoseHistory;

  /// No description provided for @databaseSize.
  ///
  /// In en, this message translates to:
  /// **'Database Size'**
  String get databaseSize;

  /// No description provided for @sendTestNotificationNow.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification (Now)'**
  String get sendTestNotificationNow;

  /// No description provided for @scheduleTestIn1Min.
  ///
  /// In en, this message translates to:
  /// **'Schedule Test (1 Minute)'**
  String get scheduleTestIn1Min;

  /// No description provided for @requestAllPermissions.
  ///
  /// In en, this message translates to:
  /// **'Request All Permissions'**
  String get requestAllPermissions;

  /// No description provided for @openNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Notification Settings'**
  String get openNotificationSettings;

  /// No description provided for @testNotificationSent.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent!'**
  String get testNotificationSent;

  /// No description provided for @testScheduled.
  ///
  /// In en, this message translates to:
  /// **'Test notification scheduled for 1 minute from now'**
  String get testScheduled;

  /// No description provided for @permissionsRequested.
  ///
  /// In en, this message translates to:
  /// **'Permission request sent'**
  String get permissionsRequested;

  /// No description provided for @troubleshootingGuide.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting Guide'**
  String get troubleshootingGuide;

  /// No description provided for @notificationsTroubleshoot.
  ///
  /// In en, this message translates to:
  /// **'If notifications aren\'t working:'**
  String get notificationsTroubleshoot;

  /// No description provided for @enableNotificationsStep.
  ///
  /// In en, this message translates to:
  /// **'1. Enable notifications in app settings'**
  String get enableNotificationsStep;

  /// No description provided for @grantExactAlarmStep.
  ///
  /// In en, this message translates to:
  /// **'2. Grant \'Exact Alarm\' permission (Android 12+)'**
  String get grantExactAlarmStep;

  /// No description provided for @disableBatteryOptStep.
  ///
  /// In en, this message translates to:
  /// **'3. Disable battery optimization for this app'**
  String get disableBatteryOptStep;

  /// No description provided for @checkDoNotDisturbStep.
  ///
  /// In en, this message translates to:
  /// **'4. Check Do Not Disturb settings'**
  String get checkDoNotDisturbStep;

  /// No description provided for @reinstallIfNeededStep.
  ///
  /// In en, this message translates to:
  /// **'5. Reinstall the app if issues persist'**
  String get reinstallIfNeededStep;

  /// No description provided for @searchMedications.
  ///
  /// In en, this message translates to:
  /// **'Search medications...'**
  String get searchMedications;

  /// No description provided for @allTypes.
  ///
  /// In en, this message translates to:
  /// **'All Types'**
  String get allTypes;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @expiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get expiring;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @noMedicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No medications yet'**
  String get noMedicationsYet;

  /// No description provided for @startByAdding.
  ///
  /// In en, this message translates to:
  /// **'Start by adding your first medication\nto keep track of your health'**
  String get startByAdding;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryAdjusting.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get tryAdjusting;

  /// No description provided for @deleteMedicationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Delete Medication?'**
  String get deleteMedicationQuestion;

  /// No description provided for @deleteMedicationConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this medication? This action cannot be undone.'**
  String get deleteMedicationConfirm;

  /// No description provided for @medicationDeleted.
  ///
  /// In en, this message translates to:
  /// **'Medication deleted'**
  String get medicationDeleted;

  /// No description provided for @errorDeletingMedication.
  ///
  /// In en, this message translates to:
  /// **'Error deleting medication: {error}'**
  String errorDeletingMedication(String error);

  /// No description provided for @medicationPaused.
  ///
  /// In en, this message translates to:
  /// **'Medication paused'**
  String get medicationPaused;

  /// No description provided for @medicationResumed.
  ///
  /// In en, this message translates to:
  /// **'Medication resumed'**
  String get medicationResumed;

  /// No description provided for @nameAZ.
  ///
  /// In en, this message translates to:
  /// **'Name (A-Z)'**
  String get nameAZ;

  /// No description provided for @nameZA.
  ///
  /// In en, this message translates to:
  /// **'Name (Z-A)'**
  String get nameZA;

  /// No description provided for @dateAddedNewest.
  ///
  /// In en, this message translates to:
  /// **'Date Added (Newest)'**
  String get dateAddedNewest;

  /// No description provided for @dateAddedOldest.
  ///
  /// In en, this message translates to:
  /// **'Date Added (Oldest)'**
  String get dateAddedOldest;

  /// No description provided for @stockLowToHigh.
  ///
  /// In en, this message translates to:
  /// **'Stock (Low to High)'**
  String get stockLowToHigh;

  /// No description provided for @stockHighToLow.
  ///
  /// In en, this message translates to:
  /// **'Stock (High to Low)'**
  String get stockHighToLow;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @bulkDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete {count} medications?'**
  String bulkDelete(int count);

  /// No description provided for @bulkPause.
  ///
  /// In en, this message translates to:
  /// **'Pause {count} medications?'**
  String bulkPause(int count);

  /// No description provided for @bulkResume.
  ///
  /// In en, this message translates to:
  /// **'Resume {count} medications?'**
  String bulkResume(int count);

  /// No description provided for @medicationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Medication Not Found'**
  String get medicationNotFound;

  /// No description provided for @perDose.
  ///
  /// In en, this message translates to:
  /// **'Per Dose'**
  String get perDose;

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @ends.
  ///
  /// In en, this message translates to:
  /// **'Ends'**
  String get ends;

  /// No description provided for @stockStatus.
  ///
  /// In en, this message translates to:
  /// **'Stock Status'**
  String get stockStatus;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noDoseHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No dose history yet'**
  String get noDoseHistoryYet;

  /// No description provided for @noRemindersSet.
  ///
  /// In en, this message translates to:
  /// **'No reminders set'**
  String get noRemindersSet;

  /// No description provided for @dose.
  ///
  /// In en, this message translates to:
  /// **'Dose {number}'**
  String dose(int number);

  /// No description provided for @failedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load medication'**
  String get failedToLoad;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes?'**
  String get discardChanges;

  /// No description provided for @discardChangesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard your changes?'**
  String get discardChangesConfirm;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @medicationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Medication updated successfully!'**
  String get medicationUpdated;

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update medication'**
  String get failedToUpdate;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @adherenceRate.
  ///
  /// In en, this message translates to:
  /// **'Adherence Rate'**
  String get adherenceRate;

  /// No description provided for @takenDoses.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get takenDoses;

  /// No description provided for @missedDoses.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missedDoses;

  /// No description provided for @skippedDoses.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skippedDoses;

  /// No description provided for @totalDoses.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalDoses;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// No description provided for @daysStreak.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysStreak(int days);

  /// No description provided for @noMedicationData.
  ///
  /// In en, this message translates to:
  /// **'No medication data yet'**
  String get noMedicationData;

  /// No description provided for @dosesProgress.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} doses taken'**
  String dosesProgress(int taken, int total);

  /// No description provided for @bestTimeForAdherence.
  ///
  /// In en, this message translates to:
  /// **'Best Time for Adherence'**
  String get bestTimeForAdherence;

  /// No description provided for @reportsAndExport.
  ///
  /// In en, this message translates to:
  /// **'Reports & Export'**
  String get reportsAndExport;

  /// No description provided for @exportYourData.
  ///
  /// In en, this message translates to:
  /// **'Export your data as CSV or PDF'**
  String get exportYourData;

  /// No description provided for @medicationsCSV.
  ///
  /// In en, this message translates to:
  /// **'Medications CSV'**
  String get medicationsCSV;

  /// No description provided for @adherencePDF.
  ///
  /// In en, this message translates to:
  /// **'Adherence PDF'**
  String get adherencePDF;

  /// No description provided for @dataExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully!'**
  String get dataExported;

  /// No description provided for @errorExporting.
  ///
  /// In en, this message translates to:
  /// **'Error exporting data: {error}'**
  String errorExporting(String error);

  /// No description provided for @medicationHistory.
  ///
  /// In en, this message translates to:
  /// **'Medication History'**
  String get medicationHistory;

  /// No description provided for @goToToday.
  ///
  /// In en, this message translates to:
  /// **'Go to today'**
  String get goToToday;

  /// No description provided for @errorLoadingHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading history: {error}'**
  String errorLoadingHistory(String error);

  /// No description provided for @noMedicationHistory.
  ///
  /// In en, this message translates to:
  /// **'No medication history'**
  String get noMedicationHistory;

  /// No description provided for @noDosesScheduled.
  ///
  /// In en, this message translates to:
  /// **'No doses were scheduled for this date'**
  String get noDosesScheduled;

  /// No description provided for @stockOverview.
  ///
  /// In en, this message translates to:
  /// **'Stock Overview'**
  String get stockOverview;

  /// No description provided for @refreshStock.
  ///
  /// In en, this message translates to:
  /// **'Refresh stock'**
  String get refreshStock;

  /// No description provided for @stockSummary.
  ///
  /// In en, this message translates to:
  /// **'Stock Summary'**
  String get stockSummary;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @errorLoadingStock.
  ///
  /// In en, this message translates to:
  /// **'Error loading stock: {error}'**
  String errorLoadingStock(String error);

  /// No description provided for @addMedicationsToTrack.
  ///
  /// In en, this message translates to:
  /// **'Add medications to track their stock levels'**
  String get addMedicationsToTrack;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @alwaysHereToHelp.
  ///
  /// In en, this message translates to:
  /// **'Always here to help'**
  String get alwaysHereToHelp;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear Chat'**
  String get clearChat;

  /// No description provided for @aiWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your medication assistant. I can help you with:\n\n• Medication information\n• Dosage schedules\n• Side effects\n• General health questions\n\nHow can I assist you today?'**
  String get aiWelcomeMessage;

  /// No description provided for @aiErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'I apologize, but I\'m having trouble responding right now. Please try again in a moment.'**
  String get aiErrorMessage;

  /// No description provided for @chatCleared.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared! How can I help you today?'**
  String get chatCleared;

  /// No description provided for @aiThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiThinking;

  /// No description provided for @suggestedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Suggested questions:'**
  String get suggestedQuestions;

  /// No description provided for @quickTips.
  ///
  /// In en, this message translates to:
  /// **'Quick Tips'**
  String get quickTips;

  /// No description provided for @suggestQuestions.
  ///
  /// In en, this message translates to:
  /// **'Suggest Questions'**
  String get suggestQuestions;

  /// No description provided for @giveMeTips.
  ///
  /// In en, this message translates to:
  /// **'Give me medication tips'**
  String get giveMeTips;

  /// No description provided for @askAboutMedications.
  ///
  /// In en, this message translates to:
  /// **'Ask about medications...'**
  String get askAboutMedications;

  /// No description provided for @moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get moreOptions;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @receiveMedicationReminders.
  ///
  /// In en, this message translates to:
  /// **'Receive medication reminders'**
  String get receiveMedicationReminders;

  /// No description provided for @playSoundForNotifications.
  ///
  /// In en, this message translates to:
  /// **'Play sound for notifications'**
  String get playSoundForNotifications;

  /// No description provided for @vibrateForNotifications.
  ///
  /// In en, this message translates to:
  /// **'Vibrate for notifications'**
  String get vibrateForNotifications;

  /// No description provided for @testAndFix.
  ///
  /// In en, this message translates to:
  /// **'Test and fix notification issues'**
  String get testAndFix;

  /// No description provided for @notifyWhenLow.
  ///
  /// In en, this message translates to:
  /// **'Notify when medication is running low'**
  String get notifyWhenLow;

  /// No description provided for @notifyWhenExpiring.
  ///
  /// In en, this message translates to:
  /// **'Notify when medication is expiring soon'**
  String get notifyWhenExpiring;

  /// No description provided for @restoreAllSettings.
  ///
  /// In en, this message translates to:
  /// **'Restore all settings to default values'**
  String get restoreAllSettings;

  /// No description provided for @settingsAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings are automatically saved and will be applied immediately'**
  String get settingsAutoSaved;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @alwaysLight.
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get alwaysLight;

  /// No description provided for @alwaysDark.
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get alwaysDark;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow system theme settings'**
  String get followSystem;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language / اختر اللغة'**
  String get chooseLanguage;

  /// No description provided for @resetSettingsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their default values? This action cannot be undone.'**
  String get resetSettingsConfirm;

  /// No description provided for @settingsReset.
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsReset;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @testNotificationMessage.
  ///
  /// In en, this message translates to:
  /// **'Test notification sent! Check your notification tray.'**
  String get testNotificationMessage;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorMessage(String error);

  /// No description provided for @notificationScheduled.
  ///
  /// In en, this message translates to:
  /// **'Notification scheduled for 1 minute from now! Wait and see if it appears.'**
  String get notificationScheduled;

  /// No description provided for @openingSettings.
  ///
  /// In en, this message translates to:
  /// **'Opening settings. Please enable \"Alarms & reminders\" for MedAssist.'**
  String get openingSettings;

  /// No description provided for @permissionsGranted.
  ///
  /// In en, this message translates to:
  /// **'Permissions granted! If exact alarms still shows NO, tap the red button below.'**
  String get permissionsGranted;

  /// No description provided for @someDenied.
  ///
  /// In en, this message translates to:
  /// **'Some permissions denied. Please enable in settings.'**
  String get someDenied;

  /// No description provided for @selectTimezone.
  ///
  /// In en, this message translates to:
  /// **'Select Your Timezone'**
  String get selectTimezone;

  /// No description provided for @scheduleTest.
  ///
  /// In en, this message translates to:
  /// **'Schedule Test (1 Minute)'**
  String get scheduleTest;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @criticalExactAlarms.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL: Exact Alarms permission is OFF! Scheduled notifications will NOT work. Enable it below.'**
  String get criticalExactAlarms;

  /// No description provided for @timezoneUTC.
  ///
  /// In en, this message translates to:
  /// **'Timezone is UTC! Notifications may not work correctly. Set your timezone below.'**
  String get timezoneUTC;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'1. Make sure notifications are enabled in system settings'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'2. Grant \'Exact Alarms\' permission (Android 12+)'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'3. Disable battery optimization for this app'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In en, this message translates to:
  /// **'4. Check \'Do Not Disturb\' is not blocking notifications'**
  String get tip4;

  /// No description provided for @tip5.
  ///
  /// In en, this message translates to:
  /// **'5. Ensure the app has background permissions'**
  String get tip5;

  /// No description provided for @tip6.
  ///
  /// In en, this message translates to:
  /// **'6. Try rebooting your device'**
  String get tip6;

  /// No description provided for @tip7.
  ///
  /// In en, this message translates to:
  /// **'7. Clear app cache (Settings > Apps > MedAssist > Storage)'**
  String get tip7;

  /// No description provided for @tip8.
  ///
  /// In en, this message translates to:
  /// **'8. Reinstall the app if issues persist'**
  String get tip8;

  /// No description provided for @tip9.
  ///
  /// In en, this message translates to:
  /// **'9. Check if timezone is set correctly'**
  String get tip9;

  /// No description provided for @tip10.
  ///
  /// In en, this message translates to:
  /// **'10. Verify notification sound is not muted'**
  String get tip10;

  /// No description provided for @addMedicine.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicine;

  /// No description provided for @myMedications.
  ///
  /// In en, this message translates to:
  /// **'My Medications'**
  String get myMedications;

  /// No description provided for @takeDose.
  ///
  /// In en, this message translates to:
  /// **'Take Dose'**
  String get takeDose;

  /// No description provided for @viewStats.
  ///
  /// In en, this message translates to:
  /// **'View Stats'**
  String get viewStats;

  /// No description provided for @askAI.
  ///
  /// In en, this message translates to:
  /// **'Ask AI'**
  String get askAI;

  /// No description provided for @trendsInsights.
  ///
  /// In en, this message translates to:
  /// **'Trends & Insights'**
  String get trendsInsights;

  /// No description provided for @medicationInsights.
  ///
  /// In en, this message translates to:
  /// **'Medication Insights'**
  String get medicationInsights;

  /// No description provided for @chatbotWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello! I\'m your medication assistant. I can help you with:\n\n• Medication information\n• Dosage schedules\n• Side effects\n• General health questions\n\nHow can I assist you today?'**
  String get chatbotWelcomeMessage;

  /// No description provided for @chatbotErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'I apologize, but I\'m having trouble responding right now. Please try again in a moment.'**
  String get chatbotErrorMessage;

  /// No description provided for @failedToLoadMedication.
  ///
  /// In en, this message translates to:
  /// **'Failed to load medication'**
  String get failedToLoadMedication;

  /// No description provided for @failedToUpdateMedication.
  ///
  /// In en, this message translates to:
  /// **'Failed to update medication'**
  String get failedToUpdateMedication;

  /// No description provided for @medicationUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Medication updated successfully!'**
  String get medicationUpdatedSuccessfully;

  /// No description provided for @selectMedications.
  ///
  /// In en, this message translates to:
  /// **'Select medications'**
  String get selectMedications;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @medicationsPaused.
  ///
  /// In en, this message translates to:
  /// **'Medication(s) paused'**
  String get medicationsPaused;

  /// No description provided for @medicationsResumed.
  ///
  /// In en, this message translates to:
  /// **'Medication(s) resumed'**
  String get medicationsResumed;

  /// No description provided for @medicationsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Medication(s) deleted'**
  String get medicationsDeleted;

  /// No description provided for @noDosesScheduledForDate.
  ///
  /// In en, this message translates to:
  /// **'No doses were scheduled for this date'**
  String get noDosesScheduledForDate;

  /// No description provided for @chatClearedMessage.
  ///
  /// In en, this message translates to:
  /// **'Chat cleared! How can I help you today?'**
  String get chatClearedMessage;

  /// No description provided for @giveMeMedicationTips.
  ///
  /// In en, this message translates to:
  /// **'Give me medication tips'**
  String get giveMeMedicationTips;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @dosesTakenOf.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {total} doses taken'**
  String dosesTakenOf(int taken, int total);

  /// No description provided for @errorLoadingStats.
  ///
  /// In en, this message translates to:
  /// **'Error loading stats'**
  String get errorLoadingStats;

  /// No description provided for @errorLoadingStreak.
  ///
  /// In en, this message translates to:
  /// **'Error loading streak'**
  String get errorLoadingStreak;

  /// No description provided for @noMedicationDataYet.
  ///
  /// In en, this message translates to:
  /// **'No medication data yet'**
  String get noMedicationDataYet;

  /// No description provided for @errorLoadingInsights.
  ///
  /// In en, this message translates to:
  /// **'Error loading insights'**
  String get errorLoadingInsights;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @medicationAdherenceReport.
  ///
  /// In en, this message translates to:
  /// **'Medication Adherence Report'**
  String get medicationAdherenceReport;

  /// No description provided for @dataExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully!'**
  String get dataExportedSuccessfully;

  /// No description provided for @skipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// No description provided for @reportsExport.
  ///
  /// In en, this message translates to:
  /// **'Reports & Export'**
  String get reportsExport;

  /// No description provided for @exportYourDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Export your data as CSV or PDF'**
  String get exportYourDataDescription;

  /// No description provided for @medicationsCsv.
  ///
  /// In en, this message translates to:
  /// **'Medications CSV'**
  String get medicationsCsv;

  /// No description provided for @adherencePdf.
  ///
  /// In en, this message translates to:
  /// **'Adherence PDF'**
  String get adherencePdf;

  /// No description provided for @errorExportingData.
  ///
  /// In en, this message translates to:
  /// **'Error exporting data'**
  String errorExportingData(Object error);

  /// No description provided for @discardChangesConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard your changes?'**
  String get discardChangesConfirmation;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @aiIsThinking.
  ///
  /// In en, this message translates to:
  /// **'AI is thinking...'**
  String get aiIsThinking;

  /// No description provided for @addMedicationsToTrackStock.
  ///
  /// In en, this message translates to:
  /// **'Add medications to track their stock levels'**
  String get addMedicationsToTrackStock;

  /// No description provided for @notificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get notificationsDisabled;

  /// No description provided for @turnOnReminders.
  ///
  /// In en, this message translates to:
  /// **'Turn on reminders to never miss a dose'**
  String get turnOnReminders;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @notificationPermissionRequested.
  ///
  /// In en, this message translates to:
  /// **'Notification permission requested'**
  String get notificationPermissionRequested;

  /// No description provided for @howMedAssistWorks.
  ///
  /// In en, this message translates to:
  /// **'How Med Assist Works'**
  String get howMedAssistWorks;

  /// No description provided for @smartReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get smartReminders;

  /// No description provided for @smartRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Get timely alerts even when offline'**
  String get smartRemindersDescription;

  /// No description provided for @privateData.
  ///
  /// In en, this message translates to:
  /// **'100% Private'**
  String get privateData;

  /// No description provided for @privateDataDescription.
  ///
  /// In en, this message translates to:
  /// **'All data stays on your device'**
  String get privateDataDescription;

  /// No description provided for @flexibleSnoozing.
  ///
  /// In en, this message translates to:
  /// **'Flexible Snoozing'**
  String get flexibleSnoozing;

  /// No description provided for @flexibleSnoozingDescription.
  ///
  /// In en, this message translates to:
  /// **'Snooze reminders when you\'re busy'**
  String get flexibleSnoozingDescription;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @selectNotificationSound.
  ///
  /// In en, this message translates to:
  /// **'Select Notification Sound'**
  String get selectNotificationSound;

  /// No description provided for @soundDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get soundDefault;

  /// No description provided for @soundDefaultDescription.
  ///
  /// In en, this message translates to:
  /// **'System default notification sound'**
  String get soundDefaultDescription;

  /// No description provided for @soundNotification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get soundNotification;

  /// No description provided for @soundNotificationDescription.
  ///
  /// In en, this message translates to:
  /// **'Standard notification tone'**
  String get soundNotificationDescription;

  /// No description provided for @soundReminder.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get soundReminder;

  /// No description provided for @soundReminderDescription.
  ///
  /// In en, this message translates to:
  /// **'Reminder notification'**
  String get soundReminderDescription;

  /// No description provided for @soundAlert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get soundAlert;

  /// No description provided for @soundAlertDescription.
  ///
  /// In en, this message translates to:
  /// **'Alert notification'**
  String get soundAlertDescription;

  /// No description provided for @previewSound.
  ///
  /// In en, this message translates to:
  /// **'Preview Sound'**
  String get previewSound;

  /// No description provided for @soundPreview.
  ///
  /// In en, this message translates to:
  /// **'Sound Preview'**
  String get soundPreview;

  /// No description provided for @customSound.
  ///
  /// In en, this message translates to:
  /// **'Custom Sound'**
  String get customSound;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettings;

  /// No description provided for @allSoundsUseSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'All sounds use your device\'s notification tone'**
  String get allSoundsUseSystemDefault;

  /// No description provided for @smartSnooze.
  ///
  /// In en, this message translates to:
  /// **'Smart Snooze'**
  String get smartSnooze;

  /// No description provided for @snoozeOptions.
  ///
  /// In en, this message translates to:
  /// **'Snooze Options'**
  String get snoozeOptions;

  /// No description provided for @snoozeRemaining.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No snoozes left} =1{1 snooze left} other{{count} snoozes left}}'**
  String snoozeRemaining(int count);

  /// No description provided for @snoozeLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Snooze limit reached today'**
  String get snoozeLimitReached;

  /// No description provided for @snoozeLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the maximum number of snoozes for today. Please take your medication now or skip this dose.'**
  String get snoozeLimitMessage;

  /// No description provided for @maxSnoozesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max Snoozes Per Day'**
  String get maxSnoozesPerDay;

  /// No description provided for @smartSnoozeDescription.
  ///
  /// In en, this message translates to:
  /// **'Intelligent snooze suggestions based on your schedule'**
  String get smartSnoozeDescription;

  /// No description provided for @snoozeHistory.
  ///
  /// In en, this message translates to:
  /// **'Snooze History'**
  String get snoozeHistory;

  /// No description provided for @timesSnoozed.
  ///
  /// In en, this message translates to:
  /// **'Times Snoozed'**
  String get timesSnoozed;

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average Per Day'**
  String get averagePerDay;

  /// No description provided for @snoozeStats.
  ///
  /// In en, this message translates to:
  /// **'Snooze Statistics'**
  String get snoozeStats;

  /// No description provided for @scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// No description provided for @scanBarcodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Position the barcode within the frame\nIt will scan automatically'**
  String get scanBarcodeInstructions;

  /// No description provided for @medicationNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not find medication information for this barcode.\n\nWould you like to enter the medication details manually?'**
  String get medicationNotFoundMessage;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get enterManually;

  /// No description provided for @errorScanningBarcode.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while scanning the barcode'**
  String get errorScanningBarcode;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @backupRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupRestore;

  /// No description provided for @backupRestoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save or restore your data'**
  String get backupRestoreSubtitle;

  /// No description provided for @backupInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Backup stores all your medications, history, and settings. You can restore it anytime.'**
  String get backupInfoMessage;

  /// No description provided for @createBackup.
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// No description provided for @createBackupDescription.
  ///
  /// In en, this message translates to:
  /// **'Export all your data to a file that you can save or share'**
  String get createBackupDescription;

  /// No description provided for @saveToDevice.
  ///
  /// In en, this message translates to:
  /// **'Save to Device'**
  String get saveToDevice;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @restoreFromBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromBackup;

  /// No description provided for @restoreDescription.
  ///
  /// In en, this message translates to:
  /// **'Import data from a backup file. This will replace all current data.'**
  String get restoreDescription;

  /// No description provided for @restoreWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Current data will be erased'**
  String get restoreWarning;

  /// No description provided for @selectBackupFile.
  ///
  /// In en, this message translates to:
  /// **'Select Backup File'**
  String get selectBackupFile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
