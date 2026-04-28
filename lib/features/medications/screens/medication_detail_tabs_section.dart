import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/medications/widgets/medication_detail_drug_info_card.dart';
import 'package:med_assist/features/medications/widgets/medication_history_tab.dart';
import 'package:med_assist/features/medications/widgets/medication_persisted_interactions.dart';
import 'package:med_assist/features/medications/widgets/medication_schedule_tab.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Four-tab section for the medication detail screen.
///
/// Tabs: Schedule | History | Notes | Interactions.
class MedicationDetailTabsSection extends StatelessWidget {
  const MedicationDetailTabsSection({
    required this.tabController,
    required this.medication,
    super.key,
  });

  final TabController tabController;
  final Medication medication;

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
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(
                icon: const Icon(Icons.schedule, size: 18),
                text: l10n.schedule,
              ),
              Tab(
                icon: const Icon(Icons.history, size: 18),
                text: l10n.history,
              ),
              Tab(
                icon: const Icon(Icons.notes, size: 18),
                text: l10n.notes,
              ),
              Tab(
                icon: const Icon(Icons.science_outlined, size: 18),
                text: l10n.drugInteractions,
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              MedicationScheduleTab(medication: medication),
              MedicationHistoryTab(medicationId: medication.id),
              _NotesTab(medication: medication),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MedicationPersistedInteractions(
                      medicationId: medication.id,
                    ),
                    MedicationDetailDrugInfoCard(medication: medication),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotesTab extends StatelessWidget {
  const _NotesTab({required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final notes = medication.notes;

    if (notes == null || notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notes_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noNotes,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(notes, style: theme.textTheme.bodyMedium),
      ),
    );
  }
}
