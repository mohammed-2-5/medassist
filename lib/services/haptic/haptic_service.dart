import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Haptic feedback service for providing tactile feedback
class HapticService {
  HapticService._();

  static bool _enabled = true;

  /// Enable or disable haptic feedback
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Light impact (for simple interactions like taps)
  static Future<void> light() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.lightImpact();
      // Fallback to vibration if HapticFeedback not available
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 10);
      }
    } catch (e) {
      // Silently fail if haptics not supported
    }
  }

  /// Medium impact (for moderate interactions like switches)
  static Future<void> medium() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.mediumImpact();
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 20);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Heavy impact (for important interactions like confirmations)
  static Future<void> heavy() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.heavyImpact();
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 30);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Selection feedback (for picker/selector changes)
  static Future<void> selection() async {
    if (!_enabled) return;
    try {
      await HapticFeedback.selectionClick();
    } catch (e) {
      // Silently fail
    }
  }

  /// Success pattern (for successful operations)
  static Future<void> success() async {
    if (!_enabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(pattern: [0, 50, 50, 50]);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Error pattern (for errors or failed operations)
  static Future<void> error() async {
    if (!_enabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(pattern: [0, 100, 50, 100]);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Warning pattern (for important alerts)
  static Future<void> warning() async {
    if (!_enabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(pattern: [0, 80, 100, 80]);
      } else {
        await HapticFeedback.heavyImpact();
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Delete pattern (for delete actions)
  static Future<void> delete() async {
    if (!_enabled) return;
    try {
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 40);
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      // Silently fail
    }
  }
}
