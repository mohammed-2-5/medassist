import 'package:flutter/material.dart';

class ScanMedicationErrorView extends StatelessWidget {
  const ScanMedicationErrorView({
    required this.errorColor,
    required this.errorMessage,
    required this.onTryAgain,
    super.key,
  });

  final Color errorColor;
  final String errorMessage;
  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: errorColor),
          const SizedBox(height: 16),
          Text(
            'Scan Failed',
            style: theme.textTheme.titleLarge?.copyWith(color: errorColor),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onTryAgain,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
