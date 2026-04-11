import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Card showing the best time of day for medication adherence.
class AnalyticsBestTimeCard extends ConsumerWidget {
  const AnalyticsBestTimeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<String>(
      future: ref.read(analyticsProvider).getBestTimeOfDay(),
      builder: (context, snapshot) {
        final bestTime = snapshot.data ?? l10n.loading;
        return Card(
          margin: EdgeInsets.zero,
          child: ListTile(
            leading: Icon(
              Icons.access_time,
              color: colorScheme.primary,
              size: 32,
            ),
            title: Text(
              l10n.bestTimeForAdherence,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              bestTime,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            trailing: Icon(
              Icons.info_outline,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
