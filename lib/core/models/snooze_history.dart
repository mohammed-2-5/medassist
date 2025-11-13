/// Model for tracking snooze history and limits
class SnoozeHistory {

  const SnoozeHistory({
    required this.id,
    required this.medicationId,
    required this.snoozeDate,
    required this.snoozeCount,
    required this.lastSnoozeTime,
    required this.suggestedMinutes,
  });
  final int id;
  final int medicationId;
  final DateTime snoozeDate;
  final int snoozeCount;
  final DateTime lastSnoozeTime;
  final int suggestedMinutes;

  /// Check if max snoozes reached for today
  bool isLimitReached(int maxSnoozes) {
    return snoozeCount >= maxSnoozes;
  }

  /// Get remaining snoozes for today
  int getRemainingSnoozes(int maxSnoozes) {
    return (maxSnoozes - snoozeCount).clamp(0, maxSnoozes);
  }

  SnoozeHistory copyWith({
    int? id,
    int? medicationId,
    DateTime? snoozeDate,
    int? snoozeCount,
    DateTime? lastSnoozeTime,
    int? suggestedMinutes,
  }) {
    return SnoozeHistory(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      snoozeDate: snoozeDate ?? this.snoozeDate,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      lastSnoozeTime: lastSnoozeTime ?? this.lastSnoozeTime,
      suggestedMinutes: suggestedMinutes ?? this.suggestedMinutes,
    );
  }
}

/// Smart snooze time suggestion model
class SnoozeSuggestion {

  const SnoozeSuggestion({
    required this.minutes,
    required this.label,
    required this.reason,
    this.isRecommended = false,
  });
  final int minutes;
  final String label;
  final String reason;
  final bool isRecommended;

  /// Standard snooze presets
  static const List<SnoozeSuggestion> standardPresets = [
    SnoozeSuggestion(
      minutes: 5,
      label: '5 min',
      reason: 'Quick reminder',
    ),
    SnoozeSuggestion(
      minutes: 15,
      label: '15 min',
      reason: 'Short break',
      isRecommended: true,
    ),
    SnoozeSuggestion(
      minutes: 30,
      label: '30 min',
      reason: 'Half hour',
    ),
    SnoozeSuggestion(
      minutes: 60,
      label: '1 hour',
      reason: 'Long delay',
    ),
  ];

  /// Calculate smart suggestions based on next dose time
  static List<SnoozeSuggestion> getSmartSuggestions({
    required DateTime now,
    required int maxSnoozes, required int currentSnoozeCount, DateTime? nextDoseTime,
  }) {
    final suggestions = <SnoozeSuggestion>[];
    final remainingSnoozes = (maxSnoozes - currentSnoozeCount).clamp(0, maxSnoozes);

    if (remainingSnoozes == 0) {
      // No snoozes left, suggest taking now
      return [
        const SnoozeSuggestion(
          minutes: 0,
          label: 'Take Now',
          reason: 'Snooze limit reached',
          isRecommended: true,
        ),
      ];
    }

    if (nextDoseTime != null) {
      final minutesUntilNext = nextDoseTime.difference(now).inMinutes;

      if (minutesUntilNext > 120) {
        // More than 2 hours until next dose - offer longer snoozes
        suggestions.addAll([
          const SnoozeSuggestion(
            minutes: 15,
            label: '15 min',
            reason: 'Quick reminder',
          ),
          const SnoozeSuggestion(
            minutes: 30,
            label: '30 min',
            reason: 'Half hour',
            isRecommended: true,
          ),
          SnoozeSuggestion(
            minutes: 60,
            label: '1 hour',
            reason: '$remainingSnoozes snoozes left',
          ),
        ]);
      } else if (minutesUntilNext > 60) {
        // 1-2 hours until next dose
        suggestions.addAll([
          const SnoozeSuggestion(
            minutes: 10,
            label: '10 min',
            reason: 'Quick reminder',
          ),
          const SnoozeSuggestion(
            minutes: 20,
            label: '20 min',
            reason: 'Short break',
            isRecommended: true,
          ),
          SnoozeSuggestion(
            minutes: 30,
            label: '30 min',
            reason: '$remainingSnoozes snoozes left',
          ),
        ]);
      } else if (minutesUntilNext > 30) {
        // 30 min - 1 hour until next dose
        suggestions.addAll([
          const SnoozeSuggestion(
            minutes: 5,
            label: '5 min',
            reason: 'Quick reminder',
          ),
          const SnoozeSuggestion(
            minutes: 15,
            label: '15 min',
            reason: 'Before next dose',
            isRecommended: true,
          ),
          SnoozeSuggestion(
            minutes: 20,
            label: '20 min',
            reason: '$remainingSnoozes snoozes left',
          ),
        ]);
      } else {
        // Less than 30 min until next dose - short snoozes only
        suggestions.addAll([
          const SnoozeSuggestion(
            minutes: 5,
            label: '5 min',
            reason: 'Very quick',
            isRecommended: true,
          ),
          const SnoozeSuggestion(
            minutes: 10,
            label: '10 min',
            reason: 'Short reminder',
          ),
          SnoozeSuggestion(
            minutes: 15,
            label: '15 min',
            reason: 'Next dose soon ($remainingSnoozes left)',
          ),
        ]);
      }
    } else {
      // No next dose scheduled, use standard presets
      return standardPresets;
    }

    return suggestions;
  }
}
