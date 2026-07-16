import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';
import 'package:fitness_tracker/features/onboarding/presentation/models/onboarding_page_model.dart';
import 'package:fitness_tracker/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:fitness_tracker/features/onboarding/presentation/widgets/onboarding_bottom_controls.dart';
import 'package:fitness_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';

/// The onboarding flow screen.
///
/// Ties together page data models, page widgets, bottom page indicators, skip/next/get-started
/// actions and manages overall state synchronization using [onboardingProvider].
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<OnboardingPageModel> _pages = const [
    OnboardingPageModel(
      title: AppStrings.onboardingTitle1,
      subtitle: AppStrings.onboardingSubtitle1,
      icon: Icons.fitness_center,
    ),
    OnboardingPageModel(
      title: AppStrings.onboardingTitle2,
      subtitle: AppStrings.onboardingSubtitle2,
      icon: Icons.directions_run,
    ),
    OnboardingPageModel(
      title: AppStrings.onboardingTitle3,
      subtitle: AppStrings.onboardingSubtitle3,
      icon: Icons.insights,
    ),
    OnboardingPageModel(
      title: AppStrings.onboardingTitle4,
      subtitle: AppStrings.onboardingSubtitle4,
      icon: Icons.emoji_events,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPageIndex = ref.watch(onboardingProvider);
    final isLastPage = currentPageIndex == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button bar (fades away on last page)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: AnimatedOpacity(
                  opacity: isLastPage ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: isLastPage,
                    child: Semantics(
                      label: 'Skip onboarding flow directly to the final screen.',
                      button: true,
                      excludeSemantics: true,
                      onTap: () {
                        ref.read(onboardingProvider.notifier).skip(_pageController);
                      },
                      child: TextButton(
                        key: const Key('onboarding_skip_button'),
                        onPressed: () {
                          ref.read(onboardingProvider.notifier).skip(_pageController);
                        },
                        child: Text(
                          AppStrings.onboardingSkip,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Onboarding pages sliding container
            Expanded(
              child: PageView.builder(
                key: const Key('onboarding_page_view'),
                controller: _pageController,
                onPageChanged: (index) {
                  ref.read(onboardingProvider.notifier).setPage(index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(model: _pages[index]);
                },
              ),
            ),

            // Animated bottom controllers
            OnboardingBottomControls(
              pageController: _pageController,
              currentPageIndex: currentPageIndex,
              pageCount: _pages.length,
              onNextPressed: () {
                ref
                    .read(onboardingProvider.notifier)
                    .nextPage(_pageController, context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
