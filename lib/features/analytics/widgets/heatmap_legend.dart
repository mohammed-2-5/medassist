import 'package:flutter/material.dart';

/// Colour-coded legend for the time-of-day heatmap.
///
/// Shows five adherence bands from ≥90 % (green) down to <40 % (red).
class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({
    required this.theme,
    super.key,
  });

  final ThemeData theme;

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildLegendItem(Colors.green.shade400, '90%+'),
        _buildLegendItem(Colors.lightGreen.shade300, '75-89%'),
        _buildLegendItem(Colors.amber.shade300, '60-74%'),
        _buildLegendItem(Colors.orange.shade400, '40-59%'),
        _buildLegendItem(Colors.red.shade400, '<40%'),
      ],
    );
  }
}
