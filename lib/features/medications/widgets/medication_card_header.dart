import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/utils/medicine_type_style.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationCardHeader extends StatelessWidget {
  const MedicationCardHeader({
    required this.medication,
    required this.theme,
    required this.colorScheme,
    super.key,
  });

  final Medication medication;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            medication.medicineName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: medication.isActive
                  ? colorScheme.onSurface
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          _MedicationTypeBadge(
            medication: medication,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }
}

class _MedicationTypeBadge extends StatelessWidget {
  const _MedicationTypeBadge({
    required this.medication,
    required this.theme,
    required this.colorScheme,
  });

  final Medication medication;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getMedicineTypeLabel(context),
        style: theme.textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getMedicineTypeLabel(BuildContext context) {
    final medicineType = MedicineType.values.firstWhere(
      (type) => type.name == medication.medicineType,
      orElse: () => MedicineType.pill,
    );
    return medicineType.localizedLabel(AppLocalizations.of(context)!);
  }
}

class MedicationStatusChip extends StatelessWidget {
  const MedicationStatusChip({
    required this.isActive,
    required this.theme,
    super.key,
  });

  final bool isActive;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.green.withOpacity(0.1)
              : Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? Colors.green : Colors.orange,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isActive
                  ? AppLocalizations.of(context)!.active
                  : AppLocalizations.of(context)!.paused,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
