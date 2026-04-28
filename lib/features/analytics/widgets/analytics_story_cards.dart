import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Horizontal row of three story cards: streak, best time, most missed.
class AnalyticsStoryCards extends ConsumerWidget {
  const AnalyticsStoryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final streakAsync = ref.watch(streakInfoProvider);
    final insightsAsync = ref.watch(medicationInsightsProvider);

    return SizedBox(
      height: 140,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          _StoryCard(
            icon: Icons.local_fire_department,
            label: l10n.dayStreak,
            gradient: AppColors.warningGradient,
            child: _StoryValueText(
              text: streakAsync.when(
                data: (s) => '${s.currentStreak}',
                loading: () => '…',
                error: (_, _) => '—',
              ),
            ),
          ),
          const SizedBox(width: 12),
          _StoryCard(
            icon: Icons.access_time_rounded,
            label: l10n.bestTime,
            gradient: cs.primaryGradient,
            child: FutureBuilder<String>(
              future: ref.read(analyticsProvider).getBestTimeOfDay(),
              builder: (_, snap) => _StoryValueText(
                text: snap.data ?? (snap.hasError ? '—' : '…'),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _StoryCard(
            icon: Icons.trending_down,
            label: l10n.mostMissed,
            gradient: cs.tertiaryGradient,
            child: _StoryValueText(
              text: insightsAsync.when(
                data: (list) {
                  final sorted = [
                    ...list,
                  ]..sort((a, b) => a.adherenceRate.compareTo(b.adherenceRate));
                  return sorted.firstOrNull?.medicationName ?? l10n.noData;
                },
                loading: () => '…',
                error: (_, _) => '—',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryValueText extends StatelessWidget {
  const _StoryValueText({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        maxLines: 1,
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.child,
  });

  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }
}
