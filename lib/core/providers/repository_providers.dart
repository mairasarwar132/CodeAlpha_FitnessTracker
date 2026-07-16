import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/providers/database_provider.dart';
import 'package:fitness_tracker/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:fitness_tracker/features/activity/domain/repositories/activity_repository.dart';
import 'package:fitness_tracker/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fitness_tracker/features/profile/domain/repositories/profile_repository.dart';

/// Provides the concrete [ActivityRepository] backed by [AppDatabase].
///
/// Typed against the abstract [ActivityRepository] so consumers are
/// decoupled from the implementation detail.
final activityRepositoryProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepositoryImpl(
    database: ref.watch(databaseProvider),
  ),
);

/// Provides the concrete [ProfileRepository] backed by [AppDatabase].
///
/// Typed against the abstract [ProfileRepository] so consumers are
/// decoupled from the implementation detail.
final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(
    database: ref.watch(databaseProvider),
  ),
);
