/// Exception thrown when backup/restore operations fail
class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => 'BackupException: $message';
}
