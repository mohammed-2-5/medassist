import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class DiagnosticsActionButtons extends StatelessWidget {
  const DiagnosticsActionButtons({
    required this.onSendTestNotification,
    required this.onScheduleTestNotification,
    required this.onRequestPermissions,
    super.key,
  });

  final Future<void> Function() onSendTestNotification;
  final Future<void> Function() onScheduleTestNotification;
  final Future<void> Function() onRequestPermissions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _ActionButton(
          title: l10n.sendTestNotificationTitle,
          subtitle: l10n.testIfNotificationsWork,
          icon: Icons.notifications_active_rounded,
          color: AppColors.primaryBlue,
          onPressed: onSendTestNotification,
          index: 0,
        ),
        const SizedBox(height: 12),
        _ActionButton(
          title: l10n.scheduleTest1Min,
          subtitle: l10n.scheduleTestDescription,
          icon: Icons.schedule_rounded,
          color: AppColors.warningOrange,
          onPressed: onScheduleTestNotification,
          index: 1,
        ),
        const SizedBox(height: 12),
        _ActionButton(
          title: l10n.requestPermissionsTitle,
          subtitle: l10n.requestPermissionsDescription,
          icon: Icons.security_rounded,
          color: AppColors.accentPurple,
          onPressed: onRequestPermissions,
          index: 2,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.index,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Future<void> Function() onPressed;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
          onTap: () => onPressed(),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.arrow_back_ios
                      : Icons.arrow_forward_ios,
                  size: 16,
                  color: color,
                ),
              ],
            ),
          ),
        )
        .animate(delay: (index * 100).ms)
        .slideX(begin: 0.2, duration: 500.ms)
        .fadeIn();
  }
}
