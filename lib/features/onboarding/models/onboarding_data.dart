import 'package:flutter/material.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Data model for a single onboarding page.
class OnboardingData {
  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });

  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;

  static List<OnboardingData> getPages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      OnboardingData(
        title: l10n.welcomeTitle,
        description: l10n.welcomeDescription,
        icon: Icons.medication_rounded,
        gradient: AppColors.primaryGradient,
        accentColor: AppColors.primaryBlue,
      ),
      OnboardingData(
        title: l10n.neverMissTitle,
        description: l10n.neverMissDescription,
        icon: Icons.notifications_active_rounded,
        gradient: AppColors.purpleGradient,
        accentColor: AppColors.accentPurple,
      ),
      OnboardingData(
        title: l10n.trackProgressTitle,
        description: l10n.trackProgressDescription,
        icon: Icons.analytics_rounded,
        gradient: AppColors.successGradient,
        accentColor: AppColors.accentGreen,
      ),
      OnboardingData(
        title: l10n.stayHealthyTitle,
        description: l10n.stayHealthyDescription,
        icon: Icons.favorite_rounded,
        gradient: AppColors.pinkGradient,
        accentColor: AppColors.accentPink,
      ),
    ];
  }
}
