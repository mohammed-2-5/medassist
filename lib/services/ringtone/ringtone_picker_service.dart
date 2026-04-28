import 'dart:io';

import 'package:flutter/services.dart';

/// Result of a native ringtone picker invocation.
class PickedRingtone {
  const PickedRingtone({required this.uri, this.title});
  final String uri;
  final String? title;
}

/// Bridge to native (Android) system ringtone picker.
///
/// iOS has no public ringtone picker API — calls return `null`.
class RingtonePickerService {
  RingtonePickerService._();

  static const MethodChannel _channel = MethodChannel('med_assist/ringtone');

  /// Launch the system notification ringtone picker.
  ///
  /// Returns the chosen ringtone, or `null` if the user cancelled or the
  /// platform is unsupported.
  static Future<PickedRingtone?> pick({
    String? existingUri,
    String? title,
  }) async {
    if (!Platform.isAndroid) return null;
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'pickRingtone',
        {'existingUri': existingUri, 'title': title},
      );
      if (result == null) return null;
      final uri = result['uri'] as String?;
      if (uri == null || uri.isEmpty) return null;
      return PickedRingtone(uri: uri, title: result['title'] as String?);
    } on PlatformException {
      return null;
    }
  }

  /// Play a ringtone preview using Android's native Ringtone API.
  ///
  /// Returns `true` if playback started. Handles `content://` URIs that
  /// `MediaPlayer` (via audioplayers) can't open directly.
  static Future<bool> play(String uri) async {
    if (!Platform.isAndroid) return false;
    if (uri.isEmpty) return false;
    try {
      final ok = await _channel.invokeMethod<bool>('playRingtone', {
        'uri': uri,
      });
      return ok ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Stop any ongoing ringtone preview.
  static Future<void> stop() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('stopRingtone');
    } on PlatformException {
      // ignore
    }
  }

  /// Resolve a stored URI back to its display title (e.g. on app restart).
  static Future<String?> getTitle(String uri) async {
    if (!Platform.isAndroid) return null;
    if (uri.isEmpty) return null;
    try {
      return await _channel.invokeMethod<String>(
        'getRingtoneTitle',
        {'uri': uri},
      );
    } on PlatformException {
      return null;
    }
  }
}
