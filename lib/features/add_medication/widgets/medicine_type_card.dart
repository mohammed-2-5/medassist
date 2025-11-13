import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';

/// Beautiful animated medicine type selection card
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
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  LinearGradient _getGradientForType(MedicineType type) {
    return switch (type) {
      MedicineType.pill => AppColors.primaryGradient,
      MedicineType.injection => AppColors.pinkGradient,
      MedicineType.suppository => AppColors.warningGradient,
      MedicineType.ivSolution => const LinearGradient(
          colors: [Color(0xFF42A5F5), Color(0xFF4DD0CE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      MedicineType.syrup => AppColors.successGradient,
      MedicineType.drops => const LinearGradient(
          colors: [Color(0xFF66BB6A), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final gradient = _getGradientForType(widget.type);

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: widget.isSelected ? gradient : null,
            color: widget.isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isSelected
                  ? Colors.transparent
                  : colorScheme.outlineVariant.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              if (widget.isSelected)
                BoxShadow(
                  color: gradient.colors.first.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              if (!widget.isSelected)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with animation and glow effect
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(
                  begin: 0,
                  end: widget.isSelected ? 1.0 : 0.0,
                ),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 1.0 + (value * 0.15),
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? Colors.white.withOpacity(0.2)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (widget.isSelected)
                        BoxShadow(
                          color: Colors.white.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                    ],
                  ),
                  child: Text(
                    widget.type.label.split(' ')[0], // Get emoji
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Type name
              Text(
                widget.type.label.substring(2), // Remove emoji
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // Description
              Text(
                widget.type.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: widget.isSelected
                      ? Colors.white.withOpacity(0.9)
                      : AppColors.textSecondary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Checkmark for selected with animation
              if (widget.isSelected) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: gradient.colors.first,
                    size: 16,
                  ),
                )
                    .animate()
                    .scale(duration: 300.ms, curve: Curves.elasticOut)
                    .fadeIn(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
