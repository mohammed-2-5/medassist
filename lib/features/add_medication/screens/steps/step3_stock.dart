import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/models/notification_sound.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/notification_sound_picker.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Step 3: Stock & Reminder
class Step3Stock extends ConsumerStatefulWidget {
  const Step3Stock({super.key});

  @override
  ConsumerState<Step3Stock> createState() => _Step3StockState();
}

class _Step3StockState extends ConsumerState<Step3Stock>
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

              // Stock quantity input
              _buildStockQuantitySection(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Stock timeline visualization
              if (formData.stockQuantity > 0) ...[
                _buildStockTimeline(formData, theme, colorScheme),
                const SizedBox(height: 24),
              ],

              // Low stock reminder toggle
              _buildLowStockReminderSection(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Expiry date section
              _buildExpiryDateSection(formData, theme, colorScheme),
              const SizedBox(height: 32),

              // Advanced settings divider
              Row(
                children: [
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context)!.advancedSettings,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),

              // Notification sound picker
              NotificationSoundPicker(
                selectedSound: NotificationSound.fromPath(formData.customSoundPath) ??
                    NotificationSound.presets.first,
                onChanged: (sound) {
                  ref
                      .read(medicationFormProvider.notifier)
                      .setCustomSoundPath(sound.path);
                },
              ),
              const SizedBox(height: 24),

              // Smart snooze settings
              _buildSmartSnoozeSettings(formData, theme, colorScheme),
              const SizedBox(height: 24),

              // Completion summary
              _buildCompletionSummary(formData, theme, colorScheme),
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
        gradient: AppColors.successGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.successGreen.withOpacity(0.3),
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
                  Icons.inventory_2_rounded,
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
                  AppLocalizations.of(context)!.step3Of3,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.stockAndReminder,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Track your medicine supply and get low stock alerts',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockQuantitySection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current stock quantity',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'How many ${formData.doseUnit}s do you have?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: formData.stockQuantity > 0
                    ? formData.stockQuantity.toString()
                    : '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: '30',
                  prefixIcon: const Icon(Icons.inventory),
                  suffixText: formData.doseUnit,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[850]
                      : Colors.grey[100],
                ),
                onChanged: (value) {
                  final quantity = int.tryParse(value) ?? 0;
                  ref
                      .read(medicationFormProvider.notifier)
                      .setStockQuantity(quantity);
                },
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.medication,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formData.stockQuantity}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'in stock',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
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

  Widget _buildStockTimeline(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final runOutDate = formData.stockRunOutDate;
    final lowStockDate = formData.lowStockReminderDate;
    final dailyUsage = formData.dosePerTime * formData.timesPerDay;
    final daysRemaining = runOutDate != null
        ? runOutDate.difference(DateTime.now()).inDays
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.timeline,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Stock Timeline',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Daily usage
          _buildTimelineItem(
            icon: Icons.today,
            label: 'Daily usage',
            value: '$dailyUsage ${formData.doseUnit}${dailyUsage != 1 ? 's' : ''}',
            color: colorScheme.primary,
            theme: theme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),

          // Days remaining
          _buildTimelineItem(
            icon: Icons.event_available,
            label: 'Stock lasts for',
            value: '$daysRemaining day${daysRemaining != 1 ? 's' : ''}',
            color: daysRemaining > 7
                ? Colors.green
                : daysRemaining > 3
                    ? Colors.orange
                    : Colors.red,
            theme: theme,
            colorScheme: colorScheme,
          ),
          const SizedBox(height: 16),

          // Low stock alert date
          if (lowStockDate != null && formData.remindBeforeRunOut)
            _buildTimelineItem(
              icon: Icons.notifications_active,
              label: 'Low stock alert',
              value: _formatDate(lowStockDate),
              color: Colors.orange,
              theme: theme,
              colorScheme: colorScheme,
            ),
          if (lowStockDate != null && formData.remindBeforeRunOut)
            const SizedBox(height: 16),

          // Run out date
          if (runOutDate != null)
            _buildTimelineItem(
              icon: Icons.warning,
              label: 'Stock runs out',
              value: _formatDate(runOutDate),
              color: Colors.red,
              theme: theme,
              colorScheme: colorScheme,
            ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // Visual progress bar
          _buildStockProgressBar(
            daysRemaining: daysRemaining,
            totalDays: daysRemaining,
            theme: theme,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockProgressBar({
    required int daysRemaining,
    required int totalDays,
    required ThemeData theme,
    required ColorScheme colorScheme,
  }) {
    final percentage = daysRemaining > 0 ? 1.0 : 0.0;
    final color = daysRemaining > 7
        ? Colors.green
        : daysRemaining > 3
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stock level',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer.withOpacity(0.7),
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 12,
            backgroundColor: colorScheme.surface.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockReminderSection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Low stock reminder',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Switch(
                value: formData.remindBeforeRunOut,
                onChanged: (value) {
                  ref
                      .read(medicationFormProvider.notifier)
                      .setRemindBeforeRunOut(value);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Get notified before your medicine runs out',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (formData.remindBeforeRunOut) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Remind me this many days before:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [1, 3, 5, 7, 10, 14].map((days) {
                final isSelected = formData.reminderDaysBeforeRunOut == days;
                return FilterChip(
                  label: Text('$days day${days != 1 ? 's' : ''}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(medicationFormProvider.notifier)
                          .setReminderDaysBeforeRunOut(days);
                    }
                  },
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primaryContainer,
                  checkmarkColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpiryDateSection(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_busy,
                color: colorScheme.error,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Expiry date (optional)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Track when your medication expires',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: formData.expiryDate ?? now.add(const Duration(days: 365)),
                firstDate: now,
                lastDate: now.add(const Duration(days: 3650)),
              );
              if (picked != null) {
                ref
                    .read(medicationFormProvider.notifier)
                    .setExpiryDate(picked);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: formData.expiryDate != null
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      formData.expiryDate != null
                          ? _formatDate(formData.expiryDate!)
                          : 'Tap to set expiry date',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: formData.expiryDate != null
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: formData.expiryDate != null
                            ? FontWeight.w600
                            : null,
                      ),
                    ),
                  ),
                  if (formData.expiryDate != null)
                    IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        ref
                            .read(medicationFormProvider.notifier)
                            .setExpiryDate(null);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ),
          if (formData.expiryDate != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Remind me before expiry:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [7, 14, 30, 60, 90].map((days) {
                final isSelected = formData.reminderDaysBeforeExpiry == days;
                return FilterChip(
                  label: Text('$days day${days != 1 ? 's' : ''}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref
                          .read(medicationFormProvider.notifier)
                          .setReminderDaysBeforeExpiry(days);
                    }
                  },
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.errorContainer,
                  checkmarkColor: colorScheme.error,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onErrorContainer
                        : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmartSnoozeSettings(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.snooze,
              color: colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.smartSnooze,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.smartSnoozeDescription,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            children: [
              // Max snoozes per day
              Row(
                children: [
                  Icon(
                    Icons.timelapse,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.maxSnoozesPerDay,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      formData.maxSnoozesPerDay.toString(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Slider
              Slider(
                value: formData.maxSnoozesPerDay.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: formData.maxSnoozesPerDay.toString(),
                onChanged: (value) {
                  ref
                      .read(medicationFormProvider.notifier)
                      .setMaxSnoozesPerDay(value.toInt());
                },
              ),
              // Help text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    l10n.snoozeRemaining(formData.maxSnoozesPerDay),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '10',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionSummary(
    MedicationFormData formData,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isComplete = formData.isComplete;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isComplete
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComplete ? colorScheme.secondary : colorScheme.outline,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.info,
            color: isComplete
                ? colorScheme.secondary
                : colorScheme.onSurfaceVariant,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            isComplete
                ? 'Ready to save!'
                : 'Complete all steps to continue',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isComplete
                  ? colorScheme.onSecondaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isComplete
                ? 'Your medicine information is complete and ready to be saved'
                : 'Please fill in all required fields in previous steps',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isComplete
                  ? colorScheme.onSecondaryContainer.withOpacity(0.7)
                  : colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (isComplete) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryCheckItem(
                    'Medicine type and details',
                    formData.isStep1Valid,
                    theme,
                    colorScheme,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryCheckItem(
                    'Schedule configured',
                    formData.isStep2Valid,
                    theme,
                    colorScheme,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryCheckItem(
                    'Stock information',
                    formData.isStep3Valid,
                    theme,
                    colorScheme,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCheckItem(
    String label,
    bool isValid,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.circle_outlined,
          color: isValid ? Colors.green : colorScheme.onSurfaceVariant,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              fontWeight: isValid ? FontWeight.w600 : null,
            ),
          ),
        ),
      ],
    );
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
}
