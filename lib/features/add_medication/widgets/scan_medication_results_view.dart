import 'package:flutter/material.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_confidence_card.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_error_view.dart';
import 'package:med_assist/features/add_medication/widgets/scan_medication_result_field.dart';
import 'package:med_assist/services/ocr/ocr_service.dart';

class ScanMedicationResultsView extends StatelessWidget {
  const ScanMedicationResultsView({
    required this.scanResult,
    required this.confidence,
    required this.onScanAgain,
    required this.onUseDetails,
    super.key,
  });

  final MedicationScanResult scanResult;
  final double confidence;
  final VoidCallback onScanAgain;
  final VoidCallback onUseDetails;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (!scanResult.success) {
      return ScanMedicationErrorView(
        errorColor: colorScheme.error,
        errorMessage:
            scanResult.errorMessage ?? 'Unable to extract medication details',
        onTryAgain: onScanAgain,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScanMedicationConfidenceCard(confidence: confidence),
          const SizedBox(height: 24),
          Text('Extracted Information:', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          ScanMedicationResultField(
            label: 'Medication Name',
            value: scanResult.medicationName,
            icon: Icons.medication,
          ),
          ScanMedicationResultField(
            label: 'Strength',
            value: '${scanResult.strength ?? ''} ${scanResult.unit ?? ''}'
                .trim(),
            icon: Icons.science,
          ),
          ScanMedicationResultField(
            label: 'Dosage Form',
            value: scanResult.dosageForm,
            icon: Icons.category,
          ),
          ScanMedicationResultField(
            label: 'Manufacturer',
            value: scanResult.manufacturer,
            icon: Icons.business,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onScanAgain,
                  child: const Text('Scan Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onUseDetails,
                  child: const Text('Use Details'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
