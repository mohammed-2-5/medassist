import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';

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
  ConsumerState<StockAdjustmentDialog> createState() => _StockAdjustmentDialogState();
}

class _StockAdjustmentDialogState extends ConsumerState<StockAdjustmentDialog> {
  late TextEditingController _stockController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.currentStock.toString());
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

    return AlertDialog(
      title: const Text('Adjust Stock'),
      content: Column(
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
                  'Current Stock:',
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
              labelText: 'New Stock Amount',
              suffixText: widget.medication.doseUnit,
              border: const OutlineInputBorder(),
              helperText: 'Enter the updated stock quantity',
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
            'Quick Adjustments:',
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildQuickButton('+10'),
              _buildQuickButton('+30'),
              _buildQuickButton('+60'),
              _buildQuickButton('-10'),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
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
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildQuickButton(String label) {
    return OutlinedButton(
      onPressed: () {
        final currentValue = int.tryParse(_stockController.text) ?? widget.currentStock;
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

    if (newStock == null || newStock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid stock amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final database = ref.read(appDatabaseProvider);

      // Update medication with new stock
      final updatedMedication = widget.medication.copyWith(
        stockQuantity: newStock,
      );

      await database.updateMedication(updatedMedication);

      if (!mounted) return;

      Navigator.of(context).pop();
      widget.onAdjusted();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock updated to $newStock ${widget.medication.doseUnit}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating stock: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
