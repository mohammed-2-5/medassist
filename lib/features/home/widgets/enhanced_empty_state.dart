import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class EnhancedEmptyState extends StatelessWidget {

  const EnhancedEmptyState({
    super.key,
    this.onAddPressed,
  });
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewportHeight = MediaQuery.of(context).size.height - MediaQuery.paddingOf(context).vertical;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: viewportHeight),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            // Animated illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medication_liquid_rounded,
                size: 100,
                color: Colors.white,
              ),
            )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(
                  duration: 2000.ms,
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  curve: Curves.easeInOut,
                ),

            const SizedBox(height: 48),

            // Title
            Text(
              l10n.noMedicationsYet,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(),

            const SizedBox(height: 16),

            // Description
            Text(
              l10n.startByAdding,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            )
                .animate(delay: 200.ms)
                .slideY(begin: 0.3, duration: 600.ms)
                .fadeIn(),

            const SizedBox(height: 48),

            // Add button
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: onAddPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, color: Colors.white),
                label: Text(
                  l10n.addYourFirstMedication,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
                .animate(delay: 400.ms)
                .scale(duration: 600.ms, curve: Curves.elasticOut)
                .fadeIn(),

            const SizedBox(height: 24),

            // Features
            _buildFeaturesList(l10n, colorScheme).animate(delay: 600.ms).fadeIn(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesList(AppLocalizations l10n, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.notifications_active_rounded,
          text: l10n.smartRemindersDescription,
          gradient: AppColors.purpleGradient,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.analytics_rounded,
          text: l10n.trackProgressDescription,
          gradient: AppColors.successGradient,
          colorScheme: colorScheme,
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.shield_rounded,
          text: l10n.privateDataDescription,
          gradient: AppColors.warningGradient,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required LinearGradient gradient,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
