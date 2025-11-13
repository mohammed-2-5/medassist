class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Info
  static const String appName = 'Med Assist';
  static const String appTagline = 'Your medication companion';

  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyThemeMode = 'theme_mode';
  static const String keyTimeZone = 'time_zone';

  // Routes
  static const String routeSplash = '/';
  static const String routeOnboarding = '/onboarding';
  static const String routeHome = '/home';
  static const String routeAddReminder = '/add-reminder';
  static const String routeSettings = '/settings';

  // Notification
  static const String notificationChannelId = 'med_assist_reminders';
  static const String notificationChannelName = 'Medication Reminders';
  static const String notificationChannelDescription =
      'Notifications for medication reminders';

  // Background
  static const int backgroundFetchInterval = 15; // minutes

  // Database
  static const String databaseName = 'med_assist.db';
  static const int databaseVersion = 1;
}
