import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/providers/home_providers.dart';
import 'package:med_assist/features/medications/screens/medication_detail_tabs_section.dart';
import 'package:med_assist/features/medications/utils/medication_actions.dart';
import 'package:med_assist/features/medications/widgets/medication_detail_app_bar.dart';
import 'package:med_assist/features/medications/widgets/medication_stat_chips.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Modern Medication Detail Screen with comprehensive information
class MedicationDetailScreen extends ConsumerStatefulWidget {
  const MedicationDetailScreen({this.medicationId, super.key});

  final int? medicationId;

  @override
  ConsumerState<MedicationDetailScreen> createState() =>
      _MedicationDetailScreenState();
}

class _MedicationDetailScreenState extends ConsumerState<MedicationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (widget.medicationId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.medicationDetails)),
        body: Center(child: Text(l10n.medicationNotFound)),
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Medication?>(
      future: ref
          .read(appDatabaseProvider)
          .getMedicationById(widget.medicationId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.medicationDetails)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.medicationDetails)),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(l10n.medicationNotFound),
                ],
              ),
            ),
          );
        }

        final medication = snapshot.data!;

        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              MedicationDetailAppBar(
                medication: medication,
                onEdit: () =>
                    context.push('/medication/${widget.medicationId}/edit'),
                onToggleActive: () => MedicationActions.toggleActive(
                  context: context,
                  ref: ref,
                  medication: medication,
                  onRefresh: () => setState(() {}),
                ),
                onDelete: () => MedicationActions.delete(
                  context: context,
                  ref: ref,
                  medicationId: widget.medicationId!,
                  popOnComplete: true,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                  child: MedicationStatChips(medication: medication),
                ),
              ),
            ],
            body: MedicationDetailTabsSection(
              tabController: _tabController,
              medication: medication,
            ),
          ),
          floatingActionButton: _LogDoseFab(
            medicationId: widget.medicationId!,
          ),
        );
      },
    );
  }
}

class _LogDoseFab extends ConsumerWidget {
  const _LogDoseFab({required this.medicationId});

  final int medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final idStr = medicationId.toString();
    final nextPending = ref
        .watch(todayDosesProvider)
        .where(
          (d) => d.medicationId == idStr && d.status == DoseStatus.pending,
        )
        .firstOrNull;

    return FloatingActionButton.extended(
      heroTag: 'detail_fab',
      onPressed: nextPending == null
          ? null
          : () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref
                  .read(todayDosesProvider.notifier)
                  .markAsTaken(nextPending.id);
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.takeDose)),
              );
            },
      icon: const Icon(Icons.check_circle_outline),
      label: Text(nextPending == null ? l10n.allCaughtUp : l10n.takeNow),
    );
  }
}
