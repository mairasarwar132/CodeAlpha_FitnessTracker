import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker/features/onboarding/presentation/providers/onboarding_provider.dart';

void main() {
  group('OnboardingNotifier Provider Tests', () {
    late ProviderContainer container;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is page 0', () {
      final index = container.read(onboardingProvider);
      expect(index, equals(0));
    });

    test('setPage updates page index correctly', () {
      container.read(onboardingProvider.notifier).setPage(2);
      expect(container.read(onboardingProvider), equals(2));
    });

    test('skip sets active page directly to index 3', () async {
      final controller = PageController();
      addTearDown(controller.dispose);

      await container.read(onboardingProvider.notifier).skip(controller);

      expect(container.read(onboardingProvider), equals(3));
    });

    test('nextPage advances the page state by 1', () async {
      final controller = PageController();
      addTearDown(controller.dispose);

      final notifier = container.read(onboardingProvider.notifier);

      expect(container.read(onboardingProvider), equals(0));
      
      // Navigate to page 1. Passing null for BuildContext for provider unit test.
      // We skip actual pagecontroller animation execution check or mock it.
      await notifier.nextPage(controller, FakeBuildContext());
      expect(container.read(onboardingProvider), equals(1));
    });
  });
}

class FakeBuildContext extends Fake implements BuildContext {
  @override
  bool get mounted => false;
}
