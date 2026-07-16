import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/activities_table.dart';
import 'tables/user_profile_table.dart';

part 'app_database.g.dart';

/// Central Drift database for FitTrack Pro.
///
/// Includes all tables and handles lazy initialisation so the database
/// is opened only on first access.
@DriftDatabase(tables: [ActivitiesTable, UserProfileTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // ---------------------------------------------------------------------------
  // Activities DAO-style helpers (kept here so the DB is self-contained)
  // ---------------------------------------------------------------------------

  /// Insert a new activity and return its generated id.
  Future<int> insertActivity(ActivitiesTableCompanion entry) =>
      into(activitiesTable).insert(entry);

  /// Return every activity, newest first.
  Future<List<ActivitiesTableData>> getAllActivities() =>
      (select(activitiesTable)
            ..orderBy(
              [(t) => OrderingTerm.desc(t.activityDateTime)],
            ))
          .get();

  /// Return activities whose [activityDateTime] falls within [start]..[end].
  Future<List<ActivitiesTableData>> getActivitiesByDateRange(
    DateTime start,
    DateTime end,
  ) =>
      (select(activitiesTable)
            ..where((t) => t.activityDateTime.isBetweenValues(start, end))
            ..orderBy(
              [(t) => OrderingTerm.desc(t.activityDateTime)],
            ))
          .get();

  /// Replace an existing activity row.
  Future<bool> updateActivity(ActivitiesTableCompanion entry) =>
      update(activitiesTable).replace(entry);

  /// Delete the activity with [id].
  Future<int> deleteActivity(int id) =>
      (delete(activitiesTable)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // User Profile helpers
  // ---------------------------------------------------------------------------

  /// Persist (insert or replace) the single user profile row.
  Future<int> saveProfile(UserProfileTableCompanion entry) =>
      into(userProfileTable).insertOnConflictUpdate(entry);

  /// Return the first (and only) profile row, or null if none exists.
  Future<UserProfileTableData?> getProfile() =>
      (select(userProfileTable)..limit(1)).getSingleOrNull();

  /// Update the profile row.
  Future<bool> updateProfile(UserProfileTableCompanion entry) =>
      update(userProfileTable).replace(entry);

  /// Delete the profile row.
  Future<int> deleteProfile() => delete(userProfileTable).go();
}

/// Opens a [LazyDatabase] stored in the application documents directory.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbDir.path, 'fittrack.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
