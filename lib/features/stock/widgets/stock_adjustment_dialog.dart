import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Dialog for adjusting medication stock
class StockAdjustmentDialog extends ConsumerStatefulWidget {
  const StockAdjustmentDialog({
    required this.medication,
    required this.currentStock,
    required this.onAdjusted,
    super.key,
  });
  final Medication medication;
  final int currentStock;
  final VoidCallback onAdjusted;

  @override
  ConsumerState<StockAdjustmentDialog> createState() =>
      _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  late TextEditingController _stockController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(
      text: widget.currentStock.toString(),
    );
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.adjustStock),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medication info
            Text(
              widget.medication.medicineName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.medication.medicineType,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            // Current stock display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.currentStockLabel,
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${widget.currentStock} ${widget.medication.doseUnit}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // New stock input
            TextField(
              controller: _stockController,
              decoration: InputDecoration(
                labelText: l10n.newStockAmount,
                suffixText: widget.medication.doseUnit,
                helperText: l10n.enterUpdatedStockQuantity,
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              autofocus: true,
            ),

            const SizedBox(height: 16),

            // Quick adjustment buttons
            Text(
              l10n.quickAdjustments,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQuickButton('+10'),
                _buildQuickButton('+30'),
                _buildQuickButton('+60'),
                _buildQuickButton('-10'),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveStock,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.onPrimary,
                    ),
                  ),
                )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label) {
    return OutlinedButton(
      onPressed: () {
        final currentValue =
            int.tryParse(_stockController.text) ?? widget.currentStock;
        final adjustment = int.parse(label);
        final newValue = (currentValue + adjustment).clamp(0, 9999);
        _stockController.text = newValue.toString();
      },
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(60, 36),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Text(label),
    );
  }

  Future<void> _saveStock() async {
    final newStock = int.tryParse(_stockController.text);

    final l10n = AppLocalizations.of(context)!;

    if (newStock == null || newStock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseEnterValidStock),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(medicationRepositoryProvider);
      await repository.updateStockQuantity(widget.medication.id, newStock);

      if (!mounted) return;

      ProviderRefreshUtils.refreshStockProviders(ref);
      Navigator.of(context).pop();
      widget.onAdjusted();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.stockUpdatedTo(newStock, widget.medication.doseUnit),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorUpdatingStock(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
