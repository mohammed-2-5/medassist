import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/models/notification_sound.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/widgets/completion_summary_card.dart';
import 'package:med_assist/features/add_medication/widgets/expiry_date_section.dart';
import 'package:med_assist/features/add_medication/widgets/low_stock_reminder_section.dart';
import 'package:med_assist/features/add_medication/widgets/notification_sound_picker.dart';
import 'package:med_assist/features/add_medication/widgets/smart_snooze_settings.dart';
import 'package:med_assist/features/add_medication/widgets/stock_quantity_section.dart';
import 'package:med_assist/features/add_medication/widgets/stock_step_header.dart';
import 'package:med_assist/features/add_medication/widgets/stock_timeline_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Step 3: Stock & Reminder.
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

    unawaited(_animationController.forward());
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
    final l10n = AppLocalizations.of(context)!;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StockStepHeader(),
              const SizedBox(height: 32),

              StockQuantitySection(formData: formData),
              const SizedBox(height: 24),

              if (formData.stockQuantity > 0) ...[
                StockTimelineCard(formData: formData),
                const SizedBox(height: 24),
              ],

              LowStockReminderSection(formData: formData),
              const SizedBox(height: 24),

              ExpiryDateSection(formData: formData),
              const SizedBox(height: 32),

              // Advanced settings divider
              Row(
                children: [
                  Expanded(
                      child: Divider(color: colorScheme.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.advancedSettings,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(color: colorScheme.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),

              NotificationSoundPicker(
                selectedSound:
                    NotificationSound.fromPath(formData.customSoundPath) ??
                        NotificationSound.presets.first,
                onChanged: (sound) => ref
                    .read(medicationFormProvider.notifier)
                    .setCustomSoundPath(sound.path),
              ),
              const SizedBox(height: 24),

              SmartSnoozeSettings(formData: formData),
              const SizedBox(height: 24),

              CompletionSummaryCard(formData: formData),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
