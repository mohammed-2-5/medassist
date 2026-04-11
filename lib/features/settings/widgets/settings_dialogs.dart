import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

Future<void> showThemeDialog({
  required BuildContext context,
  required ThemeMode selectedThemeMode,
  required Future<void> Function(ThemeMode) onThemeChanged,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.chooseTheme),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<ThemeMode>(
            title: Text(l10n.light),
            subtitle: Text(l10n.alwaysLight),
            value: ThemeMode.light,
            groupValue: selectedThemeMode,
            onChanged: (value) async {
              if (value != null) {
                await onThemeChanged(value);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.dark),
            subtitle: Text(l10n.alwaysDark),
            value: ThemeMode.dark,
            groupValue: selectedThemeMode,
            onChanged: (value) async {
              if (value != null) {
                await onThemeChanged(value);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<ThemeMode>(
            title: Text(l10n.systemDefault),
            subtitle: Text(l10n.followSystem),
            value: ThemeMode.system,
            groupValue: selectedThemeMode,
            onChanged: (value) async {
              if (value != null) {
                await onThemeChanged(value);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showLanguageDialog({
  required BuildContext context,
  required String selectedLanguageCode,
  required Future<void> Function(String) onLanguageChanged,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.chooseLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<String>(
            title: Text(l10n.english),
            subtitle: Text(l10n.english),
            value: 'en',
            groupValue: selectedLanguageCode,
            onChanged: (value) async {
              if (value != null) {
                await onLanguageChanged(value);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
          RadioListTile<String>(
            title: Text(l10n.arabic),
            subtitle: Text(l10n.arabic),
            value: 'ar',
            groupValue: selectedLanguageCode,
            onChanged: (value) async {
              if (value != null) {
                await onLanguageChanged(value);
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showResetDialog({
  required BuildContext context,
  required Future<void> Function() onReset,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.resetSettings),
      content: Text(l10n.resetSettingsConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () async {
            await onReset();
            if (context.mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.settingsReset),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          child: Text(l10n.reset),
        ),
      ],
    ),
  );
}
