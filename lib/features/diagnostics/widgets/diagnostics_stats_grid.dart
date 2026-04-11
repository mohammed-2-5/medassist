import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class DiagnosticsStatsGrid extends StatelessWidget {
  const DiagnosticsStatsGrid({
    required this.dbStats,
    super.key,
  });

  final Map<String, int>? dbStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (dbStats == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final stats = [
      _StatItem(
        label: l10n.totalMedications,
        value: dbStats!['medications']!,
        icon: Icons.medication_rounded,
        color: AppColors.primaryBlue,
      ),
      _StatItem(
        label: l10n.activeMedications,
        value: dbStats!['activeMeds']!,
        icon: Icons.check_circle_rounded,
        color: AppColors.successGreen,
      ),
      _StatItem(
        label: l10n.totalDoseHistory,
        value: dbStats!['doseHistory']!,
        icon: Icons.history_rounded,
        color: AppColors.accentPurple,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    stat.color.withOpacity(0.1),
                    stat.color.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: stat.color.withOpacity(0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(stat.icon, color: stat.color, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    stat.value.toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stat.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stat.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
            .animate(delay: (index * 100).ms)
            .scale(duration: 500.ms, curve: Curves.easeOut)
            .fadeIn();
      },
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;
}
