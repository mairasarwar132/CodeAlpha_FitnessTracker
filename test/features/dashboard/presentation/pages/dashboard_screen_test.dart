import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';
import 'package:fitness_tracker/features/activity/domain/repositories/activity_repository.dart';
import 'package:fitness_tracker/features/profile/domain/repositories/profile_repository.dart';
import 'package:fitness_tracker/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:fitness_tracker/features/dashboard/presentation/widgets/activity_list_tile.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeActivityRepository implements ActivityRepository {
  final List<ActivitiesTableData> items;
  _FakeActivityRepository(this.items);

  @override
  Future<List<ActivitiesTableData>> getActivitiesByDateRange(
    DateTime s,
    DateTime e,
  ) async => items;

  @override
  Future<int> insertActivity(ActivitiesTableCompanion e) async => 1;
  @override
  Future<List<ActivitiesTableData>> getAllActivities() async => items;
  @override
  Future<void> updateActivity(ActivitiesTableCompanion e) async {}
  @override
  Future<void> deleteActivity(int id) async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserProfileTableData?> getProfile() async => null;
  @override
  Future<void> saveProfile(UserProfileTableCompanion e) async {}
  @override
  Future<void> updateProfile(UserProfileTableCompanion e) async {}
  @override
  Future<void> deleteProfile() async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ActivitiesTableData _activity({
  int id = 1,
  String type = 'running',
  int duration = 30,
  int calories = 300,
  int steps = 3000,
}) {
  final now = DateTime.now();
  return ActivitiesTableData(
    id: id,
    activityType: type,
    duration: duration,
    calories: calories,
    steps: steps,
    notes: null,
    activityDateTime: now,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _buildScreen({List<ActivitiesTableData> activities = const []}) {
  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, _) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, _) => const Scaffold(body: Text('History Screen')),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, _) => const Scaffold(body: Text('Profile Screen')),
      ),
      GoRoute(
        path: AppRoutes.addActivity,
        builder: (context, _) =>
            const Scaffold(body: Text('Add Activity Screen')),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      activityRepositoryProvider.overrideWithValue(
        _FakeActivityRepository(activities),
      ),
      profileRepositoryProvider.overrideWithValue(_FakeProfileRepository()),
    ],
    child: MediaQuery(
      data: const MediaQueryData(size: Size(800, 2400)),
      child: MaterialApp.router(routerConfig: router),
    ),
  );
}

Finder _dashboardKey(String value) =>
    find.byKey(Key(value), skipOffstage: false);

Future<void> _pumpDashboardScreen(
  WidgetTester tester, {
  List<ActivitiesTableData> activities = const [],
  bool scrollDown = false,
}) async {
  await tester.pumpWidget(_buildScreen(activities: activities));
  // First pump to let the provider load
  await tester.pumpAndSettle();
  // Second pump to let the data state actually render
  await tester.pump();
  // Optionally scroll to see content below the fold
  if (scrollDown) {
    await tester.drag(
      find.byKey(const Key('dashboard_scroll_view')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DashboardScreen Widget Tests', () {
    testWidgets('shows loading indicator while fetching data', (tester) async {
      // We'll just pump once (no settle) to catch the async loading state.
      await tester.pumpWidget(_buildScreen());
      // First frame is the loading state before the future resolves
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders stat cards after data loads', (tester) async {
      await _pumpDashboardScreen(tester);

      expect(find.byKey(const Key('stat_steps')), findsOneWidget);
      expect(find.byKey(const Key('stat_calories')), findsOneWidget);
      expect(find.byKey(const Key('stat_distance')), findsOneWidget);
      expect(find.byKey(const Key('stat_active_min')), findsOneWidget);
    });

    testWidgets('renders goal progress card', (tester) async {
      await _pumpDashboardScreen(tester, scrollDown: true);

      expect(_dashboardKey('goal_progress_card'), findsOneWidget);
      expect(find.text(AppStrings.dashboardDailyGoal), findsOneWidget);
    });

    testWidgets('shows empty activities state when no activities logged', (
      tester,
    ) async {
      await _pumpDashboardScreen(tester, activities: [], scrollDown: true);

      expect(_dashboardKey('empty_activities_state'), findsOneWidget);
      expect(find.text(AppStrings.dashboardNoActivities), findsOneWidget);
    });

    testWidgets('shows activities list when activities exist', (tester) async {
      await _pumpDashboardScreen(
        tester,
        activities: [
          _activity(id: 1, type: 'Running', steps: 3000),
          _activity(id: 2, type: 'Cycling', steps: 2000),
        ],
        scrollDown: true,
      );

      expect(_dashboardKey('activities_list'), findsOneWidget);
      expect(find.byType(ActivityListTile), findsNWidgets(2));
    });

    testWidgets('renders quick action buttons', (tester) async {
      await _pumpDashboardScreen(tester, scrollDown: true);

      expect(_dashboardKey('btn_add_activity'), findsOneWidget);
      expect(_dashboardKey('btn_view_history'), findsOneWidget);
      expect(_dashboardKey('btn_edit_profile'), findsOneWidget);
    });

    testWidgets('tapping history button navigates to history screen', (
      tester,
    ) async {
      await _pumpDashboardScreen(tester, scrollDown: true);

      await tester.tap(_dashboardKey('btn_view_history'));
      await tester.pumpAndSettle();

      expect(find.text('History Screen'), findsOneWidget);
    });

    testWidgets('tapping profile button navigates to profile screen', (
      tester,
    ) async {
      await _pumpDashboardScreen(tester, scrollDown: true);

      await tester.tap(_dashboardKey('btn_edit_profile'));
      await tester.pumpAndSettle();

      expect(find.text('Profile Screen'), findsOneWidget);
    });

    testWidgets(
      'step count and calories are displayed in stats after loading',
      (tester) async {
        await _pumpDashboardScreen(
          tester,
          activities: [_activity(steps: 5000, calories: 400)],
        );

        // Steps formatted as "5k"
        expect(find.text('5k'), findsWidgets);
        // Calories as "400"
        expect(find.text('400'), findsWidgets);
      },
    );
  });
}
