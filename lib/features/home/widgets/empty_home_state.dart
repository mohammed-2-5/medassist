import 'package:flutter/material.dart';

/// Empty Home State - First-time user experience
class EmptyHomeState extends StatelessWidget {

  const EmptyHomeState({
    required this.onAddMedicationPressed,
    required this.onLearnMorePressed,
    super.key,
  });
  final VoidCallback onAddMedicationPressed;
  final VoidCallback onLearnMorePressed;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: 24,
          vertical: size.height * 0.1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _HeroIllustration(),
            const SizedBox(height: 48),
            _WelcomeMessage(),
            const SizedBox(height: 40),
            _PrimaryCTA(onPressed: onAddMedicationPressed),
            const SizedBox(height: 16),
            _SecondaryCTA(onPressed: onLearnMorePressed),
            const SizedBox(height: 128),

          ],
        ),
      ),
      bottomNavigationBar: const _QuickTips(),
    );
  }
}

/// Hero illustration with concentric circles
class _HeroIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.medication_liquid_rounded,
          size: 80,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

/// Welcome message
class _WelcomeMessage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          "Let's set up your first reminder",
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Add a medicine to get precise, on-time alerts—even offline.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Primary CTA button
class _PrimaryCTA extends StatelessWidget {

  const _PrimaryCTA({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.add_circle_outline, size: 24),
      label: const Text(
        'Add Medicine',
        style: TextStyle(fontSize: 16),
      ),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        minimumSize: const Size(200, 56),
      ),
    );
  }
}

/// Secondary CTA button
class _SecondaryCTA extends StatelessWidget {

  const _SecondaryCTA({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.info_outline, size: 20, color: colorScheme.primary),
      label: Text(
        'Learn how it works',
        style: TextStyle(fontSize: 15, color: colorScheme.primary),
      ),
    );
  }
}

/// Quick dismissible tips
class _QuickTips extends StatefulWidget {
  const _QuickTips();

  @override
  State<_QuickTips> createState() => _QuickTipsState();
}

class _QuickTipsState extends State<_QuickTips> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      height: 150,
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TipsHeader(onDismiss: () => setState(() => _isDismissed = true)),
          const SizedBox(height: 12),
          const _TipItem(
            icon: Icons.snooze,
            text: "You can snooze a reminder if you're busy",
          ),
          const SizedBox(height: 12),
          const _TipItem(
            icon: Icons.lock_outline,
            text: 'We never upload your data without your consent',
          ),
        ],
      ),
    );
  }
}

/// Tips header with dismiss button
class _TipsHeader extends StatelessWidget {

  const _TipsHeader({required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Quick Tips',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, size: 18, color: colorScheme.onSurfaceVariant),
          onPressed: onDismiss,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          tooltip: 'Dismiss',
        ),
      ],
    );
  }
}

/// Individual tip item
class _TipItem extends StatelessWidget {

  const _TipItem({
    required this.icon,
    required this.text,
  });
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
