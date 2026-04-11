import 'dart:io';

import 'package:flutter/material.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';

class MedicationCardIcon extends StatelessWidget {
  const MedicationCardIcon({
    required this.medication,
    required this.colorScheme,
    super.key,
  });

  final Medication medication;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final medicineType = MedicineType.values.firstWhere(
      (type) => type.name == medication.medicineType,
      orElse: () => MedicineType.pill,
    );

    final photoPath = medication.medicinePhotoPath;
    if (photoPath != null && File(photoPath).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(photoPath),
          width: 52,
          height: 52,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: medication.isActive
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        medicineType.label.contains(' ')
            ? medicineType.label.split(' ')[0]
            : medicineType.label,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }
}
