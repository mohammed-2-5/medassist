import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/meal_timing_selector.dart';
import 'package:med_assist/l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(theme, colorScheme),
              const SizedBox(height: 32),

              // Times per day selector
              _buildTimesPerDaySection(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Dose per time
              _buildDoseSection(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Duration
              _buildDurationSection(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Repetition pattern
              _buildRepetitionSection(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Start date
              _buildStartDateSection(formData, theme, colorScheme),
              const SizedBox(height: 32),

              // Reminder times
              _buildReminderTimesSection(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Recurring reminders for missed doses
              _buildRecurringRemindersSection(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Schedule preview
              _buildSchedulePreview(formData, theme, colorScheme),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.purpleGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPurple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)!.step2Of3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.scheduleAndDuration,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'When and how often to take this medicine',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimesPerDaySection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How many times per day?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Select the number of times you need to take this medicine daily',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(6, (index) {
            final times = index + 1;
            final isSelected = formData.timesPerDay == times;
            return _buildTimesChip(
              times: times,
              isSelected: isSelected,
              theme: theme,
              colorScheme: colorScheme,
            );
          }),
        ),
      ],
    );
  }

  LinearGradient _getGradientForTimes(int times) {
    final gradients = [
      AppColors.primaryGradient,
      AppColors.purpleGradient,
      AppColors.successGradient,
      AppColors.pinkGradient,
      AppColors.warningGradient,
      const LinearGradient(
        colors: [Color(0xFF42A5F5), Color(0xFF66BB6A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ];
    return gradients[(times - 1) % gradients.length];
  }

  Widget _buildTimesChip({
    required int times,
    required bool isSelected,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final gradient = _getGradientForTimes(times);

    return InkWell(
      onTap: () {
        ref.read(medicationFormProvider.notifier).setTimesPerDay(times);
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : colorScheme.outlineVariant.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$times',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              times == 1 ? 'time' : 'times',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.9)
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              )
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.elasticOut)
                  .fadeIn(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDoseSection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dose per time',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Dose amount
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: formData.dosePerTime.toString(),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '1.0',
                  prefixIcon: const Icon(Icons.medication),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                ),
                onChanged: (value) {
                  final dose = double.tryParse(value) ?? 1.0;
                  ref.read(medicationFormProvider.notifier).setDosePerTime(dose);
                },
              ),
            ),
            const SizedBox(width: 12),
            // Dose unit
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: formData.doseUnit,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                items: const [
                  DropdownMenuItem(value: 'tablet', child: Text('tablet')),
                  DropdownMenuItem(value: 'capsule', child: Text('capsule')),
                  DropdownMenuItem(value: 'ml', child: Text('ml')),
                  DropdownMenuItem(value: 'mg', child: Text('mg')),
                  DropdownMenuItem(value: 'drop', child: Text('drop')),
                  DropdownMenuItem(value: 'puff', child: Text('puff')),
                  DropdownMenuItem(value: 'unit', child: Text('unit')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    ref.read(medicationFormProvider.notifier).setDoseUnit(value);
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationSection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Treatment duration',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: formData.durationDays.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Days',
                  hintText: '7',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixText: 'days',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: theme.brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                ),
                onChanged: (value) {
                  final days = int.tryParse(value) ?? 7;
                  ref.read(medicationFormProvider.notifier).setDurationDays(days);
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    color: colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formData.durationDays}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                  Text(
                    'days',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartDateSection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final startDate = formData.startDate ?? DateTime.now();
    final endDate = startDate.add(Duration(days: formData.durationDays));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Start date',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => _selectStartDate(context, startDate),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_month,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Starting',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(startDate),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit, color: colorScheme.primary),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Treatment ends on ${_formatDate(endDate)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReminderTimesSection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Reminder times',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (formData.reminderTimes.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  ref
                      .read(medicationFormProvider.notifier)
                      .generateDefaultReminderTimes();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (formData.reminderTimes.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Select times per day to set reminder times',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          Column(
            children: List.generate(
              formData.reminderTimes.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildReminderTimeCard(
                  index: index,
                  reminderData: formData.reminderTimes[index],
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReminderTimeCard({
    required int index,
    required ReminderTimeData reminderData,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
        color: colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time selector
          InkWell(
            onTap: () => _selectReminderTime(context, index, reminderData.time),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.alarm,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dose ${index + 1}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTime(reminderData.time),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit, color: colorScheme.primary, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // Meal timing selector
          MealTimingSelector(
            selectedTiming: reminderData.mealTiming,
            onChanged: (timing) {
              ref.read(medicationFormProvider.notifier).updateReminderMealTiming(index, timing);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePreview(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isValid = formData.isStep2Valid;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isValid
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isValid ? colorScheme.secondary : colorScheme.outline,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.info,
                color: isValid ? colorScheme.secondary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isValid ? 'Schedule summary' : 'Complete the form',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isValid
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (isValid) ...[
            const SizedBox(height: 16),
            _buildSummaryRow(
              icon: Icons.schedule,
              label: 'Frequency',
              value: '${formData.timesPerDay}x per day',
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              icon: Icons.medication,
              label: 'Each dose',
              value: '${formData.dosePerTime} ${formData.doseUnit}',
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              icon: Icons.event,
              label: 'Duration',
              value: '${formData.durationDays} days',
              theme: theme,
              colorScheme: colorScheme,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              icon: Icons.calendar_today,
              label: 'Starts',
              value: _formatDate(formData.startDate ?? DateTime.now()),
              theme: theme,
              colorScheme: colorScheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSecondaryContainer),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSecondaryContainer.withOpacity(0.7),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepetitionSection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repetition pattern',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'When should this medication be taken?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // Repetition pattern selector
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: RepetitionPattern.values.map((pattern) {
            final isSelected = formData.repetitionPattern == pattern;
            return InkWell(
              onTap: () {
                ref.read(medicationFormProvider.notifier).setRepetitionPattern(pattern);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      pattern.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pattern.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Show weekday selector for specific days pattern
        if (formData.repetitionPattern == RepetitionPattern.specificDays) ...[
          const SizedBox(height: 16),
          _buildWeekdaySelector(formData, theme, colorScheme),
        ],

        // Show active days preview
        if (formData.repetitionPattern != RepetitionPattern.asNeeded &&
            formData.specificDaysOfWeek.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: colorScheme.onSecondaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Active on: ${_getActiveDaysText(formData)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildWeekdaySelector(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select days of the week',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayNumber = index + 1; // 1 = Monday, 7 = Sunday
            final isSelected = formData.specificDaysOfWeek.contains(dayNumber);
            final dayName = RepetitionPattern.getWeekdayName(dayNumber);

            return InkWell(
              onTap: () {
                final newDays = List<int>.from(formData.specificDaysOfWeek);
                if (isSelected) {
                  newDays.remove(dayNumber);
                } else {
                  newDays.add(dayNumber);
                }
                newDays.sort();

                ref.read(medicationFormProvider.notifier).setSpecificDaysOfWeek(newDays);
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  dayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _getActiveDaysText(MedicationFormData formData) {
    if (formData.repetitionPattern == RepetitionPattern.daily) {
      return 'Every day';
    } else if (formData.repetitionPattern == RepetitionPattern.everyOtherDay) {
      return 'Every other day';
    } else if (formData.repetitionPattern == RepetitionPattern.weekdays) {
      return 'Monday to Friday';
    } else if (formData.repetitionPattern == RepetitionPattern.weekends) {
      return 'Saturday and Sunday';
    } else if (formData.specificDaysOfWeek.isEmpty) {
      return 'No days selected';
    } else {
      final days = formData.specificDaysOfWeek
          .map(RepetitionPattern.getWeekdayName)
          .join(', ');
      return days;
    }
  }

  Future<void> _selectStartDate(BuildContext context, DateTime initial) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      ref.read(medicationFormProvider.notifier).setStartDate(picked);
    }
  }

  Future<void> _selectReminderTime(
    BuildContext context,
    int index,
    TimeOfDay initial,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );

    if (picked != null) {
      ref.read(medicationFormProvider.notifier).updateReminderTime(index, picked);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Widget _buildRecurringRemindersSection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.repeat_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recurring Reminders',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get follow-up reminders for missed doses',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: formData.enableRecurringReminders ?? false,
                onChanged: (value) {
                  ref
                      .read(medicationFormProvider.notifier)
                      .setEnableRecurringReminders(value);
                },
              ),
            ],
          ),
          if (formData.enableRecurringReminders ?? false) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'Reminder Interval',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [15, 30, 45, 60].map((minutes) {
                final isSelected =
                    (formData.recurringReminderInterval ?? 30) == minutes;
                return ChoiceChip(
                  label: Text('$minutes min'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(medicationFormProvider.notifier)
                          .setRecurringReminderInterval(minutes);
                    }
                  },
                  selectedColor: colorScheme.primaryContainer,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: colorScheme.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "If you miss a dose, you'll get reminder every ${formData.recurringReminderInterval ?? 30} minutes (up to 4 times)",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
