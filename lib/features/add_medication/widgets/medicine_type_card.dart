import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/utils/medicine_type_style.dart';
import 'package:med_assist/features/add_medication/widgets/medicine_type_checkmark.dart';
import 'package:med_assist/features/add_medication/widgets/medicine_type_icon_badge.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Animated medicine type selection card. Highlights with a gradient fill,
/// scaling emoji badge, and checkmark when selected.
class MedicineTypeCard extends StatefulWidget {
  const MedicineTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final MedicineType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<MedicineTypeCard> createState() => _MedicineTypeCardState();
}

class _MedicineTypeCardState extends State<MedicineTypeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final gradient = widget.type.gradient;
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: _controller.reverse,
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: isSelected ? gradient : null,
            color: isSelected ? null : colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MedicineTypeIconBadge(
                emoji: widget.type.emoji,
                isSelected: isSelected,
                colorScheme: colorScheme,
              ),
              const SizedBox(height: 8),
              Text(
                widget.type.localizedLabel(l10n),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.type.localizedDescription(l10n),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? colorScheme.onPrimary.withValues(alpha: 0.9)
                      : colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (isSelected) ...[
                const SizedBox(height: 6),
                MedicineTypeCheckmark(
                  iconColor: gradient.colors.first,
                  bgColor: colorScheme.onPrimary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
