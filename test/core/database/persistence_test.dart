import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:fitness_tracker/core/database/app_database.dart';

void main() {
  late File tempDbFile;

  setUp(() {
    // Create a temporary file path in the system temp directory for testing
    final tempDir = Directory.systemTemp.createTempSync('fitness_tracker_test');
    tempDbFile = File('${tempDir.path}/test_persist.sqlite');
  });

  tearDown(() {
    if (tempDbFile.existsSync()) {
      try {
        tempDbFile.deleteSync();
      } catch (_) {}
    }
  });

  test('Verify SQLite file creation and data persistence after database recreate', () async {
    // 1. Check file does not exist initially
    expect(tempDbFile.existsSync(), isFalse);

    // 2. Initialize database pointing to the physical file
    var db = AppDatabase(NativeDatabase(tempDbFile));

    // This triggers schema creation / table creation in sqlite
    await db.saveProfile(UserProfileTableCompanion.insert(
      name: 'Adil Persist',
      height: 180.0,
      weight: 75.0,
      createdAt: Value(DateTime.now()),
      updatedAt: Value(DateTime.now()),
    ));

    // 3. Verify that the physical file is created on the filesystem
    expect(tempDbFile.existsSync(), isTrue);
    expect(tempDbFile.lengthSync(), isPositive);

    // Close the database instance
    await db.close();

    // 4. Initialize a second, separate database instance pointing to the exact same file
    var reopenedDb = AppDatabase(NativeDatabase(tempDbFile));

    // 5. Verify the data persisted and can be queried from the reopened database
    final profile = await reopenedDb.getProfile();
    expect(profile, isNotNull);
    expect(profile!.name, equals('Adil Persist'));
    expect(profile.height, equals(180.0));
    expect(profile.weight, equals(75.0));

    // Close the reopened database instance
    await reopenedDb.close();
  });
}
