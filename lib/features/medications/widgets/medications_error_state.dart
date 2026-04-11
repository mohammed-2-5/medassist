import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Error state shown in the medications list when loading fails.
class MedicationsErrorState extends StatelessWidget {
  const MedicationsErrorState({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text(
            l10n.errorMessage(error.toString()),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
