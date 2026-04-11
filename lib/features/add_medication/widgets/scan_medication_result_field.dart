import 'package:flutter/material.dart';

class ScanMedicationResultField extends StatelessWidget {
  const ScanMedicationResultField({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String? value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: hasValue ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  hasValue ? value! : 'Not found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: hasValue ? FontWeight.w500 : FontWeight.normal,
                    color: hasValue ? null : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
