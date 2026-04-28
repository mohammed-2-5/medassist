import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Compact 3-pill glance row: Taken · Overdue · Upcoming.
class StatusPillsRow extends ConsumerWidget {
  const StatusPillsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final doses = ref.watch(todayDosesProvider);
    final overdueCount = ref.watch(overdueDosesProvider).length;

    final taken = doses.where((d) => d.status == DoseStatus.taken).length;
    final total = doses.length;
    final upcoming = doses.where((d) => d.status == DoseStatus.pending).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _Pill(
              icon: Icons.check_circle_rounded,
              label: l10n.taken,
              value: '$taken/$total',
              fg: cs.primary,
              bg: cs.primaryContainer.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Pill(
              icon: Icons.warning_amber_rounded,
              label: l10n.overdue,
              value: '$overdueCount',
              fg: cs.error,
              bg: cs.errorContainer.withOpacity(0.45),
              muted: overdueCount == 0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Pill(
              icon: Icons.schedule_rounded,
              label: l10n.upcoming,
              value: '$upcoming',
              fg: cs.tertiary,
              bg: cs.tertiaryContainer.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.value,
    required this.fg,
    required this.bg,
    this.muted = false,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color fg;
  final Color bg;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final useFg = muted ? cs.onSurfaceVariant : fg;
    final useBg = muted ? cs.surfaceContainerHighest.withOpacity(0.6) : bg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: useBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: useFg),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: useFg,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: useFg.withOpacity(0.85),
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
