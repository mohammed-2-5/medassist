import 'package:flutter/material.dart';
import 'package:med_assist/features/analytics/providers/analytics_provider.dart';

// ---------------------------------------------------------------------------
// Pure helpers — shared by HeatmapHourCell, HeatmapLegend, and _buildInsights
// ---------------------------------------------------------------------------

/// Returns an AM/PM label for a 0-based [hour] (0 → '12AM', 13 → '1PM').
String formatHour(int hour) {
  if (hour == 0) return '12AM';
  if (hour < 12) return '${hour}AM';
  if (hour == 12) return '12PM';
  return '${hour - 12}PM';
}

/// Maps an adherence [percentage] to a colour.
/// Pass [totalDoses] so the function can distinguish "no data" hours.
Color getColorForAdherence(
  double percentage,
  ColorScheme colorScheme,
  int totalDoses,
) {
  if (totalDoses == 0) {
    return colorScheme.surfaceContainerHighest.withOpacity(0.3);
  }
  if (percentage >= 90) return Colors.green.shade400;
  if (percentage >= 75) return Colors.lightGreen.shade300;
  if (percentage >= 60) return Colors.amber.shade300;
  if (percentage >= 40) return Colors.orange.shade400;
  return Colors.red.shade400;
}

/// Returns black or white depending on the luminance of [backgroundColor].
Color getTextColorForBackground(Color backgroundColor) {
  final luminance = backgroundColor.computeLuminance();
  return luminance > 0.5 ? Colors.black87 : Colors.white;
}

// ---------------------------------------------------------------------------
// HeatmapHourCell
// ---------------------------------------------------------------------------

/// A single tappable cell in the time-of-day heatmap.
///
/// Tapping opens a detail dialog when the hour has recorded doses.
class HeatmapHourCell extends StatelessWidget {
  const HeatmapHourCell({
    required this.data,
    required this.colorScheme,
    required this.theme,
    super.key,
  });

  final HourlyAdherenceData data;
  final ColorScheme colorScheme;
  final ThemeData theme;

  Future<void> _showHourDetail(
    BuildContext context,
    String hourStr,
    Color color,
  ) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(hourStr),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow(
              'Adherence',
              '${data.adherencePercentage.toStringAsFixed(0)}%',
            ),
            _detailRow('Doses taken', '${data.takenDoses}'),
            _detailRow('Total doses', '${data.totalDoses}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = getColorForAdherence(
      data.adherencePercentage,
      colorScheme,
      data.totalDoses,
    );
    final hourStr = formatHour(data.hour);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: data.totalDoses > 0
          ? () => _showHourDetail(context, hourStr, color)
          : null,
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hourStr,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: getTextColorForBackground(color),
              ),
            ),
            if (data.totalDoses > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${data.adherencePercentage.toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: getTextColorForBackground(color),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
