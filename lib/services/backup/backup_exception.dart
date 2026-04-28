/// Exception thrown when backup/restore operations fail
class BackupException implements Exception {
  BackupException(this.message);

  final String message;

  @override
  String toString() => 'BackupException: $message';
}

/// Thrown when a restore target is encrypted but no passphrase was supplied.
/// Callers catch this, prompt the user, and re-invoke restore with the
/// [filePath] and the entered passphrase.
class BackupEncryptedException extends BackupException {
  BackupEncryptedException(this.filePath)
    : super('Backup is encrypted — passphrase required');

  final String filePath;
}
