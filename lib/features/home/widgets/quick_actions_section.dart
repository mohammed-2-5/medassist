import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/features/home/widgets/quick_action_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// The Quick Actions grid shown on the Home screen.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.quickActions,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              QuickActionCard(
                icon: Icons.bar_chart_rounded,
                label: l10n.viewStats,
                color: const Color(0xFF9C27B0),
                onTap: () => context.push(AppConstants.routeAnalytics),
              ),
              QuickActionCard(
                icon: Icons.auto_awesome_outlined,
                label: l10n.askAI,
                color: const Color(0xFFFF9800),
                onTap: () => context.push(AppConstants.routeChatbot),
              ),
              QuickActionCard(
                icon: Icons.inventory_2_outlined,
                label: l10n.stock,
                color: const Color(0xFFFF5722),
                onTap: () => context.push('/stock'),
              ),
              QuickActionCard(
                icon: Icons.shopping_bag_outlined,
                label: l10n.shoppingList,
                color: const Color(0xFF009688),
                onTap: () => context.push(AppConstants.routeShoppingList),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
