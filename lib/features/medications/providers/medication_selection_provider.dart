import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the current selection mode state for the medications list.
class MedicationSelectionState {
  const MedicationSelectionState({
    this.isSelectionMode = false,
    this.selectedIds = const {},
  });

  final bool isSelectionMode;
  final Set<int> selectedIds;

  MedicationSelectionState copyWith({
    bool? isSelectionMode,
    Set<int>? selectedIds,
  }) {
    return MedicationSelectionState(
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedIds: selectedIds ?? this.selectedIds,
    );
  }
}

final medicationSelectionProvider =
    NotifierProvider<MedicationSelectionNotifier, MedicationSelectionState>(
      MedicationSelectionNotifier.new,
    );

/// Manages selection mode state for bulk operations on medications.
class MedicationSelectionNotifier extends Notifier<MedicationSelectionState> {
  @override
  MedicationSelectionState build() => const MedicationSelectionState();

  void toggle(int id) {
    final current = Set<int>.from(state.selectedIds);
    if (current.contains(id)) {
      current.remove(id);
    } else {
      current.add(id);
    }
    state = state.copyWith(selectedIds: current);
  }

  void selectAll(List<int> ids) {
    state = state.copyWith(selectedIds: Set<int>.from(ids));
  }

  void exit() {
    state = const MedicationSelectionState();
  }
}
