import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Builds the [AppBar] for the Home screen.
///
/// When [hasMedications] is true a richer title with the current date and an
/// additional search action is shown; otherwise a simpler variant is returned.
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({required this.hasMedications, super.key});

  final bool hasMedications;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (hasMedications) {
      final today = DateTime.now();
      final dateFormat = DateFormat('EEEE, MMM d');

      return AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.today,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              dateFormat.format(today),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/medications'),
            tooltip: l10n.searchMedications,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppConstants.routeSettings),
            tooltip: l10n.settings,
          ),
        ],
      );
    }

    return AppBar(
      title: Text(l10n.today),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(AppConstants.routeSettings),
          tooltip: l10n.settings,
        ),
      ],
    );
  }
}
