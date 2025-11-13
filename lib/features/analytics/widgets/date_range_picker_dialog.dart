import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Custom Date Range Picker Dialog
/// Allows users to select custom date ranges for analytics
class CustomDateRangePickerDialog extends StatefulWidget {

  const CustomDateRangePickerDialog({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
  });
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  @override
  State<CustomDateRangePickerDialog> createState() => _CustomDateRangePickerDialogState();

  /// Show the dialog and return selected date range
  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTime? initialStartDate,
    DateTime? initialEndDate,
  }) async {
    return showDialog<DateTimeRange>(
      context: context,
      builder: (context) => CustomDateRangePickerDialog(
        initialStartDate: initialStartDate,
        initialEndDate: initialEndDate,
      ),
    );
  }
}

class _CustomDateRangePickerDialogState extends State<CustomDateRangePickerDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate ?? DateTime.now().subtract(const Duration(days: 30));
    _endDate = widget.initialEndDate ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: const Text('Select Date Range'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick Selection Chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickSelectChip(
                'Last 7 Days',
                () => _setQuickRange(7),
                colorScheme,
              ),
              _buildQuickSelectChip(
                'Last 30 Days',
                () => _setQuickRange(30),
                colorScheme,
              ),
              _buildQuickSelectChip(
                'Last 3 Months',
                () => _setQuickRange(90),
                colorScheme,
              ),
              _buildQuickSelectChip(
                'This Year',
                _setThisYear,
                colorScheme,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Start Date Selector
          _buildDateSelector(
            label: 'Start Date',
            date: _startDate,
            onTap: _selectStartDate,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),

          // End Date Selector
          _buildDateSelector(
            label: 'End Date',
            date: _endDate,
            onTap: _selectEndDate,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),

          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_getDaysDifference()} days selected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirmSelection,
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildQuickSelectChip(
    String label,
    VoidCallback onTap,
    ColorScheme colorScheme,
  ) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: colorScheme.surfaceContainerHighest,
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateFormat.format(date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _setQuickRange(int days) {
    setState(() {
      _endDate = DateTime.now();
      _startDate = _endDate.subtract(Duration(days: days));
    });
  }

  void _setThisYear() {
    setState(() {
      final now = DateTime.now();
      _startDate = DateTime(now.year);
      _endDate = now;
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: _endDate,
    );

    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  int _getDaysDifference() {
    return _endDate.difference(_startDate).inDays + 1;
  }

  void _confirmSelection() {
    Navigator.of(context).pop(DateTimeRange(
      start: _startDate,
      end: _endDate,
    ));
  }
}
