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

  /// No description provided for @savingMedicine.
  ///
  /// In en, this message translates to:
  /// **'Saving medication...'**
  String get savingMedicine;

  /// No description provided for @drugInfoRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh drug information'**
  String get drugInfoRefresh;

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

  /// No description provided for @pill.
  ///
  /// In en, this message translates to:
  /// **'Pill'**
  String get pill;

  /// No description provided for @suppository.
  ///
  /// In en, this message translates to:
  /// **'Suppository'**
  String get suppository;

  /// No description provided for @ivSolution.
  ///
  /// In en, this message translates to:
  /// **'IV Solution'**
  String get ivSolution;

  /// No description provided for @medTypePillDesc.
  ///
  /// In en, this message translates to:
  /// **'Tablet or capsule'**
  String get medTypePillDesc;

  /// No description provided for @medTypeInjectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Injectable medicine'**
  String get medTypeInjectionDesc;

  /// No description provided for @medTypeSuppositoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Rectal or vaginal'**
  String get medTypeSuppositoryDesc;

  /// No description provided for @medTypeIvSolutionDesc.
  ///
  /// In en, this message translates to:
  /// **'Intravenous drip'**
  String get medTypeIvSolutionDesc;

  /// No description provided for @medTypeSyrupDesc.
  ///
  /// In en, this message translates to:
  /// **'Liquid medicine'**
  String get medTypeSyrupDesc;

  /// No description provided for @medTypeDropsDesc.
  ///
  /// In en, this message translates to:
  /// **'Eye or ear drops'**
  String get medTypeDropsDesc;

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
  /// **'Got It'**
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

  /// Popup action label for selecting a custom analytics date range
  ///
  /// In en, this message translates to:
  /// **'Custom Date Range'**
  String get customDateRange;

  /// Popup action label for exporting analytics report as PDF
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

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
  /// **'Total Doses'**
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
  /// **'{taken} of {total} doses'**
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

  /// No description provided for @soundPickFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Pick from device…'**
  String get soundPickFromDevice;

  /// No description provided for @soundPickFromDeviceHint.
  ///
  /// In en, this message translates to:
  /// **'Choose a ringtone from your phone'**
  String get soundPickFromDeviceHint;

  /// No description provided for @soundTapToChange.
  ///
  /// In en, this message translates to:
  /// **'Tap to change'**
  String get soundTapToChange;

  /// No description provided for @soundPickerHint.
  ///
  /// In en, this message translates to:
  /// **'Tap Default for system tone, or pick a ringtone from your device'**
  String get soundPickerHint;

  /// No description provided for @soundPreviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Preview unavailable for this sound'**
  String get soundPreviewUnavailable;

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
  /// **'Error scanning barcode: {error}'**
  String errorScanningBarcode(String error);

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

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStock;

  /// No description provided for @currentStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Stock:'**
  String get currentStockLabel;

  /// No description provided for @newStockAmount.
  ///
  /// In en, this message translates to:
  /// **'New Stock Amount'**
  String get newStockAmount;

  /// No description provided for @enterUpdatedStockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter the updated stock quantity'**
  String get enterUpdatedStockQuantity;

  /// No description provided for @quickAdjustments.
  ///
  /// In en, this message translates to:
  /// **'Quick Adjustments:'**
  String get quickAdjustments;

  /// No description provided for @pleaseEnterValidStock.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid stock amount'**
  String get pleaseEnterValidStock;

  /// No description provided for @stockUpdatedTo.
  ///
  /// In en, this message translates to:
  /// **'Stock updated to {quantity} {unit}'**
  String stockUpdatedTo(int quantity, String unit);

  /// No description provided for @errorUpdatingStock.
  ///
  /// In en, this message translates to:
  /// **'Error updating stock: {error}'**
  String errorUpdatingStock(String error);

  /// No description provided for @daysRemainingLabel.
  ///
  /// In en, this message translates to:
  /// **'Days Remaining'**
  String get daysRemainingLabel;

  /// No description provided for @stockLevelCritical.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL'**
  String get stockLevelCritical;

  /// No description provided for @stockLevelLow.
  ///
  /// In en, this message translates to:
  /// **'LOW'**
  String get stockLevelLow;

  /// No description provided for @stockLevelMedium.
  ///
  /// In en, this message translates to:
  /// **'MEDIUM'**
  String get stockLevelMedium;

  /// No description provided for @stockLevelGood.
  ///
  /// In en, this message translates to:
  /// **'GOOD'**
  String get stockLevelGood;

  /// No description provided for @stockWarningCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical stock level! Refill immediately.'**
  String get stockWarningCritical;

  /// No description provided for @stockWarningLow.
  ///
  /// In en, this message translates to:
  /// **'Low stock level. Consider refilling soon.'**
  String get stockWarningLow;

  /// No description provided for @expiryDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDateLabel;

  /// No description provided for @expiryStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get expiryStatusGood;

  /// No description provided for @expiryStatusToday.
  ///
  /// In en, this message translates to:
  /// **'Expires today'**
  String get expiryStatusToday;

  /// No description provided for @expiryStatusTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Expires tomorrow'**
  String get expiryStatusTomorrow;

  /// No description provided for @expiryStatusInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String expiryStatusInDays(int days);

  /// No description provided for @medicationExpiredWarning.
  ///
  /// In en, this message translates to:
  /// **'This medication has expired! Do not use.'**
  String get medicationExpiredWarning;

  /// No description provided for @medicationExpiringSoonWarning.
  ///
  /// In en, this message translates to:
  /// **'This medication is expiring soon ({days} days).'**
  String medicationExpiringSoonWarning(int days);

  /// No description provided for @generatingPdfReport.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF report...'**
  String get generatingPdfReport;

  /// No description provided for @pdfReportGenerated.
  ///
  /// In en, this message translates to:
  /// **'PDF report generated successfully!'**
  String get pdfReportGenerated;

  /// No description provided for @errorGeneratingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF: {error}'**
  String errorGeneratingPdf(String error);

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last Backup'**
  String get lastBackup;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @backupCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Backup created successfully!'**
  String get backupCreatedSuccessfully;

  /// No description provided for @failedToCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Failed to create backup: {error}'**
  String failedToCreateBackup(String error);

  /// No description provided for @failedToShareBackup.
  ///
  /// In en, this message translates to:
  /// **'Failed to share backup: {error}'**
  String failedToShareBackup(String error);

  /// No description provided for @restoreFromBackupQuestion.
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup?'**
  String get restoreFromBackupQuestion;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will erase all current data and replace it with data from the backup file.\n\nThis action cannot be undone. Are you sure?'**
  String get restoreConfirmMessage;

  /// No description provided for @restoreComplete.
  ///
  /// In en, this message translates to:
  /// **'Restore Complete!'**
  String get restoreComplete;

  /// No description provided for @successfullyRestoredItems.
  ///
  /// In en, this message translates to:
  /// **'Successfully restored {count} items:'**
  String successfullyRestoredItems(int count);

  /// No description provided for @failedToRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore backup: {error}'**
  String failedToRestoreBackup(String error);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @takenSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Taken successfully'**
  String get takenSuccessfully;

  /// No description provided for @missedDoseLabel.
  ///
  /// In en, this message translates to:
  /// **'Missed dose'**
  String get missedDoseLabel;

  /// No description provided for @logNow.
  ///
  /// In en, this message translates to:
  /// **'Log Now'**
  String get logNow;

  /// No description provided for @snoozedForMinutes.
  ///
  /// In en, this message translates to:
  /// **'Snoozed for 15 minutes'**
  String get snoozedForMinutes;

  /// No description provided for @adherenceTrendChart.
  ///
  /// In en, this message translates to:
  /// **'7-Day Adherence Trend'**
  String get adherenceTrendChart;

  /// No description provided for @adherenceByMedication.
  ///
  /// In en, this message translates to:
  /// **'Adherence by Medication'**
  String get adherenceByMedication;

  /// No description provided for @doseStatusDistribution.
  ///
  /// In en, this message translates to:
  /// **'Dose Status Distribution (This Month)'**
  String get doseStatusDistribution;

  /// No description provided for @adherenceHeatmap30Day.
  ///
  /// In en, this message translates to:
  /// **'30-Day Adherence Heatmap'**
  String get adherenceHeatmap30Day;

  /// No description provided for @timeOfDayAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Time-of-Day Analysis'**
  String get timeOfDayAnalysis;

  /// No description provided for @adherenceRateByHour.
  ///
  /// In en, this message translates to:
  /// **'Adherence rate by hour of day'**
  String get adherenceRateByHour;

  /// No description provided for @noMedicationDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No medication data available'**
  String get noMedicationDataAvailable;

  /// No description provided for @noTrendDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No trend data available yet'**
  String get noTrendDataAvailable;

  /// No description provided for @noDoseDataForTimeAnalysis.
  ///
  /// In en, this message translates to:
  /// **'No dose data available for time analysis'**
  String get noDoseDataForTimeAnalysis;

  /// No description provided for @errorLoadingTrend.
  ///
  /// In en, this message translates to:
  /// **'Error loading trend: {error}'**
  String errorLoadingTrend(String error);

  /// No description provided for @errorLoadingHeatmap.
  ///
  /// In en, this message translates to:
  /// **'Error loading heatmap: {error}'**
  String errorLoadingHeatmap(String error);

  /// No description provided for @errorLoadingChart.
  ///
  /// In en, this message translates to:
  /// **'Error loading chart: {error}'**
  String errorLoadingChart(String error);

  /// No description provided for @lessLabel.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get lessLabel;

  /// No description provided for @moreLabel.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreLabel;

  /// No description provided for @insightsLabel.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsLabel;

  /// No description provided for @bestTimeInsight.
  ///
  /// In en, this message translates to:
  /// **'Best time: {time} ({percent}% adherence)'**
  String bestTimeInsight(String time, String percent);

  /// No description provided for @needsAttentionInsight.
  ///
  /// In en, this message translates to:
  /// **'Needs attention: {time} ({percent}% adherence)'**
  String needsAttentionInsight(String time, String percent);

  /// No description provided for @noDoseDataThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No dose data for this month'**
  String get noDoseDataThisMonth;

  /// No description provided for @splashGreeting.
  ///
  /// In en, this message translates to:
  /// **'Say hi to your'**
  String get splashGreeting;

  /// No description provided for @splashAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Medical Assistant'**
  String get splashAiTitle;

  /// No description provided for @poweredByAi.
  ///
  /// In en, this message translates to:
  /// **'Powered by AI'**
  String get poweredByAi;

  /// No description provided for @dosesLabel.
  ///
  /// In en, this message translates to:
  /// **'{taken}/{total} doses'**
  String dosesLabel(int taken, int total);

  /// No description provided for @drugInteractionDetected.
  ///
  /// In en, this message translates to:
  /// **'Drug Interaction Detected'**
  String get drugInteractionDetected;

  /// No description provided for @drugInteractionsDetected.
  ///
  /// In en, this message translates to:
  /// **'{count} Drug Interactions Detected'**
  String drugInteractionsDetected(int count);

  /// No description provided for @tapToViewDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap to view details'**
  String get tapToViewDetails;

  /// No description provided for @drugInteractions.
  ///
  /// In en, this message translates to:
  /// **'Drug Interactions'**
  String get drugInteractions;

  /// No description provided for @viewMedications.
  ///
  /// In en, this message translates to:
  /// **'View Medications'**
  String get viewMedications;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get viewAnalytics;

  /// No description provided for @insightsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} insights'**
  String insightsCount(int count);

  /// No description provided for @errorLoadingInsightsMessage.
  ///
  /// In en, this message translates to:
  /// **'Error loading insights'**
  String get errorLoadingInsightsMessage;

  /// No description provided for @noInsightsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'No insights yet'**
  String get noInsightsYetMessage;

  /// No description provided for @startTakingMedsForInsights.
  ///
  /// In en, this message translates to:
  /// **'Start taking your medications to generate personalized health insights'**
  String get startTakingMedsForInsights;

  /// No description provided for @wantMoreInsights.
  ///
  /// In en, this message translates to:
  /// **'Want more insights?'**
  String get wantMoreInsights;

  /// No description provided for @viewAnalyticsDescription.
  ///
  /// In en, this message translates to:
  /// **'View your detailed analytics dashboard for comprehensive charts, trends, and statistics.'**
  String get viewAnalyticsDescription;

  /// No description provided for @chatSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'How do I add my first medication?'**
  String get chatSuggestion1;

  /// No description provided for @chatSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'What should I know about my medications?'**
  String get chatSuggestion2;

  /// No description provided for @chatSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Help me understand adherence'**
  String get chatSuggestion3;

  /// No description provided for @onlyDosesLeft.
  ///
  /// In en, this message translates to:
  /// **'Only {count} doses left'**
  String onlyDosesLeft(int count);

  /// No description provided for @addMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine'**
  String get addMedicineTitle;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save Draft'**
  String get saveDraft;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @medicineAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Medicine added successfully!'**
  String get medicineAddedSuccess;

  /// No description provided for @failedToSaveMedicine.
  ///
  /// In en, this message translates to:
  /// **'Failed to save medicine. Please try again.'**
  String get failedToSaveMedicine;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved!'**
  String get draftSaved;

  /// No description provided for @duplicateMedicineTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine already exists'**
  String get duplicateMedicineTitle;

  /// No description provided for @duplicateMedicineMessage.
  ///
  /// In en, this message translates to:
  /// **'A medicine with the same name, strength, and unit already exists. Would you like to edit the existing one instead?'**
  String get duplicateMedicineMessage;

  /// No description provided for @editExistingMedicine.
  ///
  /// In en, this message translates to:
  /// **'Edit existing'**
  String get editExistingMedicine;

  /// No description provided for @showMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get showMore;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get showLess;

  /// No description provided for @highFrequencyWarning.
  ///
  /// In en, this message translates to:
  /// **'High frequency. Double-check with your doctor.'**
  String get highFrequencyWarning;

  /// No description provided for @highDosePerTimeWarning.
  ///
  /// In en, this message translates to:
  /// **'High dose per intake. Verify this is correct.'**
  String get highDosePerTimeWarning;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @snoozeReminder.
  ///
  /// In en, this message translates to:
  /// **'Snooze Reminder'**
  String get snoozeReminder;

  /// No description provided for @howLongSnooze.
  ///
  /// In en, this message translates to:
  /// **'How long would you like to snooze?'**
  String get howLongSnooze;

  /// No description provided for @fiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes'**
  String get fiveMinutes;

  /// No description provided for @tenMinutes.
  ///
  /// In en, this message translates to:
  /// **'10 minutes'**
  String get tenMinutes;

  /// No description provided for @fifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes'**
  String get fifteenMinutes;

  /// No description provided for @thirtyMinutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes'**
  String get thirtyMinutes;

  /// No description provided for @oneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get oneHour;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select Date Range'**
  String get selectDateRange;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @partial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// No description provided for @last3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get last3Months;

  /// No description provided for @thisYear.
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @daysSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} days selected'**
  String daysSelected(int count);

  /// No description provided for @reportsAndExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & Export'**
  String get reportsAndExportTitle;

  /// No description provided for @exportYourDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Your Data'**
  String get exportYourDataTitle;

  /// No description provided for @exportYourDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate reports and export your medication data in various formats'**
  String get exportYourDataSubtitle;

  /// No description provided for @csvExports.
  ///
  /// In en, this message translates to:
  /// **'CSV Exports'**
  String get csvExports;

  /// No description provided for @pdfReports.
  ///
  /// In en, this message translates to:
  /// **'PDF Reports'**
  String get pdfReports;

  /// No description provided for @medicationsList.
  ///
  /// In en, this message translates to:
  /// **'Medications List'**
  String get medicationsList;

  /// No description provided for @exportAllMedicationsCSV.
  ///
  /// In en, this message translates to:
  /// **'Export all medications data to CSV'**
  String get exportAllMedicationsCSV;

  /// No description provided for @doseHistory.
  ///
  /// In en, this message translates to:
  /// **'Dose History'**
  String get doseHistory;

  /// No description provided for @exportDoseHistoryCSV.
  ///
  /// In en, this message translates to:
  /// **'Export complete dose history to CSV'**
  String get exportDoseHistoryCSV;

  /// No description provided for @stockHistory.
  ///
  /// In en, this message translates to:
  /// **'Stock History'**
  String get stockHistory;

  /// No description provided for @exportStockHistoryCSV.
  ///
  /// In en, this message translates to:
  /// **'Export stock changes history to CSV'**
  String get exportStockHistoryCSV;

  /// No description provided for @medicationsReport.
  ///
  /// In en, this message translates to:
  /// **'Medications Report'**
  String get medicationsReport;

  /// No description provided for @generateMedicationsPDF.
  ///
  /// In en, this message translates to:
  /// **'Generate detailed PDF report of all medications'**
  String get generateMedicationsPDF;

  /// No description provided for @adherenceReport.
  ///
  /// In en, this message translates to:
  /// **'Adherence Report'**
  String get adherenceReport;

  /// No description provided for @generateAdherencePDF.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF report with adherence statistics'**
  String get generateAdherencePDF;

  /// No description provided for @exportInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'Exported files will be saved to your device and can be shared immediately'**
  String get exportInfoMessage;

  /// No description provided for @generatingExport.
  ///
  /// In en, this message translates to:
  /// **'Generating export...'**
  String get generatingExport;

  /// No description provided for @exportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{type} exported successfully!'**
  String exportedSuccessfully(String type);

  /// No description provided for @failedToExport.
  ///
  /// In en, this message translates to:
  /// **'Failed to export: {error}'**
  String failedToExport(String error);

  /// No description provided for @failedToGeneratePdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF: {error}'**
  String failedToGeneratePdf(String error);

  /// No description provided for @pdfGeneratedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{type} report generated successfully!'**
  String pdfGeneratedSuccessfully(String type);

  /// No description provided for @systemStatus.
  ///
  /// In en, this message translates to:
  /// **'System Status'**
  String get systemStatus;

  /// No description provided for @notificationPermission.
  ///
  /// In en, this message translates to:
  /// **'Notification Permission'**
  String get notificationPermission;

  /// No description provided for @requiredForReminders.
  ///
  /// In en, this message translates to:
  /// **'Required for medication reminders'**
  String get requiredForReminders;

  /// No description provided for @exactAlarms.
  ///
  /// In en, this message translates to:
  /// **'Exact Alarms Permission'**
  String get exactAlarms;

  /// No description provided for @requiredForPreciseTiming.
  ///
  /// In en, this message translates to:
  /// **'Required for precise reminder timing on Android 12+'**
  String get requiredForPreciseTiming;

  /// No description provided for @databaseStatistics.
  ///
  /// In en, this message translates to:
  /// **'Database Statistics'**
  String get databaseStatistics;

  /// No description provided for @deviceInformation.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get deviceInformation;

  /// No description provided for @pluginVersion.
  ///
  /// In en, this message translates to:
  /// **'Plugin Version'**
  String get pluginVersion;

  /// No description provided for @testingAndActions.
  ///
  /// In en, this message translates to:
  /// **'Testing & Actions'**
  String get testingAndActions;

  /// No description provided for @sendTestNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Send Test Notification'**
  String get sendTestNotificationTitle;

  /// No description provided for @testIfNotificationsWork.
  ///
  /// In en, this message translates to:
  /// **'Test if notifications are working'**
  String get testIfNotificationsWork;

  /// No description provided for @scheduleTest1Min.
  ///
  /// In en, this message translates to:
  /// **'Schedule Test (1 min)'**
  String get scheduleTest1Min;

  /// No description provided for @scheduleTestDescription.
  ///
  /// In en, this message translates to:
  /// **'Schedule a test notification for 1 minute from now'**
  String get scheduleTestDescription;

  /// No description provided for @requestPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Permissions'**
  String get requestPermissionsTitle;

  /// No description provided for @requestPermissionsDescription.
  ///
  /// In en, this message translates to:
  /// **'Request all necessary permissions'**
  String get requestPermissionsDescription;

  /// No description provided for @troubleshooting.
  ///
  /// In en, this message translates to:
  /// **'Troubleshooting'**
  String get troubleshooting;

  /// No description provided for @notificationsNotAppearing.
  ///
  /// In en, this message translates to:
  /// **'Notifications not appearing?'**
  String get notificationsNotAppearing;

  /// No description provided for @notificationsNotAppearingTips.
  ///
  /// In en, this message translates to:
  /// **'• Check permissions above\n• Disable battery optimization\n• Enable exact alarms (Android 12+)\n• Test with \"Send Test Notification\"'**
  String get notificationsNotAppearingTips;

  /// No description provided for @appCrashing.
  ///
  /// In en, this message translates to:
  /// **'App crashing?'**
  String get appCrashing;

  /// No description provided for @appCrashingTips.
  ///
  /// In en, this message translates to:
  /// **'• Clear app data and restart\n• Ensure all permissions are granted\n• Check device timezone settings'**
  String get appCrashingTips;

  /// No description provided for @advancedDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Advanced Diagnostics'**
  String get advancedDiagnostics;

  /// No description provided for @ok_status.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok_status;

  /// No description provided for @needed_status.
  ///
  /// In en, this message translates to:
  /// **'NEEDED'**
  String get needed_status;

  /// No description provided for @medicinePhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Medicine Photo'**
  String get medicinePhotoTitle;

  /// No description provided for @medicinePhotoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional - helps identify your medicine'**
  String get medicinePhotoSubtitle;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @scanName.
  ///
  /// In en, this message translates to:
  /// **'Scan Name'**
  String get scanName;

  /// No description provided for @scanMedicationLabel.
  ///
  /// In en, this message translates to:
  /// **'Scan Medication Label'**
  String get scanMedicationLabel;

  /// No description provided for @scanPrescription.
  ///
  /// In en, this message translates to:
  /// **'Scan Prescription'**
  String get scanPrescription;

  /// No description provided for @scanPrescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Camera reads medicine name & strength automatically'**
  String get scanPrescriptionHint;

  /// No description provided for @autoFillFromPhoto.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill details from photo'**
  String get autoFillFromPhoto;

  /// No description provided for @medicineNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Aspirin, Paracetamol'**
  String get medicineNameHint;

  /// No description provided for @photoCapturedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo captured successfully!'**
  String get photoCapturedSuccess;

  /// No description provided for @photoSelectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo selected successfully!'**
  String get photoSelectedSuccess;

  /// No description provided for @photoRemovedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo removed'**
  String get photoRemovedSuccess;

  /// No description provided for @lookingUpMedication.
  ///
  /// In en, this message translates to:
  /// **'Looking up medication...'**
  String get lookingUpMedication;

  /// No description provided for @scannedCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Scanned Code'**
  String get scannedCodeLabel;

  /// No description provided for @failedToCapturePhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture photo: {error}'**
  String failedToCapturePhoto(String error);

  /// No description provided for @failedToPickPhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick photo: {error}'**
  String failedToPickPhoto(String error);

  /// No description provided for @scannedMedication.
  ///
  /// In en, this message translates to:
  /// **'Scanned: {name}'**
  String scannedMedication(String name);

  /// No description provided for @medicationFound.
  ///
  /// In en, this message translates to:
  /// **'Medication found: {name}'**
  String medicationFound(String name);

  /// No description provided for @scannedCodeEnterManually.
  ///
  /// In en, this message translates to:
  /// **'Scanned code: {code}\nPlease enter details manually'**
  String scannedCodeEnterManually(String code);

  /// No description provided for @whenAndHowOftenToTake.
  ///
  /// In en, this message translates to:
  /// **'When and how often to take this medicine'**
  String get whenAndHowOftenToTake;

  /// No description provided for @howManyTimesPerDay.
  ///
  /// In en, this message translates to:
  /// **'How many times per day?'**
  String get howManyTimesPerDay;

  /// No description provided for @selectTimesPerDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Select the number of times you need to take this medicine daily'**
  String get selectTimesPerDayDesc;

  /// No description provided for @timeSingular.
  ///
  /// In en, this message translates to:
  /// **'time'**
  String get timeSingular;

  /// No description provided for @timePlural.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get timePlural;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @treatmentDuration.
  ///
  /// In en, this message translates to:
  /// **'Treatment duration'**
  String get treatmentDuration;

  /// No description provided for @startingLabel.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get startingLabel;

  /// No description provided for @treatmentEndsOn.
  ///
  /// In en, this message translates to:
  /// **'Treatment ends on {date}'**
  String treatmentEndsOn(String date);

  /// No description provided for @reminderTimesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder times'**
  String get reminderTimesTitle;

  /// No description provided for @selectTimesForReminders.
  ///
  /// In en, this message translates to:
  /// **'Select times per day to set reminder times'**
  String get selectTimesForReminders;

  /// No description provided for @scheduleSummary.
  ///
  /// In en, this message translates to:
  /// **'Schedule summary'**
  String get scheduleSummary;

  /// No description provided for @completeTheForm.
  ///
  /// In en, this message translates to:
  /// **'Complete the form'**
  String get completeTheForm;

  /// No description provided for @eachDose.
  ///
  /// In en, this message translates to:
  /// **'Each dose'**
  String get eachDose;

  /// No description provided for @starts.
  ///
  /// In en, this message translates to:
  /// **'Starts'**
  String get starts;

  /// No description provided for @repetitionPatternTitle.
  ///
  /// In en, this message translates to:
  /// **'Repetition pattern'**
  String get repetitionPatternTitle;

  /// No description provided for @whenToTakeMedication.
  ///
  /// In en, this message translates to:
  /// **'When should this medication be taken?'**
  String get whenToTakeMedication;

  /// No description provided for @activeOnDays.
  ///
  /// In en, this message translates to:
  /// **'Active on: {days}'**
  String activeOnDays(String days);

  /// No description provided for @selectDaysOfWeek.
  ///
  /// In en, this message translates to:
  /// **'Select days of the week'**
  String get selectDaysOfWeek;

  /// No description provided for @everyDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get everyDay;

  /// No description provided for @everyOtherDay.
  ///
  /// In en, this message translates to:
  /// **'Every other day'**
  String get everyOtherDay;

  /// No description provided for @mondayToFriday.
  ///
  /// In en, this message translates to:
  /// **'Monday to Friday'**
  String get mondayToFriday;

  /// No description provided for @saturdayAndSunday.
  ///
  /// In en, this message translates to:
  /// **'Saturday and Sunday'**
  String get saturdayAndSunday;

  /// No description provided for @noDaysSelected.
  ///
  /// In en, this message translates to:
  /// **'No days selected'**
  String get noDaysSelected;

  /// No description provided for @recurringReminders.
  ///
  /// In en, this message translates to:
  /// **'Recurring Reminders'**
  String get recurringReminders;

  /// No description provided for @followUpRemindersForMissed.
  ///
  /// In en, this message translates to:
  /// **'Get follow-up reminders for missed doses'**
  String get followUpRemindersForMissed;

  /// No description provided for @reminderIntervalTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Interval'**
  String get reminderIntervalTitle;

  /// No description provided for @missedDoseReminderInfo.
  ///
  /// In en, this message translates to:
  /// **'If you miss a dose, you\'ll get a reminder every {minutes} minutes (up to 4 times)'**
  String missedDoseReminderInfo(int minutes);

  /// No description provided for @trackMedicineSupply.
  ///
  /// In en, this message translates to:
  /// **'Track your medicine supply and get low stock alerts'**
  String get trackMedicineSupply;

  /// No description provided for @howManyDoYouHave.
  ///
  /// In en, this message translates to:
  /// **'How many {unit}s do you have?'**
  String howManyDoYouHave(String unit);

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'in stock'**
  String get inStock;

  /// No description provided for @stockTimeline.
  ///
  /// In en, this message translates to:
  /// **'Stock Timeline'**
  String get stockTimeline;

  /// No description provided for @dailyUsageLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily usage'**
  String get dailyUsageLabel;

  /// No description provided for @stockLastsFor.
  ///
  /// In en, this message translates to:
  /// **'Stock lasts for'**
  String get stockLastsFor;

  /// No description provided for @stockRunsOut.
  ///
  /// In en, this message translates to:
  /// **'Stock runs out'**
  String get stockRunsOut;

  /// No description provided for @stockLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock level'**
  String get stockLevelLabel;

  /// No description provided for @lowStockReminder.
  ///
  /// In en, this message translates to:
  /// **'Low stock reminder'**
  String get lowStockReminder;

  /// No description provided for @getNotifiedBeforeRunOut.
  ///
  /// In en, this message translates to:
  /// **'Get notified before your medicine runs out'**
  String get getNotifiedBeforeRunOut;

  /// No description provided for @remindMeDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind me this many days before:'**
  String get remindMeDaysBefore;

  /// No description provided for @expiryDateOptional.
  ///
  /// In en, this message translates to:
  /// **'Expiry date (optional)'**
  String get expiryDateOptional;

  /// No description provided for @trackWhenExpires.
  ///
  /// In en, this message translates to:
  /// **'Track when your medication expires'**
  String get trackWhenExpires;

  /// No description provided for @tapToSetExpiryDate.
  ///
  /// In en, this message translates to:
  /// **'Tap to set expiry date'**
  String get tapToSetExpiryDate;

  /// No description provided for @remindMeBeforeExpiry.
  ///
  /// In en, this message translates to:
  /// **'Remind me before expiry:'**
  String get remindMeBeforeExpiry;

  /// No description provided for @readyToSave.
  ///
  /// In en, this message translates to:
  /// **'Ready to save!'**
  String get readyToSave;

  /// No description provided for @completeAllSteps.
  ///
  /// In en, this message translates to:
  /// **'Complete all steps to continue'**
  String get completeAllSteps;

  /// No description provided for @medicineInfoComplete.
  ///
  /// In en, this message translates to:
  /// **'Your medicine information is complete and ready to be saved'**
  String get medicineInfoComplete;

  /// No description provided for @fillRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields in previous steps'**
  String get fillRequiredFields;

  /// No description provided for @medicineTypeAndDetails.
  ///
  /// In en, this message translates to:
  /// **'Medicine type and details'**
  String get medicineTypeAndDetails;

  /// No description provided for @scheduleConfigured.
  ///
  /// In en, this message translates to:
  /// **'Schedule configured'**
  String get scheduleConfigured;

  /// No description provided for @stockInformation.
  ///
  /// In en, this message translates to:
  /// **'Stock information'**
  String get stockInformation;

  /// No description provided for @treatmentDaysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Treatment: {count} days remaining'**
  String treatmentDaysRemaining(int count);

  /// No description provided for @treatmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Treatment completed'**
  String get treatmentCompleted;

  /// No description provided for @xTimesPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count}x per day'**
  String xTimesPerDay(int count);

  /// No description provided for @takeAll.
  ///
  /// In en, this message translates to:
  /// **'Take All'**
  String get takeAll;

  /// No description provided for @swipeRightToTake.
  ///
  /// In en, this message translates to:
  /// **'Swipe right to take'**
  String get swipeRightToTake;

  /// No description provided for @swipeLeftToSkip.
  ///
  /// In en, this message translates to:
  /// **'Swipe left to skip'**
  String get swipeLeftToSkip;

  /// No description provided for @snoozed.
  ///
  /// In en, this message translates to:
  /// **'Snoozed'**
  String get snoozed;

  /// No description provided for @scheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// No description provided for @takenAt.
  ///
  /// In en, this message translates to:
  /// **'Taken at'**
  String get takenAt;

  /// No description provided for @onTime.
  ///
  /// In en, this message translates to:
  /// **'On time'**
  String get onTime;

  /// No description provided for @minEarly.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min early'**
  String minEarly(int minutes);

  /// No description provided for @minLate.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min late'**
  String minLate(int minutes);

  /// No description provided for @hoursMinLate.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m late'**
  String hoursMinLate(int hours, int minutes);

  /// No description provided for @startStreak.
  ///
  /// In en, this message translates to:
  /// **'Start your streak today!'**
  String get startStreak;

  /// No description provided for @keepItUpStreak.
  ///
  /// In en, this message translates to:
  /// **'Keep it up! {remaining} more days to a week!'**
  String keepItUpStreak(int remaining);

  /// No description provided for @amazingStreak.
  ///
  /// In en, this message translates to:
  /// **'Amazing! {remaining} more days to a month!'**
  String amazingStreak(int remaining);

  /// No description provided for @incredibleStreak.
  ///
  /// In en, this message translates to:
  /// **'Incredible! {remaining} more days to 100!'**
  String incredibleStreak(int remaining);

  /// No description provided for @streakChampion.
  ///
  /// In en, this message translates to:
  /// **'You\'re a medication adherence champion!'**
  String get streakChampion;

  /// No description provided for @excellentAdherenceExclaim.
  ///
  /// In en, this message translates to:
  /// **'Excellent adherence! 🎉'**
  String get excellentAdherenceExclaim;

  /// No description provided for @goodProgress.
  ///
  /// In en, this message translates to:
  /// **'Good progress!'**
  String get goodProgress;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @letsCatchUp.
  ///
  /// In en, this message translates to:
  /// **'Let\'s catch up'**
  String get letsCatchUp;

  /// No description provided for @startYourDay.
  ///
  /// In en, this message translates to:
  /// **'Start your day'**
  String get startYourDay;

  /// No description provided for @excellentAdherenceMessage.
  ///
  /// In en, this message translates to:
  /// **'Excellent adherence! Keep up the great work!'**
  String get excellentAdherenceMessage;

  /// No description provided for @goodAdherenceMessage.
  ///
  /// In en, this message translates to:
  /// **'Good adherence. Try to improve consistency.'**
  String get goodAdherenceMessage;

  /// No description provided for @fairAdherenceMessage.
  ///
  /// In en, this message translates to:
  /// **'Fair adherence. Consider setting more reminders.'**
  String get fairAdherenceMessage;

  /// No description provided for @lowAdherenceMessage.
  ///
  /// In en, this message translates to:
  /// **'Low adherence. Please try to take your medications regularly.'**
  String get lowAdherenceMessage;

  /// No description provided for @veryLowAdherenceMessage.
  ///
  /// In en, this message translates to:
  /// **'Very low adherence. Talk to your healthcare provider.'**
  String get veryLowAdherenceMessage;

  /// No description provided for @overallAdherence.
  ///
  /// In en, this message translates to:
  /// **'Overall Adherence'**
  String get overallAdherence;

  /// No description provided for @adherence.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherence;

  /// No description provided for @medicationPerformance.
  ///
  /// In en, this message translates to:
  /// **'Medication Performance'**
  String get medicationPerformance;

  /// No description provided for @weeklyAdherenceInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Adherence'**
  String get weeklyAdherenceInsightTitle;

  /// No description provided for @weeklyAdherenceInsightDesc.
  ///
  /// In en, this message translates to:
  /// **'You took {percent}% of your doses this week ({taken}/{total})'**
  String weeklyAdherenceInsightDesc(int percent, int taken, int total);

  /// No description provided for @improvingTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Improving Trend 📈'**
  String get improvingTrendTitle;

  /// No description provided for @decliningTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Declining Trend 📉'**
  String get decliningTrendTitle;

  /// No description provided for @improvingTrendDesc.
  ///
  /// In en, this message translates to:
  /// **'You improved by {change}% compared to last week. Great progress!'**
  String improvingTrendDesc(int change);

  /// No description provided for @decliningTrendDesc.
  ///
  /// In en, this message translates to:
  /// **'You declined by {change}% compared to last week. Let\'s get back on track!'**
  String decliningTrendDesc(int change);

  /// No description provided for @topMedicationTitle.
  ///
  /// In en, this message translates to:
  /// **'Top Medication'**
  String get topMedicationTitle;

  /// No description provided for @topMedicationDesc.
  ///
  /// In en, this message translates to:
  /// **'{name} has {percent}% adherence - your most consistent medication!'**
  String topMedicationDesc(String name, int percent);

  /// No description provided for @streakDayTitle.
  ///
  /// In en, this message translates to:
  /// **'{streak}-Day Streak! 🔥'**
  String streakDayTitle(int streak);

  /// No description provided for @streakAmazingDesc.
  ///
  /// In en, this message translates to:
  /// **'Amazing! You\'ve been consistent for over a week!'**
  String get streakAmazingDesc;

  /// No description provided for @streakConsistencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep it up! Consistency is key to better health.'**
  String get streakConsistencyDesc;

  /// No description provided for @bestTimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Best Time ⏰'**
  String get bestTimeTitle;

  /// No description provided for @bestTimeDesc.
  ///
  /// In en, this message translates to:
  /// **'Your most consistent time is {period} with {percent}% adherence'**
  String bestTimeDesc(String period, int percent);

  /// No description provided for @excellentAdherenceInsightTitle.
  ///
  /// In en, this message translates to:
  /// **'Excellent Adherence! 🌟'**
  String get excellentAdherenceInsightTitle;

  /// No description provided for @excellentAdherenceInsightDesc.
  ///
  /// In en, this message translates to:
  /// **'Outstanding! You took {percent}% of your doses this week. Keep up the great work!'**
  String excellentAdherenceInsightDesc(int percent);

  /// No description provided for @needsImprovementTitle.
  ///
  /// In en, this message translates to:
  /// **'Needs Improvement'**
  String get needsImprovementTitle;

  /// No description provided for @needsImprovementInsightDesc.
  ///
  /// In en, this message translates to:
  /// **'Your adherence this week was {percent}%. Try setting more reminders or adjusting your schedule to improve.'**
  String needsImprovementInsightDesc(int percent);

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @medication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get medication;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @generatedOn.
  ///
  /// In en, this message translates to:
  /// **'Generated on: {date}'**
  String generatedOn(String date);

  /// No description provided for @adherenceStatistics.
  ///
  /// In en, this message translates to:
  /// **'Adherence Statistics'**
  String get adherenceStatistics;

  /// No description provided for @recentDoseHistory.
  ///
  /// In en, this message translates to:
  /// **'Recent Dose History'**
  String get recentDoseHistory;

  /// No description provided for @reportPeriod.
  ///
  /// In en, this message translates to:
  /// **'Report Period: {start} - {end}'**
  String reportPeriod(String start, String end);

  /// No description provided for @medAssistAnalyticsReport.
  ///
  /// In en, this message translates to:
  /// **'MedAssist Analytics Report'**
  String get medAssistAnalyticsReport;

  /// No description provided for @encryptBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Encrypt Backup?'**
  String get encryptBackupTitle;

  /// No description provided for @encryptBackupMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a passphrase to encrypt your backup with AES-256. Leave empty to save unencrypted. You will need the passphrase to restore.'**
  String get encryptBackupMessage;

  /// No description provided for @enterPassphraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Passphrase'**
  String get enterPassphraseTitle;

  /// No description provided for @enterPassphraseMessage.
  ///
  /// In en, this message translates to:
  /// **'This backup is encrypted. Enter the passphrase to decrypt and restore it.'**
  String get enterPassphraseMessage;

  /// No description provided for @passphrase.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get passphrase;

  /// No description provided for @encrypt.
  ///
  /// In en, this message translates to:
  /// **'Encrypt'**
  String get encrypt;

  /// No description provided for @decrypt.
  ///
  /// In en, this message translates to:
  /// **'Decrypt'**
  String get decrypt;

  /// No description provided for @interactionWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Interaction Warning'**
  String get interactionWarningTitle;

  /// No description provided for @interactionWarningMessage.
  ///
  /// In en, this message translates to:
  /// **'This medication may interact with medications you are already taking:'**
  String get interactionWarningMessage;

  /// No description provided for @addAnyway.
  ///
  /// In en, this message translates to:
  /// **'Add Anyway'**
  String get addAnyway;

  /// No description provided for @interactionCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check drug interactions'**
  String get interactionCheckFailed;

  /// No description provided for @interactionWarningCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 conflict found} other{{count} conflicts found}}'**
  String interactionWarningCount(int count);

  /// No description provided for @interactionDoctorAdvice.
  ///
  /// In en, this message translates to:
  /// **'Don\'t change your medications without consulting your doctor first.'**
  String get interactionDoctorAdvice;

  /// No description provided for @seeYourDoctor.
  ///
  /// In en, this message translates to:
  /// **'See Your Doctor'**
  String get seeYourDoctor;

  /// No description provided for @conflictBetween.
  ///
  /// In en, this message translates to:
  /// **'Conflict between'**
  String get conflictBetween;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @whatHappens.
  ///
  /// In en, this message translates to:
  /// **'What can happen?'**
  String get whatHappens;

  /// No description provided for @whatToDo.
  ///
  /// In en, this message translates to:
  /// **'What to do?'**
  String get whatToDo;

  /// No description provided for @drugInfoFetch.
  ///
  /// In en, this message translates to:
  /// **'Get AI Drug Info'**
  String get drugInfoFetch;

  /// No description provided for @drugInfoFetching.
  ///
  /// In en, this message translates to:
  /// **'Fetching drug information...'**
  String get drugInfoFetching;

  /// No description provided for @drugInfoFetchError.
  ///
  /// In en, this message translates to:
  /// **'Could not load drug information. Tap to retry.'**
  String get drugInfoFetchError;

  /// No description provided for @drugInfoDidYouMean.
  ///
  /// In en, this message translates to:
  /// **'Drug name not recognized. Did you mean one of these?'**
  String get drugInfoDidYouMean;

  /// No description provided for @drugInformation.
  ///
  /// In en, this message translates to:
  /// **'Drug Information'**
  String get drugInformation;

  /// No description provided for @genericName.
  ///
  /// In en, this message translates to:
  /// **'Generic Name'**
  String get genericName;

  /// No description provided for @activeIngredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get activeIngredients;

  /// No description provided for @drugCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get drugCategory;

  /// No description provided for @purpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose'**
  String get purpose;

  /// No description provided for @drugRoute.
  ///
  /// In en, this message translates to:
  /// **'Route'**
  String get drugRoute;

  /// No description provided for @sideEffects.
  ///
  /// In en, this message translates to:
  /// **'Side Effects'**
  String get sideEffects;

  /// No description provided for @drugWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get drugWarnings;

  /// No description provided for @howToTake.
  ///
  /// In en, this message translates to:
  /// **'How to take'**
  String get howToTake;

  /// No description provided for @watchOut.
  ///
  /// In en, this message translates to:
  /// **'Watch out'**
  String get watchOut;

  /// No description provided for @foodsToAvoid.
  ///
  /// In en, this message translates to:
  /// **'Foods to avoid'**
  String get foodsToAvoid;

  /// No description provided for @drowsinessWarning.
  ///
  /// In en, this message translates to:
  /// **'Drowsiness warning'**
  String get drowsinessWarning;

  /// No description provided for @mayCauseDrowsiness.
  ///
  /// In en, this message translates to:
  /// **'May cause drowsiness. Avoid driving after taking it.'**
  String get mayCauseDrowsiness;

  /// No description provided for @missedDoseAdvice.
  ///
  /// In en, this message translates to:
  /// **'Missed dose'**
  String get missedDoseAdvice;

  /// No description provided for @storageInstructions.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageInstructions;

  /// No description provided for @alcoholWarning.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get alcoholWarning;

  /// No description provided for @contraindications.
  ///
  /// In en, this message translates to:
  /// **'Don\'t take if'**
  String get contraindications;

  /// No description provided for @requiresMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Monitoring'**
  String get requiresMonitoring;

  /// No description provided for @otcOrPrescription.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get otcOrPrescription;

  /// No description provided for @severityMinor.
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get severityMinor;

  /// No description provided for @severityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get severityModerate;

  /// No description provided for @severityMajor.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get severityMajor;

  /// No description provided for @severitySevere.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severitySevere;

  /// No description provided for @severityMinorDesc.
  ///
  /// In en, this message translates to:
  /// **'Monitor for side effects'**
  String get severityMinorDesc;

  /// No description provided for @severityModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Use with caution'**
  String get severityModerateDesc;

  /// No description provided for @severityMajorDesc.
  ///
  /// In en, this message translates to:
  /// **'Avoid if possible'**
  String get severityMajorDesc;

  /// No description provided for @severitySevereDesc.
  ///
  /// In en, this message translates to:
  /// **'Do not combine'**
  String get severitySevereDesc;

  /// No description provided for @medicationSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Saved'**
  String get medicationSavedTitle;

  /// No description provided for @medicationSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your medication has been added successfully.'**
  String get medicationSavedMessage;

  /// No description provided for @drugInfoAddedHint.
  ///
  /// In en, this message translates to:
  /// **'Drug details, side effects and warnings have been added automatically. Check the medication details to review.'**
  String get drugInfoAddedHint;

  /// No description provided for @interactionsFoundHint.
  ///
  /// In en, this message translates to:
  /// **'{count} interaction(s) found with your existing medications. Open medication details to review.'**
  String interactionsFoundHint(int count);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @chatHistory.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistory;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New Chat'**
  String get newChat;

  /// No description provided for @deleteChat.
  ///
  /// In en, this message translates to:
  /// **'Delete Chat'**
  String get deleteChat;

  /// No description provided for @deleteChatConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this conversation?'**
  String get deleteChatConfirm;

  /// No description provided for @noChatHistory.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noChatHistory;

  /// No description provided for @noChatHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a new chat to get medication advice'**
  String get noChatHistorySubtitle;

  /// No description provided for @chatSessionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get chatSessionDeleted;

  /// No description provided for @deleteAllChats.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAllChats;

  /// No description provided for @deleteAllChatsConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete all conversations?'**
  String get deleteAllChatsConfirm;

  /// No description provided for @allChatsDeleted.
  ///
  /// In en, this message translates to:
  /// **'All conversations deleted'**
  String get allChatsDeleted;

  /// No description provided for @older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get older;

  /// No description provided for @messagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} messages'**
  String messagesCount(int count);

  /// No description provided for @shoppingList.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get shoppingList;

  /// No description provided for @shoppingListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Medications you need to refill'**
  String get shoppingListSubtitle;

  /// No description provided for @noItemsNeeded.
  ///
  /// In en, this message translates to:
  /// **'All stocked up!'**
  String get noItemsNeeded;

  /// No description provided for @noItemsNeededSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your medications are well-stocked'**
  String get noItemsNeededSubtitle;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get expiringSoon;

  /// No description provided for @daysOfStockLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} days left'**
  String daysOfStockLeft(int count);

  /// No description provided for @expiresInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires in {count} days'**
  String expiresInDays(int count);

  /// No description provided for @expiredAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {count} days ago'**
  String expiredAgo(int count);

  /// No description provided for @shareShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Share List'**
  String get shareShoppingList;

  /// No description provided for @copyShoppingList.
  ///
  /// In en, this message translates to:
  /// **'Copy List'**
  String get copyShoppingList;

  /// No description provided for @shoppingListCopied.
  ///
  /// In en, this message translates to:
  /// **'Shopping list copied to clipboard'**
  String get shoppingListCopied;

  /// No description provided for @itemsToRefill.
  ///
  /// In en, this message translates to:
  /// **'{count} items to refill'**
  String itemsToRefill(int count);

  /// No description provided for @urgentRefill.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgentRefill;

  /// No description provided for @soonRefill.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get soonRefill;

  /// No description provided for @planAhead.
  ///
  /// In en, this message translates to:
  /// **'Plan Ahead'**
  String get planAhead;

  /// No description provided for @toBuy.
  ///
  /// In en, this message translates to:
  /// **'To Buy'**
  String get toBuy;

  /// No description provided for @inCart.
  ///
  /// In en, this message translates to:
  /// **'In Cart'**
  String get inCart;

  /// No description provided for @scheduleSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get scheduleSectionTitle;

  /// No description provided for @scheduleSectionDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose how often to take this medication'**
  String get scheduleSectionDesc;

  /// No description provided for @modeDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get modeDaily;

  /// No description provided for @modeWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get modeWeekly;

  /// No description provided for @modeMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get modeMonthly;

  /// No description provided for @modeAsNeeded.
  ///
  /// In en, this message translates to:
  /// **'As Needed'**
  String get modeAsNeeded;

  /// No description provided for @everyNDays.
  ///
  /// In en, this message translates to:
  /// **'Every N days'**
  String get everyNDays;

  /// No description provided for @everyLabel.
  ///
  /// In en, this message translates to:
  /// **'Every'**
  String get everyLabel;

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @weekSingular.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get weekSingular;

  /// No description provided for @weekPlural.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weekPlural;

  /// No description provided for @monthSingular.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get monthSingular;

  /// No description provided for @monthPlural.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get monthPlural;

  /// No description provided for @weekdaysPreset.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get weekdaysPreset;

  /// No description provided for @weekendsPreset.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get weekendsPreset;

  /// No description provided for @allDaysPreset.
  ///
  /// In en, this message translates to:
  /// **'All days'**
  String get allDaysPreset;

  /// No description provided for @dayOfMonthLabel.
  ///
  /// In en, this message translates to:
  /// **'Day of month'**
  String get dayOfMonthLabel;

  /// No description provided for @monthlyShortMonthHint.
  ///
  /// In en, this message translates to:
  /// **'Falls on last day when month is shorter'**
  String get monthlyShortMonthHint;

  /// No description provided for @asNeededInfo.
  ///
  /// In en, this message translates to:
  /// **'Take only when needed. Reminders will not be scheduled.'**
  String get asNeededInfo;

  /// No description provided for @nextDose.
  ///
  /// In en, this message translates to:
  /// **'Next dose'**
  String get nextDose;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @laterToday.
  ///
  /// In en, this message translates to:
  /// **'Later today'**
  String get laterToday;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @noMoreDosesToday.
  ///
  /// In en, this message translates to:
  /// **'No more doses scheduled today'**
  String get noMoreDosesToday;

  /// No description provided for @dueNow.
  ///
  /// In en, this message translates to:
  /// **'Due now'**
  String get dueNow;

  /// No description provided for @dueInMinutes.
  ///
  /// In en, this message translates to:
  /// **'Due in {minutes} min'**
  String dueInMinutes(int minutes);

  /// No description provided for @dueInHours.
  ///
  /// In en, this message translates to:
  /// **'Due in {hours}h {minutes}m'**
  String dueInHours(int hours, int minutes);

  /// No description provided for @overdueByMinutes.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {minutes} min'**
  String overdueByMinutes(int minutes);

  /// No description provided for @overdueByHours.
  ///
  /// In en, this message translates to:
  /// **'Overdue by {hours}h {minutes}m'**
  String overdueByHours(int hours, int minutes);

  /// No description provided for @noNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get noNotes;

  /// No description provided for @dosageInfo.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosageInfo;

  /// No description provided for @mostMissed.
  ///
  /// In en, this message translates to:
  /// **'Most Missed'**
  String get mostMissed;

  /// No description provided for @bestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get bestTime;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day Streak'**
  String get dayStreak;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @goodNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get goodNight;

  /// No description provided for @todaysProgress.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress'**
  String get todaysProgress;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// No description provided for @stayOnTrack.
  ///
  /// In en, this message translates to:
  /// **'Stay on track'**
  String get stayOnTrack;

  /// No description provided for @greatJobToday.
  ///
  /// In en, this message translates to:
  /// **'Great job today'**
  String get greatJobToday;

  /// No description provided for @letsStartDay.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start the day'**
  String get letsStartDay;
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
