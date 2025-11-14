import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/core/widgets/gradient_appbar.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Main Scaffold AppBar Builder
///
/// Creates different AppBars for each screen in the main scaffold.
class MainScaffoldAppBar {
  MainScaffoldAppBar._();

  static PreferredSizeWidget build({
    required BuildContext context,
    required int currentIndex,
    required ThemeData theme,
    required AppLocalizations l10n,
    required VoidCallback onMedicationSort,
  }) {
    final colorScheme = theme.colorScheme;

    // Home screen
    if (currentIndex == 0) {
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
            onPressed: () {
              // TODO: Implement search
            },
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

    // Medications screen
    if (currentIndex == 1) {
      return GradientAppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.medication, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(l10n.medications),
          ],
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            const Color(0xFF00BCD4),
            const Color(0xFF26C6DA),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: onMedicationSort,
            tooltip: l10n.sortBy,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppConstants.routeSettings),
            tooltip: l10n.settings,
          ),
        ],
      );
    }

    // Other screens - generic gradient AppBars
    final titles = [
      l10n.today,
      l10n.medications,
      l10n.reports,
      l10n.reminders,
      'Stock',
      'AI Chat',
    ];

    final icons = [
      Icons.home,
      Icons.medication,
      Icons.analytics,
      Icons.history,
      Icons.inventory,
      Icons.smart_toy,
    ];

    final gradients = [
      null,
      null,
      [const Color(0xFFFF6B6B), const Color(0xFFFF8E53)],
      [const Color(0xFF667EEA), const Color(0xFF764BA2)],
      [const Color(0xFFF093FB), const Color(0xFFF5576C)],
      [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
    ];

    return GradientAppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icons[currentIndex], size: 24, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(titles[currentIndex]),
        ],
      ),
      gradient: gradients[currentIndex] != null
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradients[currentIndex]!,
            )
          : null,
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
