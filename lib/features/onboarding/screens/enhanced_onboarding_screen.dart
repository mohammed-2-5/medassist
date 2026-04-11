import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:med_assist/core/theme/app_colors.dart';
import 'package:med_assist/features/onboarding/models/onboarding_data.dart';
import 'package:med_assist/features/onboarding/widgets/onboarding_page_content.dart';
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
    final pages = OnboardingData.getPages(context);
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

  Future<void> _completeOnboarding() async {
    try {
      await ref.read(settingsProvider.notifier).markOnboardingComplete();
    } catch (_) {
      // Settings persistence failure is non-fatal — navigate forward anyway.
    }
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
    final pages = OnboardingData.getPages(context);

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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        onPressed: _completeOnboarding,
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
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: pages.length,
                  itemBuilder: (context, index) => OnboardingPageContent(
                    page: pages[index],
                    index: index,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) =>
                      _buildPageIndicator(index == _currentPage, pages),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: size.width,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: pages[_currentPage].gradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color:
                              pages[_currentPage].accentColor.withOpacity(0.3),
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

  Widget _buildPageIndicator(bool isActive, List<OnboardingData> pages) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        gradient: isActive ? pages[_currentPage].gradient : null,
        color: isActive ? null : AppColors.textTertiary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
