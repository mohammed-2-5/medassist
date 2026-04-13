import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Result of a passphrase prompt.
///
/// - `null` = user cancelled
/// - empty string = user chose to skip encryption (create flow only)
/// - non-empty string = passphrase to use
Future<String?> showBackupPassphraseDialog({
  required BuildContext context,
  required bool isEncrypting,
}) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();
  return showDialog<String?>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        isEncrypting ? l10n.encryptBackupTitle : l10n.enterPassphraseTitle,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isEncrypting
                ? l10n.encryptBackupMessage
                : l10n.enterPassphraseMessage,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.passphrase,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        if (isEncrypting)
          TextButton(
            onPressed: () => Navigator.pop(context, ''),
            child: Text(l10n.skip),
          ),
        FilledButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: Text(isEncrypting ? l10n.encrypt : l10n.decrypt),
        ),
      ],
    ),
  );
}
