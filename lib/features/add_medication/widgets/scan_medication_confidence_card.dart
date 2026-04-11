import 'package:flutter/material.dart';

class ScanMedicationConfidenceCard extends StatelessWidget {
  const ScanMedicationConfidenceCard({
    required this.confidence,
    super.key,
  });

  final double confidence;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getConfidenceColor(confidence);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(_getConfidenceIcon(confidence), color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getConfidenceText(confidence),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double value) {
    if (value >= 0.7) return Colors.green;
    if (value >= 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getConfidenceIcon(double value) {
    if (value >= 0.7) return Icons.check_circle;
    if (value >= 0.4) return Icons.warning;
    return Icons.error;
  }

  String _getConfidenceText(double value) {
    if (value >= 0.7) return 'High Confidence';
    if (value >= 0.4) return 'Medium Confidence - Please verify';
    return 'Low Confidence - Manual entry recommended';
  }
}
