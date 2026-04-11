import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/dose_per_time_section.dart';
import 'package:med_assist/features/add_medication/widgets/duration_section.dart';
import 'package:med_assist/features/add_medication/widgets/recurring_reminders_section.dart';
import 'package:med_assist/features/add_medication/widgets/reminder_times_section.dart';
import 'package:med_assist/features/add_medication/widgets/repetition_pattern_section.dart';
import 'package:med_assist/features/add_medication/widgets/schedule_preview_card.dart';
import 'package:med_assist/features/add_medication/widgets/schedule_step_header.dart';
import 'package:med_assist/features/add_medication/widgets/start_date_section.dart';
import 'package:med_assist/features/add_medication/widgets/times_per_day_selector.dart';

/// Step 2: Schedule & Duration
class Step2Schedule extends ConsumerStatefulWidget {
  const Step2Schedule({super.key});

  @override
  ConsumerState<Step2Schedule> createState() => _Step2ScheduleState();
}

class _Step2ScheduleState extends ConsumerState<Step2Schedule>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(medicationFormProvider);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScheduleStepHeader(),
              const SizedBox(height: 32),
              TimesPerDaySelector(formData: formData),
              const SizedBox(height: 24),
              DosePerTimeSection(formData: formData),
              const SizedBox(height: 24),
              DurationSection(formData: formData),
              const SizedBox(height: 24),
              RepetitionPatternSection(formData: formData),
              const SizedBox(height: 24),
              StartDateSection(formData: formData),
              const SizedBox(height: 32),
              ReminderTimesSection(formData: formData),
              const SizedBox(height: 24),
              RecurringRemindersSection(formData: formData),
              const SizedBox(height: 24),
              SchedulePreviewCard(formData: formData),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
