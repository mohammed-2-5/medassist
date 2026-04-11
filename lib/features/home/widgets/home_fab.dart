import 'package:flutter/material.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// The animated Floating Action Button shown on the Home screen.
class HomeFab extends StatelessWidget {
  const HomeFab({
    required this.animationController, required this.onPressed, super.key,
  });

  final AnimationController animationController;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ScaleTransition(
      scale: CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.5, 1, curve: Curves.elasticOut),
      ),
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: Text(l10n.addMedicine),
        elevation: 4,
      ),
    );
  }
}
