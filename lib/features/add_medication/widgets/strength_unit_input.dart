import 'package:flutter/material.dart';

/// Strength value + unit dropdown row.
class StrengthUnitInput extends StatelessWidget {
  const StrengthUnitInput({
    required this.controller,
    required this.selectedUnit,
    required this.units,
    required this.onStrengthChanged,
    required this.onUnitChanged,
    super.key,
  });

  final TextEditingController controller;
  final String selectedUnit;
  final List<String> units;
  final ValueChanged<String> onStrengthChanged;
  final ValueChanged<String> onUnitChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fillColor = theme.brightness == Brightness.dark
        ? Colors.grey[850]
        : Colors.grey[100];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'e.g., 100',
              prefixIcon: const Icon(Icons.science_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: fillColor,
            ),
            keyboardType: TextInputType.number,
            onChanged: onStrengthChanged,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: selectedUnit,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: fillColor,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: units.map((unit) {
              return DropdownMenuItem(
                value: unit,
                child: Text(unit),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) onUnitChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
