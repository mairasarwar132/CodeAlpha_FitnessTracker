import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:fitness_tracker/features/statistics/domain/models/statistics_models.dart';
import 'package:fitness_tracker/features/statistics/domain/repositories/statistics_repository.dart';

void main() {
  late AppDatabase database;
  late StatisticsRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = StatisticsRepositoryImpl(database: database);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    await database.insertActivity(
      ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: 30,
        calories: 300,
        steps: const Value(10000),
        distance: const Value(8.0),
        activityDateTime: today,
        createdAt: today,
        updatedAt: today,
      ),
    );

    await database.insertActivity(
      ActivitiesTableCompanion.insert(
        activityType: 'Walking',
        duration: 45,
        calories: 220,
        steps: const Value(8000),
        distance: const Value(6.0),
        activityDateTime: yesterday,
        createdAt: yesterday,
        updatedAt: yesterday,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('calculates summary values for today range', () async {
    final summary = await repository.getStatisticsSummary(
      filter: StatisticsFilter.today,
      dailyStepGoal: 10000,
    );

    expect(summary.totalSteps, greaterThan(0));
    expect(summary.totalActivities, equals(1));
    expect(summary.goalCompletionPercent, equals(100.0));
    expect(
      summary.activityDistribution.mostFrequentActivity,
      equals('Running'),
    );
  });

  test('calculates streak values from consecutive active days', () async {
    final summary = await repository.getStatisticsSummary(
      filter: StatisticsFilter.last7Days,
      dailyStepGoal: 10000,
    );

    expect(summary.streak.currentStreak, greaterThanOrEqualTo(1));
    expect(summary.streak.longestStreak, greaterThanOrEqualTo(1));
  });
}
