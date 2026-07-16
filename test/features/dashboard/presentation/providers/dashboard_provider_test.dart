import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';
import 'package:fitness_tracker/features/activity/domain/repositories/activity_repository.dart';
import 'package:fitness_tracker/features/profile/domain/repositories/profile_repository.dart';
import 'package:fitness_tracker/features/dashboard/presentation/providers/dashboard_provider.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

class _FakeActivityRepository implements ActivityRepository {
  final List<ActivitiesTableData> _items;
  _FakeActivityRepository(this._items);

  @override
  Future<List<ActivitiesTableData>> getActivitiesByDateRange(
          DateTime s, DateTime e) async =>
      _items;

  @override
  Future<int> insertActivity(ActivitiesTableCompanion e) async => 1;
  @override
  Future<List<ActivitiesTableData>> getAllActivities() async => _items;
  @override
  Future<void> updateActivity(ActivitiesTableCompanion e) async {}
  @override
  Future<void> deleteActivity(int id) async {}
}

class _FakeProfileRepository implements ProfileRepository {
  final UserProfileTableData? _profile;
  _FakeProfileRepository(this._profile);

  @override
  Future<UserProfileTableData?> getProfile() async => _profile;
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

ProviderContainer _makeContainer({
  List<ActivitiesTableData> activities = const [],
  UserProfileTableData? profile,
}) {
  return ProviderContainer(
    overrides: [
      activityRepositoryProvider
          .overrideWithValue(_FakeActivityRepository(activities)),
      profileRepositoryProvider
          .overrideWithValue(_FakeProfileRepository(profile)),
    ],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('DashboardStats model', () {
    test('goalProgress clamps to 0.0 when steps == 0', () {
      const s = DashboardStats();
      expect(s.goalProgress, equals(0.0));
    });

    test('goalProgress clamps to 1.0 when steps exceed goal', () {
      const s = DashboardStats(totalSteps: 15000, dailyStepGoal: 10000);
      expect(s.goalProgress, equals(1.0));
    });

    test('isGoalComplete is true when steps >= goal', () {
      const s = DashboardStats(totalSteps: 10000, dailyStepGoal: 10000);
      expect(s.isGoalComplete, isTrue);
    });

    test('remainingSteps returns 0 when goal exceeded', () {
      const s = DashboardStats(totalSteps: 12000, dailyStepGoal: 10000);
      expect(s.remainingSteps, equals(0));
    });

    test('remainingSteps returns correct difference', () {
      const s = DashboardStats(totalSteps: 3000, dailyStepGoal: 10000);
      expect(s.remainingSteps, equals(7000));
    });

    test('copyWith preserves unspecified fields', () {
      const original = DashboardStats(totalSteps: 1000, totalCalories: 200);
      final copy = original.copyWith(totalSteps: 2000);
      expect(copy.totalSteps, equals(2000));
      expect(copy.totalCalories, equals(200));
    });
  });

  group('dashboardStatsProvider', () {
    test('returns zero stats when no activities exist', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(dashboardStatsProvider.future);

      expect(result.totalSteps, equals(0));
      expect(result.totalCalories, equals(0));
      expect(result.totalDistanceKm, equals(0.0));
      expect(result.totalActiveMinutes, equals(0));
      expect(result.activities, isEmpty);
    });

    test('aggregates steps, calories, and minutes from multiple activities',
        () async {
      final container = _makeContainer(
        activities: [
          _activity(id: 1, steps: 3000, calories: 200, duration: 20),
          _activity(id: 2, steps: 5000, calories: 350, duration: 40),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(dashboardStatsProvider.future);

      expect(result.totalSteps, equals(8000));
      expect(result.totalCalories, equals(550));
      expect(result.totalActiveMinutes, equals(60));
    });

    test('uses profile dailyStepGoal when profile is present', () async {
      final now = DateTime.now();
      final profile = UserProfileTableData(
        id: 1,
        name: 'Alice',
        height: 165,
        weight: 60,
        goal: null,
        dailyStepGoal: 8000,
        createdAt: now,
        updatedAt: now,
      );
      final container = _makeContainer(profile: profile);
      addTearDown(container.dispose);

      final result = await container.read(dashboardStatsProvider.future);

      expect(result.dailyStepGoal, equals(8000));
    });

    test('falls back to 10 000 step goal when no profile exists', () async {
      final container = _makeContainer();
      addTearDown(container.dispose);

      final result = await container.read(dashboardStatsProvider.future);

      expect(result.dailyStepGoal, equals(10000));
    });

    test('distance is computed correctly from steps', () async {
      final container = _makeContainer(
        activities: [_activity(steps: 10000)],
      );
      addTearDown(container.dispose);

      final result = await container.read(dashboardStatsProvider.future);

      // 10000 * 0.000762 = 7.62 km
      expect(result.totalDistanceKm, equals(7.62));
    });
  });
}
