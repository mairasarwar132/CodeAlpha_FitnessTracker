import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';
import 'package:fitness_tracker/core/database/app_database.dart';

/// Immutable activity domain model used by the presentation layer.
class ActivityModel extends Equatable {
  const ActivityModel({
    required this.id,
    required this.activityType,
    required this.duration,
    required this.calories,
    required this.steps,
    required this.distance,
    required this.notes,
    required this.activityDateTime,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String activityType;
  final int duration;
  final int calories;
  final int steps;
  final double distance;
  final String? notes;
  final DateTime activityDateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ActivityModel.fromTable(ActivitiesTableData data) {
    return ActivityModel(
      id: data.id,
      activityType: data.activityType,
      duration: data.duration,
      calories: data.calories,
      steps: data.steps,
      distance: data.distance,
      notes: data.notes,
      activityDateTime: data.activityDateTime,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
    );
  }

  ActivitiesTableCompanion toCompanion({bool isNew = false}) {
    return ActivitiesTableCompanion(
      id: isNew ? const Value.absent() : Value(id),
      activityType: Value(activityType),
      duration: Value(duration),
      calories: Value(calories),
      steps: Value(steps),
      distance: Value(distance),
      notes: notes == null ? const Value.absent() : Value(notes),
      activityDateTime: Value(activityDateTime),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  @override
  List<Object?> get props => [
    id,
    activityType,
    duration,
    calories,
    steps,
    distance,
    notes,
    activityDateTime,
    createdAt,
    updatedAt,
  ];
}
