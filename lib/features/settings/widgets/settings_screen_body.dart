import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/settings/providers/settings_provider.dart';
import 'package:med_assist/features/settings/widgets/settings_section_header.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreenBody extends ConsumerStatefulWidget {
  const SettingsScreenBody({
    required this.packageInfo,
    required this.onShowThemeDialog,
    required this.onShowLanguageDialog,
    required this.onShowResetDialog,
    super.key,
  });

  final PackageInfo? packageInfo;
  final VoidCallback onShowThemeDialog;
  final VoidCallback onShowLanguageDialog;
  final VoidCallback onShowResetDialog;

  @override
  ConsumerState<SettingsScreenBody> createState() => _SettingsScreenBodyState();
}

class _SettingsScreenBodyState extends ConsumerState<SettingsScreenBody> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(List<String> keywords) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return keywords.any((k) => k.toLowerCase().contains(q));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final cs = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.search,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: cs.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 24),

        // Appearance
        if (_matches([
          'appearance',
          'theme',
          'dark',
          'light',
          l10n.appearance,
          l10n.themeMode,
        ])) ...[
          SettingsSectionHeader(title: l10n.appearance, icon: Icons.palette),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.brightness_6, color: cs.primary),
              title: Text(l10n.themeMode),
              subtitle: Text(_themeModeLabel(settings.themeMode, l10n)),
              trailing: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
              ),
              onTap: widget.onShowThemeDialog,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Notifications (nav tile → subpage)
        if (_matches([
          'notification',
          'sound',
          'vibration',
          'snooze',
          'alert',
          'stock',
          'expiry',
          l10n.notifications,
          l10n.alerts,
        ])) ...[
          SettingsSectionHeader(
            title: l10n.notifications,
            icon: Icons.notifications,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                settings.notificationsEnabled
                    ? Icons.notifications_active
                    : Icons.notifications_off,
                color: settings.notificationsEnabled
                    ? cs.primary
                    : cs.onSurfaceVariant,
              ),
              title: Text(l10n.notifications),
              subtitle: Text(
                settings.notificationsEnabled
                    ? l10n.enableNotifications
                    : l10n.notificationsDisabled,
              ),
              trailing: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
              ),
              onTap: () => context.push('/settings/notifications'),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Language
        if (_matches([
          'language',
          'english',
          'arabic',
          l10n.language,
          l10n.appLanguage,
        ])) ...[
          SettingsSectionHeader(title: l10n.language, icon: Icons.language),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(Icons.translate, color: cs.primary),
              title: Text(l10n.appLanguage),
              subtitle: Text(_languageLabel(settings.languageCode, l10n)),
              trailing: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
              ),
              onTap: widget.onShowLanguageDialog,
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Data & Backup — prominent card
        if (_matches([
          'data',
          'backup',
          'restore',
          'reset',
          l10n.data,
          l10n.backupRestore,
        ])) ...[
          SettingsSectionHeader(title: l10n.data, icon: Icons.storage),
          const SizedBox(height: 8),
          _BackupProminentCard(onResetDialog: widget.onShowResetDialog),
          const SizedBox(height: 24),
        ],

        // About
        if (_matches([
          'about',
          'version',
          'build',
          l10n.about,
          l10n.version,
        ])) ...[
          SettingsSectionHeader(title: l10n.about, icon: Icons.info),
          const SizedBox(height: 8),
          _AboutSection(packageInfo: widget.packageInfo),
          const SizedBox(height: 32),
        ],

        // Auto-save hint
        if (_query.isEmpty)
          Card(
            color: cs.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: cs.onPrimaryContainer),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.settingsAutoSaved,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _themeModeLabel(ThemeMode mode, AppLocalizations l10n) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.light;
      case ThemeMode.dark:
        return l10n.dark;
      case ThemeMode.system:
        return l10n.systemDefault;
    }
  }

  String _languageLabel(String code, AppLocalizations l10n) {
    if (code == 'ar') return l10n.arabic;
    return l10n.english;
  }
}

class _BackupProminentCard extends StatelessWidget {
  const _BackupProminentCard({required this.onResetDialog});

  final VoidCallback onResetDialog;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer,
              cs.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.backup, color: cs.primary),
              ),
              title: Text(
                l10n.backupRestore,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(l10n.backupRestoreSubtitle),
              trailing: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
              ),
              onTap: () => context.push('/settings/backup'),
            ),
            Divider(
              height: 1,
              color: cs.onPrimaryContainer.withValues(alpha: 0.1),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.restore, color: cs.error),
              ),
              title: Text(l10n.resetToDefaults),
              subtitle: Text(l10n.restoreAllSettings),
              onTap: onResetDialog,
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.packageInfo});

  final PackageInfo? packageInfo;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.apps, color: cs.primary),
            title: Text(l10n.appName),
            subtitle: Text(packageInfo?.appName ?? 'Med Assist'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.info_outline, color: cs.primary),
            title: Text(l10n.version),
            subtitle: Text(packageInfo?.version ?? '1.0.0'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.build, color: cs.primary),
            title: Text(l10n.buildNumber),
            subtitle: Text(packageInfo?.buildNumber ?? '1'),
          ),
        ],
      ),
    );
  }
}
