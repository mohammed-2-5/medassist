import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/add_medication/providers/current_step_provider.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/screens/steps/step1_type_info.dart';
import 'package:med_assist/features/add_medication/screens/steps/step2_schedule.dart';
import 'package:med_assist/features/add_medication/screens/steps/step3_stock.dart';
import 'package:med_assist/features/medications/widgets/medication_edit_nav_buttons.dart';
import 'package:med_assist/features/medications/widgets/medication_edit_progress_bar.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Edit Medication Screen — reuses the 3-step wizard for editing.
class MedicationEditScreen extends ConsumerStatefulWidget {
  const MedicationEditScreen({required this.medicationId, super.key});

  final int medicationId;

  @override
  ConsumerState<MedicationEditScreen> createState() =>
      _MedicationEditScreenState();
}

class _MedicationEditScreenState extends ConsumerState<MedicationEditScreen> {
  bool _isLoading = true;
  bool _loadError = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadMedication());
  }

  Future<void> _loadMedication() async {
    try {
      setState(() { _isLoading = true; _loadError = false; });
      await ref
          .read(medicationFormProvider.notifier)
          .loadMedication(widget.medicationId);
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) setState(() { _isLoading = false; _loadError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final currentStep = ref.watch(currentStepProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editMedication)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editMedication)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(l10n.failedToLoadMedication,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadMedication,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.discardChanges),
            content: Text(l10n.discardChangesConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error),
                child: Text(l10n.discard),
              ),
            ],
          ),
        );
        if ((shouldPop ?? false) && mounted) {
          ref.read(currentStepProvider.notifier).reset();
          ref.read(medicationFormProvider.notifier).reset();
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          elevation: 0,
          title: Text(l10n.editMedication),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ),
        body: Column(
          children: [
            MedicationEditProgressBar(currentStep: currentStep),
            Expanded(
              child: switch (currentStep) {
                0 => const Step1TypeInfo(),
                1 => const Step2Schedule(),
                2 => const Step3Stock(),
                _ => const SizedBox.shrink(),
              },
            ),
            MedicationEditNavButtons(medicationId: widget.medicationId),
          ],
        ),
      ),
    );
  }
}
