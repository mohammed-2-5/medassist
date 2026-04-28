import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Card showing current and best adherence streaks.
class AnalyticsStreakCard extends ConsumerWidget {
  const AnalyticsStreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return ref
        .watch(streakInfoProvider)
        .when(
          data: (streak) => Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            color: colorScheme.primaryContainer,
            child: InkWell(
              onTap: () => context.push('/history'),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < 360;
                    final labelStyle = Theme.of(context).textTheme.titleMedium
                        ?.copyWith(
                          fontSize: isCompact ? 14 : null,
                        );
                    final valueStyle = Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 22 : null,
                          color: colorScheme.onPrimaryContainer,
                        );

                    Widget buildSection({
                      required IconData icon,
                      required Color iconColor,
                      required String label,
                      required String value,
                    }) {
                      return FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  icon,
                                  color: iconColor,
                                  size: isCompact ? 24 : 28,
                                ),
                                const SizedBox(width: 8),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isCompact ? 120 : double.infinity,
                                  ),
                                  child: Text(
                                    label,
                                    style: labelStyle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(value, style: valueStyle),
                          ],
                        ),
                      );
                    }

                    final current = buildSection(
                      icon: Icons.local_fire_department,
                      iconColor: Colors.orange,
                      label: l10n.currentStreak,
                      value: l10n.daysCount(streak.currentStreak),
                    );
                    final best = buildSection(
                      icon: Icons.emoji_events,
                      iconColor: Colors.amber,
                      label: l10n.bestStreak,
                      value: l10n.daysCount(streak.bestStreak),
                    );

                    return IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(child: current),
                          Container(
                            height: double.infinity,
                            width: 1,
                            color: colorScheme.onPrimaryContainer.withOpacity(
                              0.3,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: best),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          loading: () => const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (err, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('${l10n.errorLoadingStreak}: $err'),
            ),
          ),
        );
  }
}
