import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/features/splash/presentation/pages/splash_screen.dart';
import 'package:fitness_tracker/features/splash/presentation/providers/splash_provider.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a minimal [GoRouter] with splash, onboarding and dashboard routes.
GoRouter _buildRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) =>
            const Scaffold(body: Text('Onboarding Screen')),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) =>
            const Scaffold(body: Text('Dashboard Screen')),
      ),
    ],
  );
}

void main() {
  group('SplashScreen – UI rendering', () {
    testWidgets('renders all splash screen UI components', (tester) async {
      // Override splashInitializationProvider with a future that never
      // completes so the screen stays visible for the duration of the test.
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            splashInitializationProvider
                .overrideWith((ref) => Completer<String>().future),
          ],
          child: const MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );

      expect(find.byKey(const Key('splash_logo_icon')), findsOneWidget);
      expect(find.byIcon(Icons.fitness_center), findsOneWidget);
      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.splashSubtitle), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // -------------------------------------------------------------------------
  // Navigation tests – mock splashInitializationProvider directly so we test
  // routing behaviour without touching SharedPreferences or the DB.
  // -------------------------------------------------------------------------

  group('SplashScreen – navigation (first launch = true → onboarding)', () {
    testWidgets('navigates to onboarding on first launch', (tester) async {
      final router = _buildRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Simulate first-launch path: provider resolves with onboarding.
            splashInitializationProvider.overrideWith(
              (ref) async {
                await Future<void>.delayed(const Duration(seconds: 3));
                return AppRoutes.onboarding;
              },
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Onboarding Screen'), findsNothing);

      // Advance past the 3-second delay.
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding Screen'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });

  group('SplashScreen – navigation (first launch = false → dashboard)', () {
    testWidgets('navigates to dashboard on return launch', (tester) async {
      final router = _buildRouter();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // Simulate return-launch path: provider resolves with dashboard.
            splashInitializationProvider.overrideWith(
              (ref) async {
                await Future<void>.delayed(const Duration(seconds: 3));
                return AppRoutes.dashboard;
              },
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Dashboard Screen'), findsNothing);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Screen'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });
  });
}
