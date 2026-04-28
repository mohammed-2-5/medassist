import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/dose_unit_localizer.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Row of stat chips: stock remaining, today adherence, next dose time.
///
/// Chips stagger in with a fade+slide animation on first build.
class MedicationStatChips extends ConsumerStatefulWidget {
  const MedicationStatChips({required this.medication, super.key});

  final Medication medication;

  @override
  ConsumerState<MedicationStatChips> createState() =>
      _MedicationStatChipsState();
}

class _MedicationStatChipsState extends ConsumerState<MedicationStatChips>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _animatedChip(Widget chip, int index) {
    final start = index * 0.2;
    final end = (start + 0.6).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
      parent: _ctrl,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(curve),
        child: chip,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final medication = widget.medication;
    final todayDoses = ref
        .watch(todayDosesProvider)
        .where((d) => d.medicationId == medication.id.toString())
        .toList();

    final taken = todayDoses.where((d) => d.status == DoseStatus.taken).length;
    final total = todayDoses.length;
    final nextPending = todayDoses
        .where((d) => d.status == DoseStatus.pending)
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _animatedChip(
              _StatChip(
                icon: Icons.inventory_2_outlined,
                label: l10n.stock,
                value: '${medication.stockQuantity}',
                suffix: localizeDoseUnit(l10n, medication.doseUnit),
              ),
              0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _animatedChip(
              _StatChip(
                icon: Icons.check_circle_outline,
                label: l10n.today,
                value: '$taken/$total',
              ),
              1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _animatedChip(
              _StatChip(
                icon: Icons.access_time,
                label: l10n.nextDose,
                value: nextPending?.time ?? '—',
              ),
              2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    this.suffix,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: cs.primary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            suffix != null ? '$value $suffix' : value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
