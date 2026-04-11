import 'dart:io';

import 'package:flutter/material.dart';

class ScanMedicationImagePreview extends StatelessWidget {
  const ScanMedicationImagePreview({
    required this.selectedImage,
    required this.onRetake,
    required this.onScan,
    super.key,
  });

  final File selectedImage;
  final VoidCallback onRetake;
  final Future<void> Function() onScan;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Image.file(
            selectedImage,
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetake,
                  child: const Text('Retake'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => onScan(),
                  child: const Text('Scan'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
