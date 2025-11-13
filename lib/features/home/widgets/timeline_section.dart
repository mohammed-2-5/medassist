import 'package:flutter/material.dart';
import 'package:med_assist/core/theme/app_animations.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/home/models/dose_event.dart';
import 'package:med_assist/features/home/widgets/dose_card.dart';

/// Timeline Section - Groups medications by time of day with staggered animations
class TimelineSection extends StatefulWidget {

  const TimelineSection({
    required this.timeOfDay,
    required this.timeRange,
    required this.icon,
    required this.doses,
    super.key,
  });
  final String timeOfDay;
  final String timeRange;
  final IconData icon;
  final List<DoseEvent> doses;

  @override
  State<TimelineSection> createState() => _TimelineSectionState();
}

class _TimelineSectionState extends State<TimelineSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(
        milliseconds: AppAnimations.listItemFade.inMilliseconds +
            (widget.doses.length * AppAnimations.listItemStagger.inMilliseconds),
      ),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show section if no doses
    if (widget.doses.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TimeSectionHeader(
              timeOfDay: widget.timeOfDay,
              timeRange: widget.timeRange,
              icon: widget.icon,
              doseCount: widget.doses.length,
            ),
            const SizedBox(height: 12),
            ...widget.doses.asMap().entries.map((entry) {
              final index = entry.key;
              final dose = entry.value;
              return _StaggeredDoseCard(
                dose: dose,
                index: index,
                controller: _controller,
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Staggered animated dose card for smooth entry
class _StaggeredDoseCard extends StatelessWidget {

  const _StaggeredDoseCard({
    required this.dose,
    required this.index,
    required this.controller,
  });
  final DoseEvent dose;
  final int index;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final delay = index * AppAnimations.listItemStagger.inMilliseconds;
    final fadeStart = delay / controller.duration!.inMilliseconds;
    final fadeEnd = (delay + AppAnimations.listItemFade.inMilliseconds) /
        controller.duration!.inMilliseconds;

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          fadeStart.clamp(0.0, 1.0),
          fadeEnd.clamp(0.0, 1.0),
          curve: AppAnimations.easeOut,
        ),
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          fadeStart.clamp(0.0, 1.0),
          fadeEnd.clamp(0.0, 1.0),
          curve: AppAnimations.smooth,
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(
          position: slideAnimation,
          child: DoseCard(dose: dose),
        ),
      ),
    );
  }
}

/// Time section header component
class _TimeSectionHeader extends StatelessWidget {

  const _TimeSectionHeader({
    required this.timeOfDay,
    required this.timeRange,
    required this.icon,
    required this.doseCount,
  });
  final String timeOfDay;
  final String timeRange;
  final IconData icon;
  final int doseCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timeColor = _getTimeColor(timeOfDay);

    return Row(
      children: [
        // Time icon badge
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: timeColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: timeColor),
        ),
        const SizedBox(width: 12),

        // Time labels
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                timeOfDay,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                timeRange,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Dose count badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$doseCount',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Color _getTimeColor(String timeOfDay) {
    switch (timeOfDay) {
      case 'Morning':
        return AppColors.morningColor;
      case 'Afternoon':
        return AppColors.afternoonColor;
      case 'Evening':
        return AppColors.eveningColor;
      case 'Night':
        return AppColors.nightColor;
      default:
        return AppColors.primaryBlue;
    }
  }
}
