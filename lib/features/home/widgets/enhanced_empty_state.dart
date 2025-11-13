import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/theme/app_colors.dart';

class EnhancedEmptyState extends StatelessWidget {

  const EnhancedEmptyState({
    super.key,
    this.onAddPressed,
  });
  final VoidCallback? onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
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
            const Text(
              'No Medications Yet',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ).animate().slideY(begin: 0.3, duration: 600.ms).fadeIn(),

            const SizedBox(height: 16),

            // Description
            const Text(
              "Start your health journey by adding your first medication. We'll help you stay on track!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
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
                label: const Text(
                  'Add Your First Medication',
                  style: TextStyle(
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
            _buildFeaturesList().animate(delay: 600.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildFeatureItem(
          icon: Icons.notifications_active_rounded,
          text: 'Smart reminders at the right time',
          gradient: AppColors.purpleGradient,
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.analytics_rounded,
          text: 'Track your medication adherence',
          gradient: AppColors.successGradient,
        ),
        const SizedBox(height: 12),
        _buildFeatureItem(
          icon: Icons.shield_rounded,
          text: '100% private and secure',
          gradient: AppColors.warningGradient,
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required LinearGradient gradient,
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
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
