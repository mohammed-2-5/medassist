import 'package:flutter/material.dart';
import 'package:med_assist/core/theme/app_animations.dart';
import 'package:med_assist/core/widgets/gradient_container.dart';

/// Adherence Summary Card
///
/// Displays today's medication adherence summary with:
/// - Circular progress indicator with smooth animation
/// - Doses taken vs total
/// - Current streak counter
/// - Tap to navigate to detailed analytics
/// - Modern gradient background and smooth interactions
class AdherenceSummaryCard extends StatefulWidget {

  const AdherenceSummaryCard({
    required this.takenToday,
    required this.totalToday,
    required this.currentStreak,
    required this.onTap,
    super.key,
  });
  final int takenToday;
  final int totalToday;
  final int currentStreak;
  final VoidCallback onTap;

  @override
  State<AdherenceSummaryCard> createState() => _AdherenceSummaryCardState();
}

class _AdherenceSummaryCardState extends State<AdherenceSummaryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.cardScale,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.cardScaleCurve,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculate adherence percentage
    final adherencePercentage = widget.totalToday > 0
        ? (widget.takenToday / widget.totalToday * 100).round()
        : 0;

    // Determine status color
    final statusColor = _getStatusColor(adherencePercentage, colorScheme);
    final statusMessage = _getStatusMessage(adherencePercentage);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          onTap: widget.onTap,
          child: GradientContainer(
            borderRadius: BorderRadius.circular(20),
            elevation: 4,
            padding: const EdgeInsets.all(20),
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.6),
              colorScheme.primaryContainer.withValues(alpha: 0.3),
            ],
            child: Row(
              children: [
                // Circular progress indicator
                _buildCircularProgress(
                  context,
                  adherencePercentage,
                  statusColor,
                  colorScheme,
                ),

                const SizedBox(width: 20),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "Today's Progress",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Status message
                      Text(
                        statusMessage,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Doses taken
                      Row(
                        children: [
                          Icon(
                            Icons.medication_rounded,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.takenToday} of ${widget.totalToday} doses taken',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Streak
                      Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: Colors.orange.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.currentStreak} day streak',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircularProgress(
    BuildContext context,
    int percentage,
    Color statusColor,
    ColorScheme colorScheme,
  ) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
          ),

          // Progress circle
          SizedBox(
            width: 80,
            height: 80,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1500),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(
                begin: 0,
                end: percentage / 100,
              ),
              builder: (context, value, child) {
                return CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                  strokeCap: StrokeCap.round,
                );
              },
            ),
          ),

          // Percentage text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(int percentage, ColorScheme colorScheme) {
    if (percentage >= 80) {
      return colorScheme.secondary; // Green - Excellent
    } else if (percentage >= 60) {
      return Colors.blue; // Blue - Good
    } else if (percentage >= 40) {
      return Colors.orange; // Orange - Fair
    } else {
      return colorScheme.error; // Red - Needs attention
    }
  }

  String _getStatusMessage(int percentage) {
    if (percentage >= 80) {
      return 'Excellent adherence! 🎉';
    } else if (percentage >= 60) {
      return 'Good progress!';
    } else if (percentage >= 40) {
      return 'Keep it up!';
    } else if (percentage > 0) {
      return "Let's catch up";
    } else {
      return 'Start your day';
    }
  }
}
