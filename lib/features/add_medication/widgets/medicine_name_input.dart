import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Medicine name text field with scan and barcode action buttons.
class MedicineNameInput extends StatelessWidget {
  const MedicineNameInput({
    required this.controller,
    required this.onChanged,
    required this.onScanName,
    required this.onScanBarcode,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onScanName;
  final VoidCallback onScanBarcode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.medicineNameHint,
              prefixIcon: Icon(Icons.medication, color: colorScheme.primary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterMedicineName;
              }
              return null;
            },
            onChanged: onChanged,
          ),
          _ActionButtonsRow(
            onScanName: onScanName,
            onScanBarcode: onScanBarcode,
          ),
        ],
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow({
    required this.onScanName,
    required this.onScanBarcode,
  });

  final VoidCallback onScanName;
  final VoidCallback onScanBarcode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: Border(
          top: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onScanName,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt,
                        size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.scanName,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: InkWell(
              onTap: onScanBarcode,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code_scanner,
                        size: 20, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.scanBarcode,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
