import 'dart:io';

import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/utils/medicine_type_style.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationDetailAppBar extends StatelessWidget {
  const MedicationDetailAppBar({
    required this.medication,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
    super.key,
  });

  final Medication medication;
  final VoidCallback onEdit;
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
      expandedHeight: 240,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Gradient background
            DecoratedBox(
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
            ),
            // Layer 2: Decorative circles
            Positioned(
              top: -30,
              right: -20,
              child: _DecoCircle(
                size: 120,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Positioned(
              bottom: 20,
              left: -40,
              child: _DecoCircle(
                size: 100,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            // Layer 3: Bottom gradient overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      colorScheme.primary.withOpacity(0.25),
                    ],
                  ),
                ),
              ),
            ),
            // Layer 4: Content
            SafeArea(
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
                            medicineType.localizedLabel(l10n),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer.withOpacity(
                                0.8,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _StatusBadge(
                      medication: medication,
                      theme: theme,
                      l10n: l10n,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          tooltip: l10n.edit,
          icon: const Icon(Icons.edit_outlined),
          onPressed: onEdit,
        ),
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
    final inner = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child:
          medication.medicinePhotoPath != null &&
              File(medication.medicinePhotoPath!).existsSync()
          ? Image.file(
              File(medication.medicinePhotoPath!),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            )
          : Container(
              width: 80,
              height: 80,
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
                  medicineType.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
    );
    return Hero(tag: 'med-icon-${medication.id}', child: inner);
  }
}

class _DecoCircle extends StatelessWidget {
  const _DecoCircle({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: medication.isActive ? cs.tertiary : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        medication.isActive ? l10n.active : l10n.paused,
        style: theme.textTheme.labelSmall?.copyWith(
          color: medication.isActive ? cs.onTertiary : cs.onSecondaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
