import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Time-aware greeting with compact today-adherence ring.
class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final adherence = ref.watch(adherenceSummaryProvider).value;

    final hour = DateTime.now().hour;
    final greet = _greetingFor(hour, l10n);
    final subtitle = _subtitleFor(
      taken: adherence?.takenToday ?? 0,
      total: adherence?.totalToday ?? 0,
      hour: hour,
      l10n: l10n,
    );

    final taken = adherence?.takenToday ?? 0;
    final total = adherence?.totalToday ?? 0;
    final progress = total > 0 ? (taken / total).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greet,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          _AdherenceRing(progress: progress, taken: taken, total: total),
        ],
      ),
    );
  }

  String _greetingFor(int hour, AppLocalizations l10n) {
    if (hour < 12) return l10n.goodMorning;
    if (hour < 17) return l10n.goodAfternoon;
    if (hour < 22) return l10n.goodEvening;
    return l10n.goodNight;
  }

  String _subtitleFor({
    required int taken,
    required int total,
    required int hour,
    required AppLocalizations l10n,
  }) {
    if (total == 0) return l10n.letsStartDay;
    if (taken >= total) return l10n.greatJobToday;
    if (hour < 10) return l10n.letsStartDay;
    return l10n.dosesTakenOf(taken, total);
  }
}

class _AdherenceRing extends StatelessWidget {
  const _AdherenceRing({
    required this.progress,
    required this.taken,
    required this.total,
  });
  final double progress;
  final int taken;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final percent = total > 0 ? (progress * 100).round() : 0;

    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CircularProgressIndicator(
              value: total > 0 ? progress : 0,
              strokeWidth: 5,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(cs.primary),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            total > 0 ? '$percent%' : '—',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
