import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/constants/app_constants.dart';
import 'package:med_assist/features/home/widgets/quick_action_card.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// The Quick Actions grid row shown on the Home screen.
///
/// [onTakeDoseTap] is called when the user taps "Take Dose" so the parent
/// can scroll the timeline into view.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({
    required this.onTakeDoseTap, super.key,
  });

  final VoidCallback onTakeDoseTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.quickActions,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: Icons.medication,
                  label: l10n.takeDose,
                  color: const Color(0xFF4CAF50),
                  onTap: onTakeDoseTap,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionCard(
                  icon: Icons.add_circle,
                  label: l10n.addMedicine,
                  color: const Color(0xFF2196F3),
                  onTap: () => context.push(AppConstants.routeAddReminder),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: QuickActionCard(
                  icon: Icons.analytics,
                  label: l10n.viewStats,
                  color: const Color(0xFF9C27B0),
                  onTap: () => context.push('/analytics'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionCard(
                  icon: Icons.chat,
                  label: l10n.askAI,
                  color: const Color(0xFFFF9800),
                  onTap: () => context.push('/chatbot'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
