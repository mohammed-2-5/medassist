import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:med_assist/services/notification/notification_service.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Permissions Service - Handle app permissions
///
/// Manages:
/// - Notification permissions
/// - Exact alarm permissions (Android 12+)
/// - Camera permissions (for OCR)
/// - Storage permissions (for photos)
class PermissionsService {
  factory PermissionsService() => _instance;
  PermissionsService._internal();
  static final PermissionsService _instance = PermissionsService._internal();

  final NotificationService _notificationService = NotificationService();

  /// Check if notification permissions are granted
  Future<bool> areNotificationsEnabled() async {
    return _notificationService.areNotificationsEnabled();
  }

  /// Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    debugPrint('Requesting notification permissions');

    try {
      final granted = await _notificationService.requestPermissions();

      if (granted) {
        debugPrint('Notification permissions granted');
      } else {
        debugPrint('Notification permissions denied');
      }

      return granted;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Check if exact alarm permission is granted (Android 12+)
  Future<bool> canScheduleExactAlarms() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true; // iOS doesn't need this permission
    }

    try {
      final status = await ph.Permission.scheduleExactAlarm.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking exact alarm permission: $e');
      return true; // Assume granted if check fails
    }
  }

  /// Request exact alarm permission (Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    try {
      final status = await ph.Permission.scheduleExactAlarm.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting exact alarm permission: $e');
      return false;
    }
  }

  /// Check if battery optimization is disabled (important for background tasks)
  Future<bool> isBatteryOptimizationDisabled() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    try {
      final status = await ph.Permission.ignoreBatteryOptimizations.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking battery optimization: $e');
      return false;
    }
  }

  /// Request to disable battery optimization (needed for reliable notifications)
  Future<bool> requestDisableBatteryOptimization() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }

    try {
      final status = await ph.Permission.ignoreBatteryOptimizations.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting battery optimization exemption: $e');
      return false;
    }
  }

  /// Check if camera permission is granted
  Future<bool> isCameraGranted() async {
    try {
      final status = await ph.Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('Error checking camera permission: $e');
      return false;
    }
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() async {
    try {
      final status = await ph.Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      debugPrint('Error requesting camera permission: $e');
      return false;
    }
  }

  /// Check if storage permission is granted
  Future<bool> isStorageGranted() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // Android 13+ doesn't need storage permission for photos
        final status = await ph.Permission.photos.status;
        return status.isGranted;
      } else {
        // iOS uses photos permission
        final status = await ph.Permission.photos.status;
        return status.isGranted;
      }
    } catch (e) {
      debugPrint('Error checking storage permission: $e');
      return false;
    }
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await ph.Permission.photos.request();
        return status.isGranted;
      } else {
        final status = await ph.Permission.photos.request();
        return status.isGranted;
      }
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      return false;
    }
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    try {
      await ph.openAppSettings();
      debugPrint('Opened app settings');
    } catch (e) {
      debugPrint('Error opening app settings: $e');
    }
  }

  /// Request all necessary permissions on first launch
  Future<Map<String, bool>> requestInitialPermissions() async {
    final results = <String, bool>{};

    // Request notification permissions (most important)
    results['notifications'] = await requestNotificationPermissions();

    // Request exact alarm permission on Android 12+
    if (defaultTargetPlatform == TargetPlatform.android) {
      results['exactAlarms'] = await requestExactAlarmPermission();

      // Request battery optimization exemption (CRITICAL for notifications)
      results['batteryOptimization'] = await requestDisableBatteryOptimization();
    } else {
      results['exactAlarms'] = true;
      results['batteryOptimization'] = true;
    }

    return results;
  }

  /// Check all permissions status
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'notifications': await areNotificationsEnabled(),
      'exactAlarms': await canScheduleExactAlarms(),
      'batteryOptimization': await isBatteryOptimizationDisabled(),
      'camera': await isCameraGranted(),
      'storage': await isStorageGranted(),
    };
  }

  /// Show permission rationale dialog
  Future<bool?> showPermissionRationale(
    BuildContext context, {
    required String title,
    required String message,
    String positiveButton = 'Grant Permission',
    String negativeButton = 'Not Now',
  }) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(negativeButton),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(positiveButton),
          ),
        ],
      ),
    );
  }

  /// Show settings dialog when permission is permanently denied
  Future<void> showPermissionDeniedDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );

    if (shouldOpen ?? false) {
      await openAppSettings();
    }
  }
}
