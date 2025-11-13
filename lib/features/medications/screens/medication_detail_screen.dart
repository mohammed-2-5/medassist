import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Modern Medication Detail Screen with comprehensive information
class MedicationDetailScreen extends ConsumerStatefulWidget {

  const MedicationDetailScreen({
    this.medicationId,
    super.key,
  });
  final int? medicationId;

  @override
  ConsumerState<MedicationDetailScreen> createState() =>
      _MedicationDetailScreenState();
}

class _MedicationDetailScreenState
    extends ConsumerState<MedicationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: colorScheme.error,
                  ),
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
          body: CustomScrollView(
            slivers: [
              // App Bar with Medication Header
              _buildAppBar(theme, colorScheme, medication, l10n),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Section
                    _buildOverviewSection(theme, colorScheme, medication, l10n),

                    const SizedBox(height: 16),

                    // Tabs for History and Info
                    _buildTabsSection(theme, colorScheme, medication, l10n),
                  ],
                ),
              ),
            ],
          ),

          // Action Button
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                context.push('/medication/${widget.medicationId}/edit'),
            icon: const Icon(Icons.edit),
            label: Text(l10n.edit),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(
    ThemeData theme,
    ColorScheme colorScheme,
    Medication medication,
    AppLocalizations l10n,
  ) {
    final medicineType = MedicineType.values.firstWhere(
      (type) => type.name == medication.medicineType,
      orElse: () => MedicineType.pill,
    );

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primaryContainer,
                colorScheme.secondaryContainer,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Medicine Icon
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            medicineType.label.split(' ')[0],
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Name and Type
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.medicineName,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              medicineType.label.substring(2),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer
                                    .withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      _buildStatusBadge(theme, medication, l10n),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'toggle':
                _toggleActive(medication);
              case 'delete':
                _deleteMedication();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    medication.isActive ? Icons.pause : Icons.play_arrow,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(medication.isActive ? l10n.pause : l10n.resume),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(l10n.delete, style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme, Medication medication, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: medication.isActive
            ? Colors.green.withOpacity(0.9)
            : Colors.orange.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        medication.isActive ? l10n.active : l10n.paused,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildOverviewSection(
    ThemeData theme,
    ColorScheme colorScheme,
    Medication medication,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dosage Card
          _buildInfoCard(
            theme,
            colorScheme,
            icon: Icons.medication,
            title: l10n.dosage,
            children: [
              _buildInfoRow(
                l10n.strength,
                '${medication.strength} ${medication.unit}',
                theme,
              ),
              _buildInfoRow(
                l10n.perDose,
                '${medication.dosePerTime} ${medication.doseUnit}',
                theme,
              ),
              _buildInfoRow(
                l10n.frequency,
                '${medication.timesPerDay}x per day',
                theme,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Schedule Card
          _buildInfoCard(
            theme,
            colorScheme,
            icon: Icons.schedule,
            title: l10n.schedule,
            children: [
              _buildInfoRow(
                l10n.duration,
                '${medication.durationDays} days',
                theme,
              ),
              _buildInfoRow(
                l10n.started,
                DateFormat('MMM dd, yyyy').format(medication.startDate),
                theme,
              ),
              _buildInfoRow(
                l10n.ends,
                DateFormat('MMM dd, yyyy').format(
                  medication.startDate
                      .add(Duration(days: medication.durationDays)),
                ),
                theme,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stock Card with Visual Indicator
          _buildStockCard(theme, colorScheme, medication, l10n),

          if (medication.notes != null && medication.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              theme,
              colorScheme,
              icon: Icons.notes,
              title: l10n.notes,
              children: [
                Text(
                  medication.notes!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    ColorScheme colorScheme, {
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard(
    ThemeData theme,
    ColorScheme colorScheme,
    Medication medication,
    AppLocalizations l10n,
  ) {
    final dailyUsage = medication.dosePerTime * medication.timesPerDay;
    final daysRemaining = medication.stockQuantity > 0
        ? (medication.stockQuantity / dailyUsage).floor()
        : 0;

    final stockPercentage = medication.stockQuantity > 0
        ? (daysRemaining / medication.durationDays).clamp(0.0, 1.0)
        : 0.0;

    final stockColor = daysRemaining > 7
        ? Colors.green
        : daysRemaining > 3
            ? Colors.orange
            : Colors.red;

    return Container(
      decoration: BoxDecoration(
        color: stockColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: stockColor.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, size: 20, color: stockColor),
              const SizedBox(width: 8),
              Text(
                l10n.stockStatus,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${medication.stockQuantity} ${medication.doseUnit}s',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stockColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.available,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$daysRemaining days',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stockColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.remaining,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stockPercentage,
              minHeight: 12,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(stockColor),
            ),
          ),
          if (daysRemaining <= 3) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.lowStockAlert,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTabsSection(
    ThemeData theme,
    ColorScheme colorScheme,
    Medication medication,
    AppLocalizations l10n,
  ) {
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
            controller: _tabController,
            tabs: [
              Tab(text: l10n.history),
              Tab(text: l10n.reminders),
            ],
          ),
        ),
        SizedBox(
          height: 400,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHistoryTab(theme, colorScheme, medication, l10n),
              _buildRemindersTab(theme, colorScheme, medication, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(
    ThemeData theme,
    ColorScheme colorScheme,
    Medication medication,
    AppLocalizations l10n,
  ) {
    return FutureBuilder<List<DoseHistoryData>>(
      future: ref.read(appDatabaseProvider).getDoseHistory(medication.id),
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
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final record = history[index];
            return _buildHistoryItem(theme, colorScheme, record);
          },
        );
      },
    );
  }

  Widget _buildHistoryItem(
    ThemeData theme,
    ColorScheme colorScheme,
    DoseHistoryData record,
  ) {
    final statusColor = switch (record.status) {
      'taken' => Colors.green,
      'skipped' => Colors.grey,
      'missed' => Colors.red,
      'snoozed' => Colors.amber,
      _ => Colors.grey,
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
        border: Border.all(
          color: statusColor.withOpacity(0.3),
        ),
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
                  '${record.scheduledHour.toString().padLeft(2, '0')}:${record.scheduledMinute.toString().padLeft(2, '0')}',
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

  Widget _buildRemindersTab(
    ThemeData theme,
    ColorScheme colorScheme,
    Medication medication,
    AppLocalizations l10n,
  ) {
    return FutureBuilder<List<ReminderTime>>(
      future: ref.read(appDatabaseProvider).getReminderTimes(medication.id),
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
                  Icons.notifications_off,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.noRemindersSet,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        final reminders = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return _buildReminderItem(theme, colorScheme, reminder, index, l10n);
          },
        );
      },
    );
  }

  Widget _buildReminderItem(
    ThemeData theme,
    ColorScheme colorScheme,
    ReminderTime reminder,
    int index,
    AppLocalizations l10n,
  ) {
    final timeString =
        '${reminder.hour.toString().padLeft(2, '0')}:${reminder.minute.toString().padLeft(2, '0')}';

    final period = reminder.hour >= 6 && reminder.hour < 12
        ? 'Morning'
        : reminder.hour >= 12 && reminder.hour < 18
            ? 'Afternoon'
            : reminder.hour >= 18 && reminder.hour < 23
                ? 'Evening'
                : 'Night';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeString,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  period,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.dose(index + 1),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(Medication medication) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final database = ref.read(appDatabaseProvider);
      final updated = medication.copyWith(isActive: !medication.isActive);
      await database.updateMedication(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              medication.isActive
                  ? l10n.medicationPaused
                  : l10n.medicationResumed,
            ),
          ),
        );

        // Refresh UI
        setState(() {});
        ProviderRefreshUtils.refreshMedicationDetail(ref, widget.medicationId!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteMedication() async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteMedicationQuestion),
        content: Text(l10n.deleteMedicationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed ?? false && mounted) {
      try {
        final repository = ref.read(medicationRepositoryProvider);
        await repository.deleteMedication(widget.medicationId!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.medicationDeleted),
              backgroundColor: Colors.green,
            ),
          );

          // Refresh all medication providers
          ProviderRefreshUtils.refreshAllMedicationProviders(ref);

          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorDeletingMedication(e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
