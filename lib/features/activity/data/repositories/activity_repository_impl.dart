import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/features/activity/domain/repositories/activity_repository.dart';

/// Concrete implementation of [ActivityRepository].
///
/// Delegates all persistence operations to [AppDatabase].
/// Contains no business logic – only data-access concerns.
class ActivityRepositoryImpl implements ActivityRepository {
  const ActivityRepositoryImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  /// Throws [ArgumentError] if any numeric field violates the basic rules:
  ///   duration >= 0, calories >= 0, steps >= 0.
  void _validateActivity(ActivitiesTableCompanion entry) {
    if (entry.duration.present && entry.duration.value < 0) {
      throw ArgumentError.value(
        entry.duration.value,
        'duration',
        'duration must be >= 0',
      );
    }
    if (entry.calories.present && entry.calories.value < 0) {
      throw ArgumentError.value(
        entry.calories.value,
        'calories',
        'calories must be >= 0',
      );
    }
    if (entry.steps.present && entry.steps.value < 0) {
      throw ArgumentError.value(
        entry.steps.value,
        'steps',
        'steps must be >= 0',
      );
    }
    if (entry.distance.present && entry.distance.value < 0) {
      throw ArgumentError.value(
        entry.distance.value,
        'distance',
        'distance must be >= 0',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // ActivityRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Future<int> insertActivity(ActivitiesTableCompanion entry) {
    _validateActivity(entry);
    return _database.insertActivity(entry);
  }

  @override
  Future<List<ActivitiesTableData>> getAllActivities() =>
      _database.getAllActivities();

  @override
  Future<void> updateActivity(ActivitiesTableCompanion entry) async {
    _validateActivity(entry);
    await _database.updateActivity(entry);
  }

  @override
  Future<void> deleteActivity(int id) async {
    await _database.deleteActivity(id);
  }

  @override
  Future<List<ActivitiesTableData>> getActivitiesByDateRange(
    DateTime start,
    DateTime end,
  ) => _database.getActivitiesByDateRange(start, end);
}
