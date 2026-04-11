import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for current wizard step
final currentStepProvider = NotifierProvider<CurrentStepNotifier, int>(
  CurrentStepNotifier.new,
);

/// Notifier for managing the current step in the add/edit medication wizard
class CurrentStepNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setStep(int step) {
    state = step;
  }

  void nextStep() {
    if (state < 2) state = state + 1;
  }

  void previousStep() {
    if (state > 0) state = state - 1;
  }

  void reset() {
    state = 0;
  }
}
