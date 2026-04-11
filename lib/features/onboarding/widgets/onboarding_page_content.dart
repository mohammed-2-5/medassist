import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/onboarding/models/onboarding_data.dart';

/// Animated content for a single onboarding page (icon, title, description).
class OnboardingPageContent extends StatelessWidget {
  const OnboardingPageContent({
    required this.page, required this.index, super.key,
  });

  final OnboardingData page;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: page.gradient,
              boxShadow: [
                BoxShadow(
                  color: page.accentColor.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                page.icon,
                size: 100,
                color: Colors.white,
              ),
            ),
          )
              .animate(key: ValueKey(index))
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(),

          const SizedBox(height: 60),

          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          )
              .animate(key: ValueKey('${index}_title'))
              .slideY(
                begin: 0.3,
                duration: 500.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          )
              .animate(key: ValueKey('${index}_desc'))
              .slideY(
                begin: 0.3,
                duration: 500.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 300.ms),
        ],
      ),
    );
  }
}
