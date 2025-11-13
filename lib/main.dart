import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/app.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/errors/error_handler_service.dart';
import 'package:med_assist/services/background/background_service.dart';
import 'package:med_assist/services/notification/notification_service.dart';
import 'package:med_assist/services/permissions/permissions_service.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  // Run app in error-handling zone
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables
    await dotenv.load(fileName: '.env');
    // ✅ Initialize WorkManager FIRST
    try {
      await Workmanager().initialize(
        callbackDispatcher, // your top-level function
        isInDebugMode: kDebugMode,
      );
      debugPrint('✅ WorkManager initialized successfully');
    } catch (e) {
      debugPrint('❌ WorkManager init failed: $e');
    }
    // Initialize error handler
    debugPrint('Initializing error handler...');
    final errorHandler = ErrorHandlerService();
    await errorHandler.initialize();

    try {
      // Initialize Crashlytics
      //await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

      // Initialize notification service ONCE
      debugPrint('Initializing notification service...');
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Request notification permissions
      debugPrint('Requesting notification permissions...');
      await notificationService.requestPermissions();

      // Initialize background service
      debugPrint('Initializing background service...');
      final bg = WorkManagerBackgroundService();
      await bg.configure();

      // Clean up old snooze history from previous days
      debugPrint('Cleaning up old snooze history...');
      try {
        final database = AppDatabase();
        await database.resetOldSnoozeHistory();
        debugPrint('✅ Snooze history cleanup completed');
      } catch (e) {
        debugPrint('❌ Snooze history cleanup failed: $e');
        // Non-critical, continue anyway
      }

      // Request initial permissions
      debugPrint('Requesting initial permissions...');
      final permissionsService = PermissionsService();
      final permissions = await permissionsService.requestInitialPermissions();

      debugPrint('Permissions status: $permissions');

      // Start background service
      await bg.start();

      debugPrint('All services initialized successfully');
    } catch (e, stack) {
      errorHandler.capture(e, stackTrace: stack, reason: 'Service initialization error');
      debugPrint('Error initializing services: $e');
      // Continue anyway - app should still work without some services
    }
    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  }, (error, stack) {
    // Catch all unhandled errors
    ErrorHandlerService().capture(
      error,
      stackTrace: stack,
      reason: 'Unhandled error in app',
    );
    debugPrint('Unhandled error: $error');
  });
}
