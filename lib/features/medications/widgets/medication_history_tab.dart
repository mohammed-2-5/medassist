import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/medications/widgets/medication_history_heatmap.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationHistoryTab extends ConsumerStatefulWidget {
  const MedicationHistoryTab({required this.medicationId, super.key});

  final int medicationId;

  @override
  ConsumerState<MedicationHistoryTab> createState() =>
      _MedicationHistoryTabState();
}

class _MedicationHistoryTabState extends ConsumerState<MedicationHistoryTab>
    with SingleTickerProviderStateMixin {
  AnimationController? _ctrl;

  void _initAnimation(int itemCount) {
    if (_ctrl != null) return;
    final duration = Duration(milliseconds: 300 + itemCount.clamp(0, 20) * 50);
    _ctrl = AnimationController(vsync: this, duration: duration)..forward();
  }

  @override
  void dispose() {
    _ctrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<DoseHistoryData>>(
      future: ref.read(appDatabaseProvider).getDoseHistory(widget.medicationId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noDoseHistoryYet,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }
        final history = snapshot.data!;
        _initAnimation(history.length);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length + 1,
          itemBuilder: (context, rawIndex) {
            if (rawIndex == 0) {
              return MedicationHistoryHeatmap(history: history);
            }
            final index = rawIndex - 1;
            final item = _HistoryItem(record: history[index]);
            if (_ctrl == null) return item;
            final start = (index * 0.05).clamp(0.0, 0.8);
            final end = (start + 0.2).clamp(0.0, 1.0);
            final curve = CurvedAnimation(
              parent: _ctrl!,
              curve: Interval(start, end, curve: Curves.easeOut),
            );
            return FadeTransition(
              opacity: curve,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(curve),
                child: item,
              ),
            );
          },
        );
      },
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.record});

  final DoseHistoryData record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = switch (record.status) {
      'taken' => colorScheme.primary,
      'skipped' => colorScheme.onSurfaceVariant,
      'missed' => colorScheme.error,
      'snoozed' => colorScheme.tertiary,
      _ => colorScheme.onSurfaceVariant,
    };
    final statusIcon = switch (record.status) {
      'taken' => Icons.check_circle,
      'skipped' => Icons.do_not_disturb_on,
      'missed' => Icons.error,
      'snoozed' => Icons.snooze,
      _ => Icons.help_outline,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(record.scheduledDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${record.scheduledHour.toString().padLeft(2, '0')}:'
                  '${record.scheduledMinute.toString().padLeft(2, '0')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              record.status.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
