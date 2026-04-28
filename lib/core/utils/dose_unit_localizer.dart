import 'package:med_assist/l10n/app_localizations.dart';

String localizeDoseUnit(AppLocalizations l10n, String unit) {
  final normalized = unit.trim().toLowerCase();
  return switch (normalized) {
    'tablet' || 'tablets' => l10n.tablet,
    'capsule' || 'capsules' => l10n.capsule,
    'drop' || 'drops' => l10n.drops,
    'unit' => l10n.unit,
    _ => unit,
  };
}
