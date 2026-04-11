import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/features/settings/widgets/backup_restore_content.dart';
import 'package:med_assist/features/settings/widgets/backup_restore_dialogs.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/backup/backup_service.dart';
import 'package:med_assist/services/haptic/haptic_service.dart';

/// Backup & Restore screen for data management
class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() =>
      _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isProcessing = false;
  DateTime? _lastBackupDate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.backupRestore),
        centerTitle: true,
      ),
      body: BackupRestoreContent(
        isProcessing: _isProcessing,
        lastBackupDate: _lastBackupDate,
        onCreateBackup: _createBackup,
        onShareBackup: _shareBackup,
        onRestoreBackup: _restoreBackup,
      ),
    );
  }

  Future<void> _createBackup() async {
    try {
      setState(() => _isProcessing = true);
      await HapticService.light();

      final database = ref.read(appDatabaseProvider);
      final backupService = BackupService(database);

      await backupService.createBackup();

      setState(() {
        _isProcessing = false;
        _lastBackupDate = DateTime.now();
      });

      if (!mounted) return;

      await HapticService.success();
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.backupCreatedSuccessfully),
          backgroundColor: Theme.of(context).colorScheme.primary,
          action: SnackBarAction(
            label: l10n.ok,
            textColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: () {},
          ),
        ),
      );
    } on Object catch (e) {
      setState(() => _isProcessing = false);

      if (!mounted) return;

      await HapticService.error();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedToCreateBackup(e.toString()),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _shareBackup() async {
    try {
      setState(() => _isProcessing = true);
      await HapticService.light();

      final database = ref.read(appDatabaseProvider);
      final backupService = BackupService(database);

      await backupService.shareBackup();

      setState(() {
        _isProcessing = false;
        _lastBackupDate = DateTime.now();
      });

      if (!mounted) return;

      await HapticService.success();
    } on Object catch (e) {
      setState(() => _isProcessing = false);

      if (!mounted) return;

      await HapticService.error();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedToShareBackup(e.toString()),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _restoreBackup() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showRestoreConfirmationDialog(context, l10n);

    if (confirmed != true) return;

    try {
      setState(() => _isProcessing = true);
      await HapticService.medium();

      final database = ref.read(appDatabaseProvider);
      final backupService = BackupService(database);

      final result = await backupService.restoreBackup();

      setState(() => _isProcessing = false);

      if (!mounted) return;

      await HapticService.success();
      if (!mounted) return;
      await showRestoreCompleteDialog(context, l10n, result);
      if (!mounted) return;
      ref.invalidate(medicationsProvider);
    } on Object catch (e) {
      setState(() => _isProcessing = false);

      if (!mounted) return;

      await HapticService.error();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToRestoreBackup(e.toString())),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
