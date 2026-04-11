import 'package:flutter/material.dart';

class MedicationCardSwipeBackground extends StatelessWidget {
  const MedicationCardSwipeBackground({
    required this.colorScheme,
    required this.isEdit,
    super.key,
  });

  final ColorScheme colorScheme;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: isEdit ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isEdit ? colorScheme.primary : colorScheme.error,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        isEdit ? Icons.edit : Icons.delete,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}
