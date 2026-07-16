import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/features/activity/data/repositories/activity_repository_impl.dart';

void main() {
  late AppDatabase database;
  late ActivityRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ActivityRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('ActivityRepository validation logic', () {
    test('Valid activity companion passes validation and inserts successfully', () async {
      final valid = ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: 30,
        calories: 300,
        steps: const Value(4000),
        activityDateTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final id = await repository.insertActivity(valid);
      expect(id, isPositive);
    });

    test('Negative duration throws ArgumentError', () async {
      final invalid = ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: -5,
        calories: 300,
        activityDateTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => repository.insertActivity(invalid), throwsArgumentError);
    });

    test('Negative calories throws ArgumentError', () async {
      final invalid = ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: 30,
        calories: -300,
        activityDateTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => repository.insertActivity(invalid), throwsArgumentError);
    });

    test('Negative steps throws ArgumentError', () async {
      final invalid = ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: 30,
        calories: 300,
        steps: const Value(-100),
        activityDateTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(() => repository.insertActivity(invalid), throwsArgumentError);
    });
  });

  group('ActivityRepository delegation checks', () {
    test('CRUD operations delegate to DB correctly', () async {
      final item = ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: 20,
        calories: 200,
        activityDateTime: DateTime(2026, 6, 25),
        createdAt: DateTime(2026, 6, 25),
        updatedAt: DateTime(2026, 6, 25),
      );

      // Insert
      final id = await repository.insertActivity(item);
      expect(id, isPositive);

      // Get All
      var list = await repository.getAllActivities();
      expect(list, hasLength(1));
      expect(list.first.activityType, 'Running');

      // Update
      final updated = ActivitiesTableCompanion(
        id: Value(id),
        activityType: const Value('Cycling'),
        duration: const Value(30),
        calories: const Value(300),
        activityDateTime: Value(DateTime(2026, 6, 25)),
        createdAt: Value(DateTime(2026, 6, 25)),
        updatedAt: Value(DateTime.now()),
      );
      await repository.updateActivity(updated);

      list = await repository.getAllActivities();
      expect(list.first.activityType, 'Cycling');
      expect(list.first.duration, 30);

      // Get by date range
      final rangeResults = await repository.getActivitiesByDateRange(
        DateTime(2026, 6, 24),
        DateTime(2026, 6, 26),
      );
      expect(rangeResults, hasLength(1));

      // Delete
      await repository.deleteActivity(id);
      list = await repository.getAllActivities();
      expect(list, isEmpty);
    });
  });
}
