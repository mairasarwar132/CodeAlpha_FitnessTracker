import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';

/// Aggregated stats computed from today's activities.
class DashboardStats {
  const DashboardStats({
    this.totalSteps = 0,
    this.totalCalories = 0,
    this.totalDistanceKm = 0.0,
    this.totalActiveMinutes = 0,
    this.activities = const [],
    this.dailyStepGoal = 10000,
  });

  final int totalSteps;
  final int totalCalories;
  final double totalDistanceKm;
  final int totalActiveMinutes;
  final List<ActivitiesTableData> activities;
  final int dailyStepGoal;

  double get goalProgress =>
      dailyStepGoal > 0 ? (totalSteps / dailyStepGoal).clamp(0.0, 1.0) : 0.0;

  int get remainingSteps =>
      (dailyStepGoal - totalSteps).clamp(0, dailyStepGoal);

  bool get isGoalComplete => totalSteps >= dailyStepGoal;

  DashboardStats copyWith({
    int? totalSteps,
    int? totalCalories,
    double? totalDistanceKm,
    int? totalActiveMinutes,
    List<ActivitiesTableData>? activities,
    int? dailyStepGoal,
  }) {
    return DashboardStats(
      totalSteps: totalSteps ?? this.totalSteps,
      totalCalories: totalCalories ?? this.totalCalories,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalActiveMinutes: totalActiveMinutes ?? this.totalActiveMinutes,
      activities: activities ?? this.activities,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
    );
  }
}

/// Async provider that loads today's activities + user profile and computes stats.
///
/// Uses [FutureProvider.autoDispose] so data refreshes each time the dashboard
/// is shown (guards against stale data after activity logging).
final dashboardStatsProvider =
    FutureProvider.autoDispose<DashboardStats>((ref) async {
  final activityRepo = ref.watch(activityRepositoryProvider);
  final profileRepo = ref.watch(profileRepositoryProvider);

  // Date range: midnight today → end of today
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

  final results = await Future.wait([
    activityRepo.getActivitiesByDateRange(startOfDay, endOfDay),
    profileRepo.getProfile(),
  ]);

  final activities = results[0] as List<ActivitiesTableData>;
  final profile = results[1] as UserProfileTableData?;

  final dailyStepGoal = profile?.dailyStepGoal ?? 10000;

  int totalSteps = 0;
  int totalCalories = 0;
  int totalActiveMinutes = 0;

  for (final a in activities) {
    totalSteps += a.steps;
    totalCalories += a.calories;
    totalActiveMinutes += a.duration;
  }

  // Distance: average stride ~0.762 m → km = steps * 0.000762
  final totalDistanceKm = totalSteps * 0.000762;

  return DashboardStats(
    totalSteps: totalSteps,
    totalCalories: totalCalories,
    totalDistanceKm: double.parse(totalDistanceKm.toStringAsFixed(2)),
    totalActiveMinutes: totalActiveMinutes,
    activities: activities,
    dailyStepGoal: dailyStepGoal,
  );
});
