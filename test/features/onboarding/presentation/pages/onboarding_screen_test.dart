import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/core/providers/preferences_provider.dart';
import 'package:fitness_tracker/core/services/app_preferences.dart';
import 'package:fitness_tracker/features/onboarding/presentation/pages/onboarding_screen.dart';

void main() {
  group('OnboardingScreen Widget and Flow Tests', () {
    late GoRouter testRouter;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      
      // Build isolated router configuration pointing Onboarding and Dashboard paths
      testRouter = GoRouter(
        initialLocation: AppRoutes.onboarding,
        routes: [
          GoRoute(
            path: AppRoutes.onboarding,
            builder: (context, state) => const OnboardingScreen(),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const Scaffold(body: Text('Dashboard Screen')),
          ),
        ],
      );
    });

    testWidgets('renders first onboarding screen with indicator and skip controls',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardingScreen(),
          ),
        ),
      );

      // Verify page titles and descriptions
      expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);
      expect(find.text(AppStrings.onboardingSubtitle1), findsOneWidget);

      // Verify SmoothPageIndicator package widget renders
      expect(find.byType(SmoothPageIndicator), findsOneWidget);

      // Verify control buttons
      expect(find.byKey(const Key('onboarding_skip_button')), findsOneWidget);
      expect(find.byKey(const Key('onboarding_next_button')), findsOneWidget);
      expect(find.byKey(const Key('onboarding_get_started_button')), findsNothing);
    });

    testWidgets('next button steps through pages to final page and navigates on Get Started',
        (WidgetTester tester) async {
      final prefsFuture = AppPreferences.create();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appPreferencesProvider.overrideWith((ref) => prefsFuture),
          ],
          child: MaterialApp.router(
            routerConfig: testRouter,
          ),
        ),
      );

      // Navigate to final page by pressing Next button repeatedly
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('onboarding_next_button')));
        await tester.pumpAndSettle();
      }

      // Check last page content
      expect(find.text(AppStrings.onboardingTitle4), findsOneWidget);
      expect(find.text(AppStrings.onboardingSubtitle4), findsOneWidget);

      // "Next" is hidden; "Get Started" is visible
      expect(find.byKey(const Key('onboarding_next_button')), findsNothing);
      expect(find.byKey(const Key('onboarding_get_started_button')), findsOneWidget);

      // Tap Get Started to complete
      await tester.tap(find.byKey(const Key('onboarding_get_started_button')));
      await tester.pumpAndSettle();

      // Verify routing redirected dashboard
      expect(find.text('Dashboard Screen'), findsOneWidget);

      // Verify SharedPreferences persisted completion flag
      final prefs = await prefsFuture;
      expect(await prefs.isFirstLaunch(), isFalse);
    });

    testWidgets('skip button navigates straight to last screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: testRouter,
          ),
        ),
      );

      // Initial page 1
      expect(find.text(AppStrings.onboardingTitle1), findsOneWidget);

      // Tap skip
      await tester.tap(find.byKey(const Key('onboarding_skip_button')));
      await tester.pumpAndSettle();

      // Verify on page 4
      expect(find.text(AppStrings.onboardingTitle4), findsOneWidget);
      expect(find.byKey(const Key('onboarding_get_started_button')), findsOneWidget);
    });

    testWidgets('accessibility semantics tags exist on controllers',
        (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardingScreen(),
          ),
        ),
      );

      // Verify semantics details on controls
      expect(
        tester.getSemantics(find.byKey(const Key('onboarding_next_button'))),
        matchesSemantics(
          label: 'Next page.',
          isButton: true,
          hasTapAction: true,
        ),
      );

      expect(
        tester.getSemantics(find.byKey(const Key('onboarding_skip_button'))),
        matchesSemantics(
          label: 'Skip onboarding flow directly to the final screen.',
          isButton: true,
          hasTapAction: true,
        ),
      );

      handle.dispose();
    });

    testWidgets('responsive layout builds safely on small viewports without overflow warnings',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 480); // very small screen
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const OnboardingScreen(),
          ),
        ),
      );

      // Verifying rendering completes successfully
      expect(find.byType(OnboardingScreen), findsOneWidget);
    });
  });
}
