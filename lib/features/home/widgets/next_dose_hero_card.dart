import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/models/dose_result.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/features/home/widgets/next_dose_caught_up_card.dart';
import 'package:med_assist/features/home/widgets/snooze_options_dialog.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Hero card showing the next upcoming dose with live countdown and CTAs.
///
/// When no pending doses remain for today, shows an "all caught up" state.
class NextDoseHeroCard extends ConsumerStatefulWidget {
  const NextDoseHeroCard({super.key});

  @override
  ConsumerState<NextDoseHeroCard> createState() => _NextDoseHeroCardState();
}

class _NextDoseHeroCardState extends ConsumerState<NextDoseHeroCard>
    with SingleTickerProviderStateMixin {
  Timer? _ticker;
  DateTime _now = DateTime.now();
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final next = ref.watch(nextDoseProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (next == null) {
      return const NextDoseCaughtUpCard();
    }

    final scheduled = doseScheduledDateTime(next.time, _now);
    final diff = scheduled.difference(_now);
    final statusText = _buildStatusText(diff, l10n);
    final isOverdue = diff.isNegative && diff.inMinutes.abs() >= 1;
    final isDueSoon = !diff.isNegative && diff.inMinutes < 15;
    final gradient = isOverdue ? AppColors.warningGradient : cs.primaryGradient;

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final pulse = _pulseCtrl.value;
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cs.primary.withOpacity(
                      isDueSoon ? 0.20 + pulse * 0.20 : 0.25,
                    ),
                    blurRadius: isDueSoon ? 16 + pulse * 10 : 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.push('/medication/${next.medicationId}');
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeroHeader(
                        label: l10n.nextDose,
                        statusText: statusText,
                        isDueSoon: isDueSoon,
                        pulse: pulse,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        next.medicationName,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${next.dosage} • ${next.time}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _HeroActions(dose: next),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _buildStatusText(Duration diff, AppLocalizations l10n) {
    if (diff.inMinutes == 0) return l10n.dueNow;
    if (diff.isNegative) {
      final mins = diff.inMinutes.abs();
      if (mins < 60) return l10n.overdueByMinutes(mins);
      final h = mins ~/ 60;
      final m = mins % 60;
      return l10n.overdueByHours(h, m);
    }
    final mins = diff.inMinutes;
    if (mins < 60) return l10n.dueInMinutes(mins);
    final h = mins ~/ 60;
    final m = mins % 60;
    return l10n.dueInHours(h, m);
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.label,
    required this.statusText,
    this.isDueSoon = false,
    this.pulse = 0,
  });
  final String label;
  final String statusText;
  final bool isDueSoon;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeScale = isDueSoon ? 1.0 + pulse * 0.06 : 1.0;
    return Row(
      children: [
        Icon(Icons.medication, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Transform.scale(
          scale: badgeScale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDueSoon ? 0.35 : 0.2),
              borderRadius: BorderRadius.circular(12),
              border: isDueSoon
                  ? Border.all(color: Colors.white.withOpacity(0.5))
                  : null,
            ),
            child: Text(
              statusText,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroActions extends ConsumerWidget {
  const _HeroActions({required this.dose});
  final DoseEvent dose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Theme.of(context).colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              unawaited(_takeDose(context, ref));
            },
            icon: const Icon(Icons.check_circle),
            label: Text(
              l10n.takeNow,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(
                color: Colors.white.withOpacity(0.6),
                width: 1.5,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              unawaited(_snoozeDose(context, ref));
            },
            icon: const Icon(Icons.snooze),
            label: Text(
              l10n.snooze,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _takeDose(BuildContext context, WidgetRef ref) async {
    HapticFeedback.mediumImpact();
    final result = await ref
        .read(todayDosesProvider.notifier)
        .markAsTaken(dose.id);
    if (!context.mounted) return;
    if (result is DoseOperationFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.message)),
      );
    }
  }

  Future<void> _snoozeDose(BuildContext context, WidgetRef ref) async {
    HapticFeedback.selectionClick();
    final minutes = await showDialog<int>(
      context: context,
      builder: (_) => SnoozeOptionsDialog(medicationName: dose.medicationName),
    );
    if (minutes == null) return;
    await ref
        .read(todayDosesProvider.notifier)
        .snoozeDose(dose.id, minutes: minutes);
  }
}
