import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class DiagnosticsPermissionCard extends StatelessWidget {
  const DiagnosticsPermissionCard({
    required this.title,
    required this.isGranted,
    required this.description,
    required this.index,
    super.key,
  });

  final String title;
  final bool isGranted;
  final String description;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = isGranted ? AppColors.successGreen : AppColors.errorRed;
    final statusGradient = isGranted
        ? AppColors.successGradient
        : LinearGradient(
            colors: [AppColors.errorRed, AppColors.errorRed.withOpacity(0.7)],
          );

    return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _withGradientOpacity(statusGradient, 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: statusGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isGranted ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isGranted
                      ? AppLocalizations.of(context)!.ok_status
                      : AppLocalizations.of(context)!.needed_status,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        )
        .animate(delay: (index * 100).ms)
        .slideX(begin: 0.2, duration: 500.ms)
        .fadeIn();
  }
}

LinearGradient _withGradientOpacity(LinearGradient gradient, double opacity) {
  return LinearGradient(
    colors: gradient.colors.map((color) => color.withOpacity(opacity)).toList(),
    begin: gradient.begin,
    end: gradient.end,
  );
}
