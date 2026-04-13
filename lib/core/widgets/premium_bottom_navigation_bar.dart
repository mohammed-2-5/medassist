import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/app_database.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Modern bottom navigation bar. Single-accent Material 3 look with an
/// animated expanding pill for the selected tab.
class PremiumBottomNavigationBar extends ConsumerWidget {
  const PremiumBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final db = ref.watch(appDatabaseProvider);

    final tabs = <_NavTab>[
      _NavTab(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: l10n.home,
      ),
      _NavTab(
        icon: Icons.medication_outlined,
        selectedIcon: Icons.medication_rounded,
        label: l10n.medications,
      ),
      _NavTab(
        icon: Icons.insights_outlined,
        selectedIcon: Icons.insights_rounded,
        label: l10n.analytics,
      ),
      _NavTab(
        icon: Icons.auto_awesome_outlined,
        selectedIcon: Icons.auto_awesome_rounded,
        label: l10n.aiAssistant,
      ),
    ];

    final barColor = isDark
        ? colorScheme.surfaceContainerHigh
        : colorScheme.surface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: barColor,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(
                    child: _NavItem(
                      tab: tabs[i],
                      isSelected: currentIndex == i,
                      onTap: () => onTap(i),
                      badge: i == 1
                          ? _AlertBadge(database: db)
                          : null,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final _NavTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedFg = colorScheme.onPrimaryContainer;
    final unselectedFg = colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        splashColor: colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: colorScheme.primary.withValues(alpha: 0.06),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primaryContainer
                : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: anim,
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      isSelected ? tab.selectedIcon : tab.icon,
                      key: ValueKey<bool>(isSelected),
                      size: 22,
                      color: isSelected ? selectedFg : unselectedFg,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      right: -6,
                      top: -4,
                      child: badge!,
                    ),
                ],
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      tab.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedFg,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({required this.database});

  final AppDatabase database;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<int>>(
      future: Future.wait([
        database.getLowStockMedications().then((l) => l.length),
        database.getExpiringMedications().then((l) => l.length),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.length < 2) {
          return const SizedBox.shrink();
        }
        final count = snapshot.data![0] + snapshot.data![1];
        if (count == 0) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
          decoration: BoxDecoration(
            color: colorScheme.error,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.surface,
              width: 1.5,
            ),
          ),
          child: Text(
            count > 9 ? '9+' : '$count',
            style: TextStyle(
              color: colorScheme.onError,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }
}
