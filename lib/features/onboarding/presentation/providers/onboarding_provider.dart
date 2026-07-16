import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/core/providers/preferences_provider.dart';

/// State notifier that manages the active onboarding page index and handles
/// transition logic, persistence via [AppPreferences], and routing to the dashboard.
class OnboardingNotifier extends AutoDisposeNotifier<int> {
  @override
  int build() {
    return 0;
  }

  /// Manually update the current page index.
  void setPage(int index) {
    state = index;
  }

  /// Animates to the next page. If currently on the final page, completes onboarding.
  Future<void> nextPage(PageController controller, BuildContext context) async {
    if (state < 3) {
      final targetPage = state + 1;
      state = targetPage;
      if (controller.hasClients) {
        await controller.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      await completeOnboarding(context);
    }
  }

  /// Animates directly to the final onboarding slide.
  Future<void> skip(PageController controller) async {
    if (state < 3) {
      state = 3;
      if (controller.hasClients) {
        await controller.animateToPage(
          3,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Marks onboarding as completed in SharedPreferences and navigates to the dashboard.
  Future<void> completeOnboarding(BuildContext context) async {
    try {
      // 1. Resolve AppPreferences
      final prefs = await ref.read(appPreferencesProvider.future);

      // 2. Persist completion flag
      await prefs.setFirstLaunchCompleted();
    } catch (_) {
      // Non-fatal fallback: navigate to dashboard even if saving completes with failure
    }

    // 3. Navigate to Dashboard using GoRouter (context-safe)
    if (context.mounted) {
      context.go(AppRoutes.dashboard);
    }
  }
}

/// Provider for the active page index state in Onboarding flow.
final onboardingProvider =
    AutoDisposeNotifierProvider<OnboardingNotifier, int>(
  OnboardingNotifier.new,
);
