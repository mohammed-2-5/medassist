import 'package:flutter/material.dart';
import 'package:med_assist/features/analytics/models/analytics_period_option.dart';

/// Single tappable pill rendered by `AnalyticsPeriodSelector`. Animates
/// fill, shadow, and typography between selected and unselected states.
class AnalyticsPeriodPill extends StatelessWidget {
  const AnalyticsPeriodPill({
    required this.option,
    required this.isSelected,
    required this.colorScheme,
    required this.onTap,
    super.key,
  });

  final AnalyticsPeriodOption option;
  final bool isSelected;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = isSelected ? Colors.white : colorScheme.onSurfaceVariant;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isSelected ? null : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: colorScheme.primary.withValues(alpha: 0.15),
          highlightColor: colorScheme.primary.withValues(alpha: 0.08),
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 20 : 16,
              vertical: 12,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(option.icon, size: 18, color: fg),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: fg,
                    letterSpacing: 0.2,
                  ),
                  child: Text(option.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
