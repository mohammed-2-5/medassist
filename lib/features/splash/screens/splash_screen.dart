import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

/// Premium Animated Splash Screen
///
/// Features:
/// - Logo with scale and fade animation
/// - Slogan with typewriter effect
/// - Gradient background
/// - Auto-navigation after animation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for splash animation to complete (3.5 seconds total)
    await Future.delayed(const Duration(milliseconds: 2800));

    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF00BCD4), // Cyan
              Color(0xFF0097A7), // Darker cyan
              Color(0xFF006064), // Dark teal
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with premium animations
              Image.asset(
                'assets/logo1.png',
                width: size.width * 0.9,
                height: size.width * 0.9,
                fit: BoxFit.contain,
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
              )
              .scale(
                begin: const Offset(0.5, 0.5),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
              )
              .then(delay: const Duration(milliseconds: 200))
              .shimmer(
                duration: const Duration(milliseconds: 1500),
                color: Colors.white.withOpacity(0.3),
              ),

              const SizedBox(height: 40),

              // Slogan with typewriter effect
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    // Main slogan
                    Text(
                      'Say hi to your',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 600),
                    )
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      delay: const Duration(milliseconds: 1000),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                    ),

                    const SizedBox(height: 8),

                    // AI Medical Assistant - highlighted
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'AI Medical Assistant',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                    .animate()
                    .fadeIn(
                      delay: const Duration(milliseconds: 1400),
                      duration: const Duration(milliseconds: 600),
                    )
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.0, 1.0),
                      delay: const Duration(milliseconds: 1400),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                    )
                    .then(delay: const Duration(milliseconds: 200))
                    .shimmer(
                      duration: const Duration(milliseconds: 1500),
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withOpacity(0.8),
                  ),
                ),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 2000),
                duration: const Duration(milliseconds: 600),
              ),

              const SizedBox(height: 20),

              // Powered by text
              Text(
                'Powered by AI',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500,
                ),
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 2200),
                duration: const Duration(milliseconds: 600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
