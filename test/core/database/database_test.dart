import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:fitness_tracker/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    // Open in-memory native SQLite database for integration/unit testing
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Initialization & Schema', () {
    test('Database initializes successfully with version 1', () {
      expect(database.schemaVersion, equals(1));
    });

    test('Tables are generated and exist in schema', () {
      final tables = database.allSchemaEntities;
      final tableNames = tables.map((e) => e.entityName).toList();
      expect(tableNames, containsAll(['activities_table', 'user_profile_table']));
    });
  });

  group('Activities CRUD', () {
    final testActivity = ActivitiesTableCompanion.insert(
      activityType: 'Running',
      duration: 30,
      calories: 300,
      steps: const Value(5000),
      notes: const Value('Evening run'),
      activityDateTime: DateTime(2026, 6, 25, 18, 0),
      createdAt: DateTime(2026, 6, 25, 19, 0),
      updatedAt: DateTime(2026, 6, 25, 19, 0),
    );

    test('Insert and get all activities', () async {
      // Empty check
      var list = await database.getAllActivities();
      expect(list, isEmpty);

      // Insert
      final id = await database.insertActivity(testActivity);
      expect(id, isPositive);

      // Get
      list = await database.getAllActivities();
      expect(list, hasLength(1));
      expect(list.first.id, id);
      expect(list.first.activityType, 'Running');
      expect(list.first.duration, 30);
      expect(list.first.calories, 300);
      expect(list.first.steps, 5000);
      expect(list.first.notes, 'Evening run');
      expect(list.first.activityDateTime, DateTime(2026, 6, 25, 18, 0));
    });

    test('Update activity', () async {
      final id = await database.insertActivity(testActivity);

      final updated = ActivitiesTableCompanion(
        id: Value(id),
        activityType: const Value('Cycling'),
        duration: const Value(45),
        calories: const Value(400),
        steps: const Value(0),
        notes: const Value('Scenic route'),
        activityDateTime: Value(DateTime(2026, 6, 25, 18, 0)),
        createdAt: Value(DateTime(2026, 6, 25, 19, 0)),
        updatedAt: Value(DateTime(2026, 6, 25, 19, 30)),
      );

      final success = await database.updateActivity(updated);
      expect(success, isTrue);

      final list = await database.getAllActivities();
      expect(list.first.activityType, 'Cycling');
      expect(list.first.duration, 45);
      expect(list.first.calories, 400);
      expect(list.first.steps, 0);
      expect(list.first.notes, 'Scenic route');
    });

    test('Delete activity', () async {
      final id = await database.insertActivity(testActivity);
      
      var list = await database.getAllActivities();
      expect(list, hasLength(1));

      final deletedRows = await database.deleteActivity(id);
      expect(deletedRows, equals(1));

      list = await database.getAllActivities();
      expect(list, isEmpty);
    });

    test('Get activities by date range', () async {
      await database.insertActivity(ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: 30,
        calories: 300,
        activityDateTime: DateTime(2026, 6, 20),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await database.insertActivity(ActivitiesTableCompanion.insert(
        activityType: 'Walking',
        duration: 20,
        calories: 100,
        activityDateTime: DateTime(2026, 6, 22),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await database.insertActivity(ActivitiesTableCompanion.insert(
        activityType: 'Swimming',
        duration: 40,
        calories: 400,
        activityDateTime: DateTime(2026, 6, 25),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // Query range: 2026-06-21 to 2026-06-23
      final result = await database.getActivitiesByDateRange(
        DateTime(2026, 6, 21),
        DateTime(2026, 6, 23),
      );
      expect(result, hasLength(1));
      expect(result.first.activityType, 'Walking');
    });
  });

  group('User Profile CRUD & Edge Cases', () {
    final testProfile = UserProfileTableCompanion.insert(
      name: 'Adil',
      height: 180.0,
      weight: 75.0,
      goal: const Value('Stay Fit'),
      dailyStepGoal: const Value(12000),
      createdAt: Value(DateTime(2026, 6, 25)),
      updatedAt: Value(DateTime(2026, 6, 25)),
    );

    test('Save, get, update, and delete profile', () async {
      // Empty check
      var profile = await database.getProfile();
      expect(profile, isNull);

      // Save
      await database.saveProfile(testProfile);
      profile = await database.getProfile();
      expect(profile, isNotNull);
      expect(profile!.name, 'Adil');
      expect(profile.height, 180.0);
      expect(profile.weight, 75.0);
      expect(profile.goal, 'Stay Fit');
      expect(profile.dailyStepGoal, 12000);

      // Update
      final updated = UserProfileTableCompanion(
        id: Value(profile.id),
        name: const Value('Adil M'),
        height: const Value(180.0),
        weight: const Value(76.0),
        goal: const Value('Build Muscle'),
        dailyStepGoal: const Value(15000),
        createdAt: Value(profile.createdAt),
        updatedAt: Value(DateTime.now()),
      );
      await database.updateProfile(updated);
      
      profile = await database.getProfile();
      expect(profile!.name, 'Adil M');
      expect(profile.weight, 76.0);
      expect(profile.goal, 'Build Muscle');
      expect(profile.dailyStepGoal, 15000);

      // Delete
      final deletedCount = await database.deleteProfile();
      expect(deletedCount, equals(1));

      profile = await database.getProfile();
      expect(profile, isNull);
    });

    test('Duplicate saveProfile overwrites/updates user profile', () async {
      await database.saveProfile(testProfile);
      
      // Save duplicate with new height/weight
      final duplicate = UserProfileTableCompanion.insert(
        id: const Value(1), // Explicit ID conflict
        name: 'Adil Refined',
        height: 181.0,
        weight: 77.0,
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      );
      await database.saveProfile(duplicate);

      final profile = await database.getProfile();
      expect(profile, isNotNull);
      expect(profile!.name, 'Adil Refined');
      expect(profile.height, 181.0);
      expect(profile.weight, 77.0);
    });
  });

  group('Edge Cases', () {
    test('Empty database queries return gracefully', () async {
      final list = await database.getAllActivities();
      expect(list, isEmpty);

      final profile = await database.getProfile();
      expect(profile, isNull);
    });

    test('Invalid date range (start > end) returns empty activities', () async {
      await database.insertActivity(ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: 30,
        calories: 300,
        activityDateTime: DateTime(2026, 6, 22),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final result = await database.getActivitiesByDateRange(
        DateTime(2026, 6, 25), // start
        DateTime(2026, 6, 20), // end (before start)
      );
      expect(result, isEmpty);
    });

    test('Nullable fields (notes, goals) serialize as null', () async {
      await database.insertActivity(ActivitiesTableCompanion.insert(
        activityType: 'Running',
        duration: 30,
        calories: 300,
        notes: const Value(null),
        activityDateTime: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      final list = await database.getAllActivities();
      expect(list.first.notes, isNull);

      await database.saveProfile(UserProfileTableCompanion.insert(
        name: 'John',
        height: 175.0,
        weight: 70.0,
        goal: const Value(null),
        createdAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ));

      final profile = await database.getProfile();
      expect(profile!.goal, isNull);
    });
  });
}
