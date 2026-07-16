import 'package:drift/drift.dart';

/// Drift table definition for the user's profile.
class UserProfileTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  RealColumn get height => real()();

  RealColumn get weight => real()();

  TextColumn get goal => text().nullable()();

  /// Daily step target, defaults to 10 000 steps.
  IntColumn get dailyStepGoal =>
      integer().withDefault(const Constant(10000))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
