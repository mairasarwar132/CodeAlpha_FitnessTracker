import 'package:fitness_tracker/core/database/app_database.dart';

/// Contract for all activity-related data operations.
///
/// Implementations live in the data layer; use-cases depend only on this
/// abstract interface (Dependency Inversion).
abstract class ActivityRepository {
  /// Persist a new activity and return its generated row id.
  Future<int> insertActivity(ActivitiesTableCompanion entry);

  /// Retrieve every stored activity, newest first.
  Future<List<ActivitiesTableData>> getAllActivities();

  /// Replace an existing activity row.
  Future<void> updateActivity(ActivitiesTableCompanion entry);

  /// Permanently remove the activity identified by [id].
  Future<void> deleteActivity(int id);

  /// Return activities whose recorded [activityDateTime] falls between [start]
  /// and [end] (inclusive), newest first.
  Future<List<ActivitiesTableData>> getActivitiesByDateRange(
    DateTime start,
    DateTime end,
  );
}
