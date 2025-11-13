import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/utils/provider_refresh_utils.dart';
import 'package:med_assist/features/add_medication/models/medication_form_data.dart';
import 'package:med_assist/features/add_medication/providers/medication_form_provider.dart';
import 'package:med_assist/features/add_medication/screens/steps/step1_type_info.dart';
import 'package:med_assist/features/add_medication/screens/steps/step2_schedule.dart';
import 'package:med_assist/features/add_medication/screens/steps/step3_stock.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Edit Medication Screen - Reuses 3-step wizard for editing
class MedicationEditScreen extends ConsumerStatefulWidget {

  const MedicationEditScreen({
    required this.medicationId,
    super.key,
  });
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
    _loadMedication();
  }

  Future<void> _loadMedication() async {
    try {
      setState(() {
        _isLoading = true;
        _loadError = false;
      });

      // Load medication data into form
      await ref
          .read(medicationFormProvider.notifier)
          .loadMedication(widget.medicationId);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentStep = ref.watch(currentStepProvider);
    final formData = ref.watch(medicationFormProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editMedication),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_loadError) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.editMedication),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.failedToLoadMedication,
                style: theme.textTheme.titleMedium,
              ),
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
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Show confirmation dialog before leaving
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(l10n.discardChanges),
            content: Text(l10n.discardChangesConfirmation),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.error,
                ),
                child: Text(l10n.discard),
              ),
            ],
          ),
        );

        if (shouldPop ?? false && mounted) {
          // Reset form
          ref.read(currentStepProvider.notifier).reset();
          ref.read(medicationFormProvider.notifier).reset();
          context.pop();
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: _buildAppBar(theme, colorScheme, currentStep, l10n),
        body: Column(
          children: [
            // Progress Indicator
            _buildProgressIndicator(theme, colorScheme, currentStep, l10n),

            // Step Content
            Expanded(
              child: _buildStepContent(currentStep),
            ),

            // Navigation Buttons
            _buildNavigationButtons(theme, colorScheme, currentStep, formData, l10n),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ThemeData theme,
    ColorScheme colorScheme,
    int currentStep,
    AppLocalizations l10n,
  ) {
    return AppBar(
      elevation: 0,
      title: Text(l10n.editMedication),
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
    );
  }

  Widget _buildProgressIndicator(
    ThemeData theme,
    ColorScheme colorScheme,
    int currentStep,
    AppLocalizations l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, currentStep, colorScheme, l10n.type),
          _buildStepConnector(currentStep >= 1, colorScheme),
          _buildStepIndicator(1, currentStep, colorScheme, l10n.schedule),
          _buildStepConnector(currentStep >= 2, colorScheme),
          _buildStepIndicator(2, currentStep, colorScheme, l10n.stock),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(
    int step,
    int currentStep,
    ColorScheme colorScheme,
    String label,
  ) {
    final isActive = step == currentStep;
    final isCompleted = step < currentStep;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? colorScheme.primary
                  : colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: colorScheme.onPrimary,
                    )
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isCompleted, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isCompleted
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
      ),
    );
  }

  Widget _buildStepContent(int currentStep) {
    return switch (currentStep) {
      0 => const Step1TypeInfo(),
      1 => const Step2Schedule(),
      2 => const Step3Stock(),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildNavigationButtons(
    ThemeData theme,
    ColorScheme colorScheme,
    int currentStep,
    MedicationFormData formData,
    AppLocalizations l10n,
  ) {
    final canProceed = _canProceedToNextStep(currentStep, formData);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref.read(currentStepProvider.notifier).previousStep();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(l10n.back),
                ),
              ),

            if (currentStep > 0) const SizedBox(width: 12),

            // Next/Finish button
            Expanded(
              flex: currentStep == 0 ? 1 : 1,
              child: FilledButton(
                onPressed: canProceed ? _handleNextOrFinish : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  currentStep == 2 ? l10n.saveChanges : l10n.next,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceedToNextStep(int step, MedicationFormData formData) {
    return switch (step) {
      0 => formData.isStep1Valid,
      1 => formData.isStep2Valid,
      2 => formData.isStep3Valid,
      _ => false,
    };
  }

  Future<void> _handleNextOrFinish() async {
    final currentStep = ref.read(currentStepProvider);

    if (currentStep < 2) {
      // Move to next step
      ref.read(currentStepProvider.notifier).nextStep();
    } else {
      // Save medication
      await _saveMedication();
    }
  }

  Future<void> _saveMedication() async {
    // Show loading
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final success =
          await ref.read(medicationFormProvider.notifier).saveMedication();

      if (!mounted) return;

      // Close loading dialog
      context.pop();

      if (success) {
        // Refresh all medication-related providers including the specific medication
        ProviderRefreshUtils.refreshMedicationDetail(ref, widget.medicationId);

        // Reset form
        ref.read(currentStepProvider.notifier).reset();
        ref.read(medicationFormProvider.notifier).reset();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.medicationUpdatedSuccessfully),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to list
        context.pop();
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.failedToUpdateMedication),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      // Close loading dialog
      context.pop();

      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
