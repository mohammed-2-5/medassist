import 'package:flutter/material.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Presentation metadata for [MedicineType]: emoji, localized label,
/// localized description, and card gradient. Keeps [MedicineType] free
/// of UI and l10n concerns.
extension MedicineTypeStyle on MedicineType {
  String get emoji => switch (this) {
    MedicineType.pill => '💊',
    MedicineType.injection => '💉',
    MedicineType.suppository => '🌡️',
    MedicineType.ivSolution => '💧',
    MedicineType.syrup => '🥄',
    MedicineType.drops => '💧',
  };

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    MedicineType.pill => l10n.pill,
    MedicineType.injection => l10n.injection,
    MedicineType.suppository => l10n.suppository,
    MedicineType.ivSolution => l10n.ivSolution,
    MedicineType.syrup => l10n.syrup,
    MedicineType.drops => l10n.drops,
  };

  String localizedDescription(AppLocalizations l10n) => switch (this) {
    MedicineType.pill => l10n.medTypePillDesc,
    MedicineType.injection => l10n.medTypeInjectionDesc,
    MedicineType.suppository => l10n.medTypeSuppositoryDesc,
    MedicineType.ivSolution => l10n.medTypeIvSolutionDesc,
    MedicineType.syrup => l10n.medTypeSyrupDesc,
    MedicineType.drops => l10n.medTypeDropsDesc,
  };

  LinearGradient get gradient => switch (this) {
    MedicineType.pill => AppColors.primaryGradient,
    MedicineType.injection => AppColors.pinkGradient,
    MedicineType.suppository => AppColors.warningGradient,
    MedicineType.ivSolution => const LinearGradient(
      colors: [Color(0xFF42A5F5), Color(0xFF4DD0CE)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    MedicineType.syrup => AppColors.successGradient,
    MedicineType.drops => const LinearGradient(
      colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  };
}
