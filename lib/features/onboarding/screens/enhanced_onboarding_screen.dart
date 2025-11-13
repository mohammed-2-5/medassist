import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/settings/providers/settings_provider.dart';
import 'package:med_assist/l10n/app_localizations.dart';

class EnhancedOnboardingScreen extends ConsumerStatefulWidget {

  const EnhancedOnboardingScreen({
    super.key,
    this.onComplete,
  });
  final VoidCallback? onComplete;

  @override
  ConsumerState<EnhancedOnboardingScreen> createState() =>
      _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState
    extends ConsumerState<EnhancedOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _getPages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      OnboardingData(
        title: l10n.welcomeTitle,
        description: l10n.welcomeDescription,
        icon: Icons.medication_rounded,
        gradient: AppColors.primaryGradient,
        accentColor: AppColors.primaryBlue,
      ),
      OnboardingData(
        title: l10n.neverMissTitle,
        description: l10n.neverMissDescription,
        icon: Icons.notifications_active_rounded,
        gradient: AppColors.purpleGradient,
        accentColor: AppColors.accentPurple,
      ),
      OnboardingData(
        title: l10n.trackProgressTitle,
        description: l10n.trackProgressDescription,
        icon: Icons.analytics_rounded,
        gradient: AppColors.successGradient,
        accentColor: AppColors.accentGreen,
      ),
      OnboardingData(
        title: l10n.stayHealthyTitle,
        description: l10n.stayHealthyDescription,
        icon: Icons.favorite_rounded,
        gradient: AppColors.pinkGradient,
        accentColor: AppColors.accentPink,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(BuildContext context) {
    final pages = _getPages(context);
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(settingsProvider.notifier).markOnboardingComplete();

    if (widget.onComplete != null) {
      widget.onComplete!();
    } else {
      if (mounted) {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;
    final pages = _getPages(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundLight,
              AppColors.primaryLight.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar with skip button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_currentPage > 0)
                      IconButton(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.textPrimary,
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                    if (_currentPage < pages.length - 1)
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          l10n.skip,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 48),
                  ],
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(pages[index], index);
                  },
                ),
              ),

              // Page indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => _buildPageIndicator(index == _currentPage, context),
                ),
              ),

              const SizedBox(height: 32),

              // Next/Get Started button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: pages[_currentPage].gradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: pages[_currentPage].accentColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => _nextPage(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      _currentPage == pages.length - 1
                          ? l10n.getStarted
                          : l10n.next,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).animate().scale(delay: 400.ms, duration: 600.ms).fadeIn(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData page, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon container
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: page.gradient,
              boxShadow: [
                BoxShadow(
                  color: page.accentColor.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                page.icon,
                size: 100,
                color: Colors.white,
              ),
            ),
          )
              .animate(key: ValueKey(index))
              .scale(duration: 600.ms, curve: Curves.elasticOut)
              .fadeIn(),

          const SizedBox(height: 60),

          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          )
              .animate(key: ValueKey('${index}_title'))
              .slideY(
                begin: 0.3,
                duration: 500.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          )
              .animate(key: ValueKey('${index}_desc'))
              .slideY(
                begin: 0.3,
                duration: 500.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive, BuildContext context) {
    final pages = _getPages(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        gradient: isActive
            ? pages[_currentPage].gradient
            : null,
        color: isActive ? null : AppColors.textTertiary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.accentColor,
  });
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;
  final Color accentColor;
}
