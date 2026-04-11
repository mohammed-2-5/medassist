/// Result of a backup import operation
class BackupImportResult {
  BackupImportResult({
    required this.success,
    required this.medicationsImported,
    required this.doseHistoryImported,
    required this.snoozeHistoryImported,
    required this.stockHistoryImported,
    required this.backupDate,
  });

  final bool success;
  final int medicationsImported;
  final int doseHistoryImported;
  final int snoozeHistoryImported;
  final int stockHistoryImported;
  final DateTime backupDate;

  int get totalImported =>
      medicationsImported +
      doseHistoryImported +
      snoozeHistoryImported +
      stockHistoryImported;
}
