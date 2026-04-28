import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/models/notification_sound.dart';
import 'package:med_assist/l10n/app_localizations.dart';
import 'package:med_assist/services/ringtone/ringtone_picker_service.dart';

/// Picker for the notification sound used by reminders.
///
/// Two choices:
/// - **Default** — the system's notification tone.
/// - **Custom** — opens the native ringtone picker; the chosen ringtone
///   plays for the actual notification (per-URI Android channel).
class NotificationSoundPicker extends StatefulWidget {
  const NotificationSoundPicker({
    required this.selectedSound,
    required this.onChanged,
    super.key,
  });

  final NotificationSound selectedSound;
  final ValueChanged<NotificationSound> onChanged;

  @override
  State<NotificationSoundPicker> createState() =>
      _NotificationSoundPickerState();
}

class _NotificationSoundPickerState extends State<NotificationSoundPicker> {
  bool _isPlaying = false;
  bool _isPicking = false;
  String? _resolvedTitle;
  Timer? _previewTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_resolveTitleIfNeeded());
  }

  @override
  void didUpdateWidget(NotificationSoundPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedSound.uri != widget.selectedSound.uri) {
      unawaited(_resolveTitleIfNeeded());
    }
  }

  Future<void> _resolveTitleIfNeeded() async {
    final sound = widget.selectedSound;
    if (sound.isDefault) {
      setState(() => _resolvedTitle = null);
      return;
    }
    if (sound.name.isNotEmpty && sound.name != 'Custom') {
      setState(() => _resolvedTitle = sound.name);
      return;
    }
    final title = await RingtonePickerService.getTitle(sound.uri!);
    if (mounted) setState(() => _resolvedTitle = title);
  }

  @override
  void dispose() {
    _previewTimer?.cancel();
    unawaited(RingtonePickerService.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDefault = widget.selectedSound.isDefault;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.volume_up, color: colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              l10n.notificationSound,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _DefaultTile(
                isSelected: isDefault,
                theme: theme,
                colorScheme: colorScheme,
                l10n: l10n,
                onTap: () {
                  unawaited(_stopPreview());
                  widget.onChanged(NotificationSound.defaultSound);
                },
              ),
              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withOpacity(0.5),
              ),
              _CustomTile(
                isSelected: !isDefault,
                isPicking: _isPicking,
                isPlaying: _isPlaying && !isDefault,
                title: _customTileTitle(l10n),
                subtitle: _customTileSubtitle(isDefault, l10n),
                theme: theme,
                colorScheme: colorScheme,
                l10n: l10n,
                onTap: () => unawaited(_openPicker()),
                onPreview: !isDefault
                    ? () => unawaited(_previewCurrent())
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                l10n.soundPickerHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _customTileTitle(AppLocalizations l10n) {
    if (widget.selectedSound.isDefault) return l10n.soundPickFromDevice;
    return _resolvedTitle ?? widget.selectedSound.name;
  }

  String _customTileSubtitle(bool isDefault, AppLocalizations l10n) {
    if (isDefault) return l10n.soundPickFromDeviceHint;
    return l10n.soundTapToChange;
  }

  Future<void> _openPicker() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);
    await _stopPreview();
    final pickerTitle = AppLocalizations.of(context)!.selectNotificationSound;
    final picked = await RingtonePickerService.pick(
      existingUri: widget.selectedSound.uri,
      title: pickerTitle,
    );
    if (!mounted) return;
    setState(() => _isPicking = false);
    if (picked == null) return;
    final sound = NotificationSound.fromUri(picked.uri, title: picked.title);
    setState(() => _resolvedTitle = picked.title);
    widget.onChanged(sound);
  }

  Future<void> _previewCurrent() async {
    final uri = widget.selectedSound.uri;
    if (uri == null) return;
    if (_isPlaying) {
      await _stopPreview();
      return;
    }
    final ok = await RingtonePickerService.play(uri);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.soundPreviewUnavailable),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isPlaying = true);
    _previewTimer?.cancel();
    _previewTimer = Timer(const Duration(seconds: 5), () {
      unawaited(_stopPreview());
    });
  }

  Future<void> _stopPreview() async {
    _previewTimer?.cancel();
    _previewTimer = null;
    await RingtonePickerService.stop();
    if (mounted && _isPlaying) {
      setState(() => _isPlaying = false);
    }
  }
}

class _DefaultTile extends StatelessWidget {
  const _DefaultTile({
    required this.isSelected,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.onTap,
  });

  final bool isSelected;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            _LeadingIcon(
              icon: Icons.notifications_active,
              isSelected: isSelected,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.soundDefault,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.soundDefaultDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colorScheme.primary, size: 24)
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.elasticOut)
                  .fadeIn()
            else
              Icon(
                Icons.radio_button_unchecked,
                color: colorScheme.onSurfaceVariant,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

class _CustomTile extends StatelessWidget {
  const _CustomTile({
    required this.isSelected,
    required this.isPicking,
    required this.isPlaying,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.colorScheme,
    required this.l10n,
    required this.onTap,
    required this.onPreview,
  });

  final bool isSelected;
  final bool isPicking;
  final bool isPlaying;
  final String title;
  final String subtitle;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        child: Row(
          children: [
            _LeadingIcon(
              icon: Icons.library_music,
              isSelected: isSelected,
              colorScheme: colorScheme,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isPicking)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              )
            else if (isPlaying)
              IconButton(
                icon: Icon(Icons.stop_circle, color: colorScheme.primary),
                onPressed: onPreview,
                tooltip: l10n.previewSound,
              )
            else if (onPreview != null)
              IconButton(
                icon: Icon(
                  Icons.play_circle_outline,
                  color: colorScheme.primary,
                ),
                onPressed: onPreview,
                tooltip: l10n.previewSound,
              )
            else
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_circle, color: colorScheme.primary, size: 20)
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.elasticOut)
                  .fadeIn(),
            ],
          ],
        ),
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.icon,
    required this.isSelected,
    required this.colorScheme,
  });

  final IconData icon;
  final bool isSelected;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isSelected
                ? colorScheme.onPrimary
                : colorScheme.onSurfaceVariant,
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(
          duration: 200.ms,
          curve: Curves.easeOut,
        );
  }
}
