import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/features/splash/widgets/splash_ai_pill.dart';
import 'package:med_assist/features/splash/widgets/splash_background.dart';
import 'package:med_assist/features/splash/widgets/splash_dot_loader.dart';
import 'package:med_assist/features/splash/widgets/splash_logo_emblem.dart';
import 'package:med_assist/l10n/app_localizations.dart';

/// Midnight-themed animated splash. Auto-navigates to /home after 3.2s.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const Duration _navigateAfter = Duration(milliseconds: 3200);

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _navigationTimer = Timer(_navigateAfter, () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const RepaintBoundary(child: SplashBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  SplashLogoEmblem(diameter: size.width * 0.62),
                  const SizedBox(height: 40),
                  _buildSlogan(theme, l10n.splashGreeting),
                  const SizedBox(height: 14),
                  SplashAiPill(label: l10n.splashAiTitle),
                  const Spacer(flex: 3),
                  const SplashDotLoader().animate().fadeIn(
                        delay: const Duration(milliseconds: 1900),
                        duration: const Duration(milliseconds: 500),
                      ),
                  const SizedBox(height: 14),
                  _buildPoweredBy(theme, l10n.poweredByAi),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlogan(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        text,
        style: theme.textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w300,
          letterSpacing: 1.4,
          height: 1.3,
        ),
        textAlign: TextAlign.center,
      )
          .animate()
          .fadeIn(
            delay: const Duration(milliseconds: 900),
            duration: const Duration(milliseconds: 700),
          )
          .slideY(
            begin: 0.3,
            end: 0,
            delay: const Duration(milliseconds: 900),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
          ),
    );
  }

  Widget _buildPoweredBy(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodySmall?.copyWith(
        color: Colors.white.withValues(alpha: 0.75),
        letterSpacing: 3,
        fontWeight: FontWeight.w500,
      ),
    ).animate().fadeIn(
          delay: const Duration(milliseconds: 2100),
          duration: const Duration(milliseconds: 600),
        );
  }
}
