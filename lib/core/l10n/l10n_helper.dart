import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Helper extension to access AppLocalizations easily
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

}
