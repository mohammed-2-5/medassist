/// Dose Event Model
///
/// Represents a scheduled medication dose
class DoseEvent {

  const DoseEvent({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.dosage,
    required this.time,
    required this.status,
    this.instructions,
    this.stockRemaining,
  });
  final String id;
  final String medicationId;
  final String medicationName;
  final String dosage;
  final String time;
  final DoseStatus status;
  final String? instructions;
  final int? stockRemaining;

  DoseEvent copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    String? dosage,
    String? time,
    DoseStatus? status,
    String? instructions,
    int? stockRemaining,
  }) {
    return DoseEvent(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      dosage: dosage ?? this.dosage,
      time: time ?? this.time,
      status: status ?? this.status,
      instructions: instructions ?? this.instructions,
      stockRemaining: stockRemaining ?? this.stockRemaining,
    );
  }
}

/// Dose Status Enum
enum DoseStatus {
  pending,  // Not yet taken
  taken,    // Marked as taken
  missed,   // Missed the dose time
  skipped,  // Intentionally skipped
  snoozed,  // Snoozed for later
}

/// Adherence Summary Model
class AdherenceSummary {

  const AdherenceSummary({
    required this.takenToday,
    required this.totalToday,
    required this.currentStreak,
  });
  final int takenToday;
  final int totalToday;
  final int currentStreak;

  int get adherencePercentage =>
      totalToday > 0 ? (takenToday / totalToday * 100).round() : 0;
}
