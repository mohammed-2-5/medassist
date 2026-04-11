import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class DiagnosticsTroubleshooting extends StatelessWidget {
  const DiagnosticsTroubleshooting({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: _withGradientOpacity(AppColors.warningGradient, 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.warningOrange.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.warningGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.help_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.troubleshooting,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _TroubleshootingItem(
            title: l10n.notificationsNotAppearing,
            content: l10n.notificationsNotAppearingTips,
          ),
          const SizedBox(height: 12),
          _TroubleshootingItem(
            title: l10n.appCrashing,
            content: l10n.appCrashingTips,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/settings/notification-debug'),
              icon: const Icon(Icons.bug_report_rounded),
              label: Text(l10n.advancedDiagnostics),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    ).animate(delay: 600.ms).fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }
}

class _TroubleshootingItem extends StatelessWidget {
  const _TroubleshootingItem({
    required this.title,
    required this.content,
  });

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

LinearGradient _withGradientOpacity(LinearGradient gradient, double opacity) {
  return LinearGradient(
    colors: gradient.colors.map((color) => color.withOpacity(opacity)).toList(),
    begin: gradient.begin,
    end: gradient.end,
  );
}
