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
            icon: const Icon(Icons.inventory_2_rounded),
            onPressed: () => context.push('/stock'),
            tooltip: l10n.stockOverview,
          ),
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

    // Analytics screen
    if (currentIndex == 2) {
      return GradientAppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics, size: 24, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(l10n.analytics),
          ],
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push('/history'),
            tooltip: l10n.history,
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppConstants.routeSettings),
            tooltip: l10n.settings,
          ),
        ],
      );
    }

    // AI Chat screen
    return GradientAppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy, size: 24, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(l10n.aiAssistant),
        ],
      ),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
      ),
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
