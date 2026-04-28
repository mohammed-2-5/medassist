import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/utils/dose_unit_localizer.dart';
import 'package:med_assist/core/utils/stock_utils.dart';
import 'package:med_assist/core/widgets/animated_progress_bar.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class MedicationCardStockIndicator extends StatelessWidget {
  const MedicationCardStockIndicator({
    required this.medication,
    required this.theme,
    required this.colorScheme,
    super.key,
  });

  final Medication medication;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final days = StockUtils.daysRemaining(medication);
    final daysRemaining = days < 0 ? 0 : days;
    final localizedDoseUnit = localizeDoseUnit(l10n, medication.doseUnit);
    final stockPercentage = medication.stockQuantity > 0
        ? (daysRemaining / medication.durationDays).clamp(0.0, 1.0)
        : 0.0;
    final stockColor = daysRemaining > 7
        ? Colors.green
        : daysRemaining > 3
        ? Colors.orange
        : Colors.red;
    final isLowStock = daysRemaining <= 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.inventory_2, size: 16, color: stockColor)
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .shimmer(
                  duration: const Duration(milliseconds: 1500),
                  color: isLowStock
                      ? stockColor.withOpacity(0.5)
                      : Colors.transparent,
                ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${l10n.stock}: ${medication.stockQuantity} $localizedDoseUnit',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            l10n.daysOfStockLeft(daysRemaining),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: stockColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedProgressBar(
          value: stockPercentage,
          gradient: LinearGradient(
            colors: [
              stockColor,
              stockColor.withOpacity(0.7),
            ],
          ),
          backgroundColor: colorScheme.surfaceContainerHighest,
          showGlow: isLowStock,
          glowColor: stockColor,
          duration: const Duration(milliseconds: 800),
        ),
      ],
    );
  }
}
