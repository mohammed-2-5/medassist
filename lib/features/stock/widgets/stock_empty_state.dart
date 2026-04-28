import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/widgets/empty_state_widget.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Empty state for the Stock Overview screen.
class StockEmptyState extends StatelessWidget {
  const StockEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyStateWidget(
      icon: Icons.inventory_2_outlined,
      title: l10n.noMedications,
      subtitle: l10n.addMedicationsToTrackStock,
      actionLabel: l10n.addMedicine,
      onAction: () => context.push('/add-reminder'),
    );
  }
}
