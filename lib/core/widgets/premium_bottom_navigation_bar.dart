import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:med_assist/core/database/providers/database_providers.dart';
import 'package:med_assist/core/widgets/glass_container.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Premium Bottom Navigation Bar
///
/// Features:
/// - 6 unique gradient colors per tab
/// - Animated icon backgrounds with scale effects
/// - Shimmer badges for expiring medications and low stock
/// - Glass effect background
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
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final lowStockFuture = ref.watch(appDatabaseProvider).getLowStockMedications();
    final expiringFuture = ref.watch(appDatabaseProvider).getExpiringMedications();

    final tabColors = [
      const Color(0xFF6366F1), // Home - Indigo
      const Color(0xFF10B981), // Medications - Emerald
      const Color(0xFFF59E0B), // Analytics - Amber
      const Color(0xFF8B5CF6), // History - Purple
      const Color(0xFFEC4899), // Stock - Pink
      const Color(0xFF06B6D4), // AI Chat - Cyan
    ];

    final tabIcons = [
      Icons.home_rounded,
      Icons.medication_liquid_rounded,
      Icons.pie_chart_rounded,
      Icons.schedule_rounded,
      Icons.inventory_2_rounded,
      Icons.psychology_rounded,
    ];

    final tabLabels = [
      l10n.home,
      l10n.medications,
      l10n.reports,
      l10n.reminders,
      'Stock',
      'AI',
    ];

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, -10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRect(
        child: GlassContainer(
          blur: 20,
          opacity: theme.brightness == Brightness.dark ? 0.25 : 0.1,
          borderRadius: 0,
          child: SafeArea(
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (index) {
                  final isSelected = currentIndex == index;
                  final color = tabColors[index];

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(index),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  width: isSelected ? 56 : 40,
                                  height: isSelected ? 32 : 28,
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [
                                              color,
                                              color.withOpacity(0.7),
                                            ],
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.4),
                                              blurRadius: 12,
                                              spreadRadius: 0,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Icon(
                                    tabIcons[index],
                                    size: isSelected ? 22 : 20,
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurface.withOpacity(0.6),
                                  ).animate(target: isSelected ? 1 : 0)
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      end: const Offset(1.1, 1.1),
                                      duration: const Duration(milliseconds: 300),
                                    ),
                                ),
                                if (index == 1)
                                  _buildBadge(expiringFuture, colorScheme.error),
                                if (index == 4)
                                  _buildBadge(lowStockFuture, Colors.orange),
                              ],
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              style: theme.textTheme.labelSmall!.copyWith(
                                fontSize: isSelected ? 11 : 10,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? color
                                    : colorScheme.onSurface.withOpacity(0.6),
                                letterSpacing: 0.5,
                              ),
                              child: Text(
                                tabLabels[index],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(Future<List<dynamic>> future, Color color) {
    return FutureBuilder<List<dynamic>>(
      future: future,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final count = snapshot.data!.length;
        if (count == 0) return const SizedBox.shrink();
        
        return Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            constraints: const BoxConstraints(
              minWidth: 18,
              minHeight: 18,
            ),
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate(onPlay: (controller) => controller.repeat())
           .shimmer(
             duration: const Duration(milliseconds: 1500),
             color: Colors.white.withOpacity(0.3),
           ),
        );
      },
    );
  }
}
