import 'package:drift/drift.dart';

/// Drift table definition for fitness activities.
///
/// Note: The column getter is named [activityDateTime] instead of [dateTime]
/// to avoid shadowing Drift's built-in [dateTime()] builder method,
/// which causes a drift_dev parser crash. The SQL column is named
/// 'activity_date_time' (snake_case of the getter name).
class ActivitiesTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get activityType => text()();

  /// Duration of the activity in minutes.
  IntColumn get duration => integer()();

  IntColumn get calories => integer()();

  IntColumn get steps => integer().withDefault(const Constant(0))();

  RealColumn get distance => real().withDefault(const Constant(0.0))();

  TextColumn get notes => text().nullable()();

  DateTimeColumn get activityDateTime => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}
