import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Handles timezone detection and initialization for notification scheduling.
class NotificationTimezone {
  NotificationTimezone._();

  /// Initialize timezone database and detect device timezone.
  static Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final timezoneName = timezoneInfo.identifier;
      debugPrint('📍 Device timezone detected: $timezoneName');

      try {
        final location = tz.getLocation(timezoneName);
        tz.setLocalLocation(location);
        debugPrint('✅ Timezone set successfully to: ${tz.local.name}');
        debugPrint('✅ Current offset: ${tz.local.currentTimeZone.offset}');
      } catch (locationError) {
        debugPrint('⚠️ Timezone "$timezoneName" not found in database');
        debugPrint('⚠️ Error: $locationError');

        final variations = _getTimezoneVariations(timezoneName);
        var timezoneSet = false;

        for (final variation in variations) {
          try {
            final location = tz.getLocation(variation);
            tz.setLocalLocation(location);
            debugPrint('✅ Using timezone variation: $variation');
            timezoneSet = true;
            break;
          } catch (e) {
            continue;
          }
        }

        if (!timezoneSet) {
          throw Exception(
            'Could not find matching timezone for: $timezoneName',
          );
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error in timezone detection: $e');
      debugPrint('Stack trace: $stackTrace');
      _fallbackToOffset();
    }
  }

  static void _fallbackToOffset() {
    final now = DateTime.now();
    final offset = now.timeZoneOffset;
    debugPrint('📍 Device timezone offset: ${offset.inHours} hours');

    final timezoneByOffset = _getTimezoneByOffset(offset);
    var timezoneSet = false;

    for (final timezoneName in timezoneByOffset) {
      try {
        tz.setLocalLocation(tz.getLocation(timezoneName));
        debugPrint('✅ Using timezone based on offset: $timezoneName');
        timezoneSet = true;
        break;
      } catch (e) {
        continue;
      }
    }

    if (!timezoneSet) {
      debugPrint('⚠️ All timezone detection failed, using UTC');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  static List<String> _getTimezoneVariations(String timezoneName) {
    final variations = <String>[timezoneName];

    if (timezoneName.contains('_')) {
      variations.add(timezoneName.replaceAll('_', ' '));
    }
    if (timezoneName.contains(' ')) {
      variations.add(timezoneName.replaceAll(' ', '_'));
    }

    variations.add(timezoneName.toLowerCase());
    variations.add(timezoneName.toUpperCase());

    return variations;
  }

  static List<String> _getTimezoneByOffset(Duration offset) {
    final offsetHours = offset.inHours;

    final timezoneMap = <int, List<String>>{
      -12: ['Pacific/Kwajalein'],
      -11: ['Pacific/Samoa'],
      -10: ['Pacific/Honolulu'],
      -9: ['America/Anchorage'],
      -8: ['America/Los_Angeles', 'America/Vancouver'],
      -7: ['America/Denver', 'America/Phoenix'],
      -6: ['America/Chicago', 'America/Mexico_City'],
      -5: ['America/New_York', 'America/Toronto'],
      -4: ['America/Caracas', 'America/Halifax'],
      -3: ['America/Sao_Paulo', 'America/Argentina/Buenos_Aires'],
      -2: ['Atlantic/South_Georgia'],
      -1: ['Atlantic/Azores'],
      0: ['UTC', 'Europe/London', 'Africa/Casablanca'],
      1: ['Europe/Paris', 'Europe/Berlin', 'Africa/Lagos'],
      2: ['Africa/Cairo', 'Europe/Athens', 'Africa/Johannesburg'],
      3: ['Europe/Moscow', 'Asia/Riyadh', 'Africa/Nairobi'],
      4: ['Asia/Dubai', 'Asia/Baku'],
      5: ['Asia/Karachi', 'Asia/Tashkent'],
      6: ['Asia/Dhaka', 'Asia/Almaty'],
      7: ['Asia/Bangkok', 'Asia/Jakarta'],
      8: ['Asia/Shanghai', 'Asia/Singapore', 'Asia/Hong_Kong'],
      9: ['Asia/Tokyo', 'Asia/Seoul'],
      10: ['Australia/Sydney', 'Australia/Melbourne'],
      11: ['Pacific/Noumea'],
      12: ['Pacific/Fiji', 'Pacific/Auckland'],
    };

    return timezoneMap[offsetHours] ?? ['UTC'];
  }

  /// Manually set timezone (for troubleshooting).
  static bool setTimezone(String timezoneName) {
    try {
      final location = tz.getLocation(timezoneName);
      tz.setLocalLocation(location);
      debugPrint('✅ Manually set timezone to: $timezoneName');
      return true;
    } catch (e) {
      debugPrint('❌ Failed to set timezone to $timezoneName: $e');
      return false;
    }
  }

  /// Common timezones for manual selection.
  static List<String> get commonTimezones => [
    'Asia/Riyadh',
    'Asia/Dubai',
    'Africa/Cairo',
    'Asia/Baghdad',
    'Asia/Kuwait',
    'Asia/Qatar',
    'Asia/Bahrain',
    'Europe/London',
    'Europe/Paris',
    'America/New_York',
    'America/Chicago',
    'America/Los_Angeles',
    'Asia/Tokyo',
    'Australia/Sydney',
    'UTC',
  ];
}
