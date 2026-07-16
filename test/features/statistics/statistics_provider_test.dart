import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/core/providers/database_provider.dart';
import 'package:fitness_tracker/features/statistics/domain/models/statistics_models.dart';
import 'package:fitness_tracker/features/statistics/presentation/providers/statistics_providers.dart';

void main() {
  test('selected filter provider defaults to today', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(selectedFilterProvider), StatisticsFilter.today);
  });

  test('statistics provider exposes summary data', () async {
    final database = AppDatabase(NativeDatabase.memory());
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

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

    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final summary = await container.read(
      statisticsProvider(StatisticsFilter.today).future,
    );
    expect(summary.totalSteps, equals(10000));
    expect(summary.totalActivities, equals(1));
  });
}
