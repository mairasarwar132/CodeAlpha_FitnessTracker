import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/features/profile/data/repositories/profile_repository_impl.dart';

void main() {
  late AppDatabase database;
  late ProfileRepositoryImpl repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ProfileRepositoryImpl(database: database);
  });

  tearDown(() async {
    await database.close();
  });

  group('ProfileRepository validation logic', () {
    test('Valid profile passes validation and saves successfully', () async {
      final valid = UserProfileTableCompanion.insert(
        name: 'Adil',
        height: 180.0,
        weight: 75.0,
        dailyStepGoal: const Value(10000),
      );

      await repository.saveProfile(valid);
      final profile = await repository.getProfile();
      expect(profile, isNotNull);
      expect(profile!.name, 'Adil');
    });

    test('Zero height throws ArgumentError', () async {
      final invalid = UserProfileTableCompanion.insert(
        name: 'Adil',
        height: 0.0,
        weight: 75.0,
      );

      expect(() => repository.saveProfile(invalid), throwsArgumentError);
    });

    test('Negative height throws ArgumentError', () async {
      final invalid = UserProfileTableCompanion.insert(
        name: 'Adil',
        height: -10.0,
        weight: 75.0,
      );

      expect(() => repository.saveProfile(invalid), throwsArgumentError);
    });

    test('Zero weight throws ArgumentError', () async {
      final invalid = UserProfileTableCompanion.insert(
        name: 'Adil',
        height: 180.0,
        weight: 0.0,
      );

      expect(() => repository.saveProfile(invalid), throwsArgumentError);
    });

    test('Negative weight throws ArgumentError', () async {
      final invalid = UserProfileTableCompanion.insert(
        name: 'Adil',
        height: 180.0,
        weight: -5.0,
      );

      expect(() => repository.saveProfile(invalid), throwsArgumentError);
    });

    test('Zero dailyStepGoal throws ArgumentError', () async {
      final invalid = UserProfileTableCompanion.insert(
        name: 'Adil',
        height: 180.0,
        weight: 75.0,
        dailyStepGoal: const Value(0),
      );

      expect(() => repository.saveProfile(invalid), throwsArgumentError);
    });

    test('Negative dailyStepGoal throws ArgumentError', () async {
      final invalid = UserProfileTableCompanion.insert(
        name: 'Adil',
        height: 180.0,
        weight: 75.0,
        dailyStepGoal: const Value(-100),
      );

      expect(() => repository.saveProfile(invalid), throwsArgumentError);
    });
  });

  group('ProfileRepository delegation checks', () {
    test('CRUD operations delegate to DB correctly', () async {
      final profile = UserProfileTableCompanion.insert(
        name: 'Adil',
        height: 180.0,
        weight: 75.0,
        dailyStepGoal: const Value(10000),
      );

      // Save
      await repository.saveProfile(profile);
      var fetched = await repository.getProfile();
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Adil');

      // Update
      final updated = UserProfileTableCompanion(
        id: Value(fetched.id),
        name: const Value('Adil M'),
        height: const Value(180.0),
        weight: const Value(76.0),
        dailyStepGoal: const Value(12000),
        createdAt: Value(fetched.createdAt),
        updatedAt: Value(DateTime.now()),
      );
      await repository.updateProfile(updated);

      fetched = await repository.getProfile();
      expect(fetched!.name, 'Adil M');
      expect(fetched.weight, 76.0);
      expect(fetched.dailyStepGoal, 12000);

      // Delete
      await repository.deleteProfile();
      fetched = await repository.getProfile();
      expect(fetched, isNull);
    });
  });
}
