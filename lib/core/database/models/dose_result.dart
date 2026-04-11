import 'package:med_assist/core/database/repositories/medication_repository.dart' show MedicationRepository;

/// Result of a dose recording operation.
///
/// Used by [MedicationRepository] to communicate outcomes back to the UI
/// and notification layers without throwing exceptions for expected cases.
sealed class DoseResult {
  const DoseResult();
}

/// Dose was successfully recorded (and stock deducted if applicable).
class DoseRecorded extends DoseResult {
  const DoseRecorded({this.stockWarning});

  /// Non-null when stock is zero or went below the dose amount.
  final String? stockWarning;
}

/// A record for this dose already exists with the same status.
class DoseAlreadyRecorded extends DoseResult {
  const DoseAlreadyRecorded();
}

/// The referenced medication was not found in the database.
class DoseMedicationNotFound extends DoseResult {
  const DoseMedicationNotFound();
}

/// An unexpected error occurred during the operation.
class DoseOperationFailed extends DoseResult {
  const DoseOperationFailed(this.message);
  final String message;
}
