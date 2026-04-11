import 'package:flutter/material.dart';
import 'package:med_assist/features/medications/widgets/medication_history_tab.dart';
import 'package:med_assist/features/medications/widgets/medication_reminders_tab.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Tabs section shown at the bottom of the medication detail screen.
///
/// Contains History and Reminders tabs.
class MedicationDetailTabsSection extends StatelessWidget {
  const MedicationDetailTabsSection({
    required this.tabController,
    required this.medicationId,
    super.key,
  });

  final TabController tabController;
  final int medicationId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant),
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: TabBar(
            controller: tabController,
            tabs: [
              Tab(text: l10n.history),
              Tab(text: l10n.reminders),
            ],
          ),
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: tabController,
            children: [
              MedicationHistoryTab(medicationId: medicationId),
              MedicationRemindersTab(medicationId: medicationId),
            ],
          ),
        ),
      ],
    );
  }
}
