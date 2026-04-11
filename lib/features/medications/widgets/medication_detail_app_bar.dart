import 'dart:io';

import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationDetailAppBar extends StatelessWidget {
  const MedicationDetailAppBar({
    required this.medication,
    required this.onToggleActive,
    required this.onDelete,
    super.key,
  });

  final Medication medication;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
              child: Row(
                children: [
                  _MedicationIcon(
                    medication: medication,
                    medicineType: medicineType,
                    colorScheme: colorScheme,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                          medicineType.label.length > 2
                              ? medicineType.label.substring(2)
                              : medicineType.label,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color:
                                colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _StatusBadge(medication: medication, theme: theme, l10n: l10n),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            switch (value) {
              case 'toggle':
                onToggleActive();
              case 'delete':
                onDelete();
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
                  Text(
                    l10n.delete,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MedicationIcon extends StatelessWidget {
  const _MedicationIcon({
    required this.medication,
    required this.medicineType,
    required this.colorScheme,
  });

  final Medication medication;
  final MedicineType medicineType;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: medication.medicinePhotoPath != null &&
              File(medication.medicinePhotoPath!).existsSync()
          ? Image.file(
              File(medication.medicinePhotoPath!),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            )
          : Container(
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
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.medication,
    required this.theme,
    required this.l10n,
  });

  final Medication medication;
  final ThemeData theme;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
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
}
