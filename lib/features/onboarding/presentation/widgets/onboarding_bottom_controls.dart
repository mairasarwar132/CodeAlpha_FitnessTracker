import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';

/// A presentation widget rendering the bottom navigation bar of the onboarding flow.
///
/// Houses the [SmoothPageIndicator] aligned alongside the Next / Get Started controls.
/// All controls feature Semantic descriptors to support screen reader accessibility.
class OnboardingBottomControls extends StatelessWidget {
  const OnboardingBottomControls({
    required this.pageController,
    required this.currentPageIndex,
    required this.pageCount,
    required this.onNextPressed,
    super.key,
  });

  final PageController pageController;
  final int currentPageIndex;
  final int pageCount;
  final VoidCallback onNextPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = currentPageIndex == pageCount - 1;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Smooth Page Indicator dots
          Semantics(
            label: 'Onboarding page indicator. Page ${currentPageIndex + 1} of $pageCount',
            excludeSemantics: true,
            child: SmoothPageIndicator(
              controller: pageController,
              count: pageCount,
              effect: ExpandingDotsEffect(
                activeDotColor: theme.colorScheme.primary,
                dotColor: theme.colorScheme.primary.withAlpha(60),
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
                spacing: 8,
              ),
            ),
          ),

          // 2. Action Button (Next or Get Started)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              );
            },
            child: isLastPage
                ? Semantics(
                    label: 'Get Started. Complete onboarding and open application dashboard.',
                    button: true,
                    excludeSemantics: true,
                    onTap: onNextPressed,
                    child: ElevatedButton(
                      key: const Key('onboarding_get_started_button'),
                      onPressed: onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        AppStrings.onboardingGetStarted,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Semantics(
                    label: 'Next page.',
                    button: true,
                    excludeSemantics: true,
                    onTap: onNextPressed,
                    child: ElevatedButton(
                      key: const Key('onboarding_next_button'),
                      onPressed: onNextPressed,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        AppStrings.onboardingNext,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
