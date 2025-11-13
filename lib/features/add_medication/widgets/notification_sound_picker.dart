import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:med_assist/core/models/notification_sound.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Widget for selecting notification sound with preview
class NotificationSoundPicker extends StatefulWidget {

  const NotificationSoundPicker({
    required this.selectedSound, required this.onChanged, super.key,
  });
  final NotificationSound selectedSound;
  final ValueChanged<NotificationSound> onChanged;

  @override
  State<NotificationSoundPicker> createState() =>
      _NotificationSoundPickerState();
}

class _NotificationSoundPickerState extends State<NotificationSoundPicker> {
  String? _playingId;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.volume_up,
              color: colorScheme.primary,
              size: 20,
            ),
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
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: NotificationSound.presets.asMap().entries.map((entry) {
              final index = entry.key;
              final sound = entry.value;
              final isFirst = index == 0;
              final isLast = index == NotificationSound.presets.length - 1;
              final isSelected = sound.id == widget.selectedSound.id;
              final isPlaying = _playingId == sound.id;

              return _buildSoundTile(
                sound: sound,
                isSelected: isSelected,
                isPlaying: isPlaying,
                isFirst: isFirst,
                isLast: isLast,
                theme: theme,
                colorScheme: colorScheme,
                l10n: l10n,
              );
            }).toList(),
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
                'Tap to select, long press to preview',
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

  Widget _buildSoundTile({
    required NotificationSound sound,
    required bool isSelected,
    required bool isPlaying,
    required bool isFirst,
    required bool isLast,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required AppLocalizations l10n,
  }) {
    return InkWell(
      onTap: () {
        widget.onChanged(sound);
        setState(() {
          _playingId = null;
        });
      },
      onLongPress: () {
        _previewSound(sound);
      },
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer.withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(16) : Radius.zero,
            bottom: isLast ? const Radius.circular(16) : Radius.zero,
          ),
          border: !isLast
              ? Border(
                  bottom: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                sound.icon,
                size: 20,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            )
                .animate(target: isSelected ? 1 : 0)
                .scale(duration: 200.ms, curve: Curves.easeOut),
            const SizedBox(width: 16),

            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getLocalizedName(sound, l10n),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getLocalizedDescription(sound, l10n),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? colorScheme.onPrimaryContainer.withOpacity(0.7)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Preview/Selected indicator
            if (isPlaying)
              Container(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
              )
                  .animate(onPlay: (controller) => controller.repeat())
                  .fadeIn()
            else if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 24,
              )
                  .animate()
                  .scale(
                    duration: 300.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn()
            else
              IconButton(
                icon: Icon(
                  Icons.play_circle_outline,
                  color: colorScheme.primary,
                ),
                onPressed: () => _previewSound(sound),
                tooltip: l10n.previewSound,
              ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedName(NotificationSound sound, AppLocalizations l10n) {
    switch (sound.id) {
      case 'default':
        return l10n.soundDefault;
      case 'notification':
        return l10n.soundNotification;
      case 'reminder':
        return l10n.soundReminder;
      case 'alert':
        return l10n.soundAlert;
      default:
        return sound.name;
    }
  }

  String _getLocalizedDescription(
      NotificationSound sound, AppLocalizations l10n) {
    switch (sound.id) {
      case 'default':
        return l10n.soundDefaultDescription;
      case 'notification':
        return l10n.soundNotificationDescription;
      case 'reminder':
        return l10n.soundReminderDescription;
      case 'alert':
        return l10n.soundAlertDescription;
      default:
        return sound.description;
    }
  }

  Future<void> _previewSound(NotificationSound sound) async {
    try {
      // Stop any currently playing sound
      await _audioPlayer.stop();

      setState(() {
        _playingId = sound.id;
      });

      if (sound.path != null) {
        // Play custom sound from file path
        await _audioPlayer.play(DeviceFileSource(sound.path!));
      } else {
        // For system sounds, play a default notification sound asset
        // Since we don't have audio files, we'll use a notification sound URL
        // You can add actual sound files to assets later
        await _audioPlayer.play(AssetSource('sounds/notification.mp3')).catchError((e) {
          // If asset doesn't exist, show message instead
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "This will use your device's ${_getLocalizedName(sound, AppLocalizations.of(context)!)} sound"
                ),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      }

      // Listen for completion
      _audioPlayer.onPlayerComplete.listen((event) {
        if (mounted) {
          setState(() {
            _playingId = null;
          });
        }
      });

      // Auto-stop after 3 seconds for system sounds
      if (sound.path == null) {
        await Future.delayed(const Duration(seconds: 3));
        if (mounted && _playingId == sound.id) {
          await _audioPlayer.stop();
          setState(() {
            _playingId = null;
          });
        }
      }
    } catch (e) {
      // Handle any errors gracefully
      if (mounted) {
        setState(() {
          _playingId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Preview unavailable. This will use your device's notification sound."
            ),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
