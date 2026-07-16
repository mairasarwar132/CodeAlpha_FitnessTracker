import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';
import 'package:fitness_tracker/features/activity/domain/models/activity_model.dart';
import 'package:fitness_tracker/features/activity/domain/usecases/activity_validation.dart';

final activityListProvider = FutureProvider.autoDispose<List<ActivityModel>>((
  ref,
) async {
  final repository = ref.watch(activityRepositoryProvider);
  final items = await repository.getAllActivities();
  return items.map(ActivityModel.fromTable).toList();
});

final activityFilterProvider = StateProvider<String?>((ref) => null);
final activitySearchProvider = StateProvider<String>((ref) => '');
final activitySortProvider = StateProvider<String>((ref) => 'newest');

final activityDetailsProvider = Provider.family<ActivityModel?, int>((ref, id) {
  final asyncItems = ref.watch(activityListProvider);
  return asyncItems.whenOrNull(
    data: (items) => items.where((item) => item.id == id).firstOrNull,
  );
});

final createActivityProvider = FutureProvider.autoDispose
    .family<void, ActivityModel>((ref, activity) async {
      final repository = ref.watch(activityRepositoryProvider);
      await repository.insertActivity(activity.toCompanion(isNew: true));
      ref.invalidate(activityListProvider);
    });

final updateActivityProvider = FutureProvider.autoDispose
    .family<void, ActivityModel>((ref, activity) async {
      final repository = ref.watch(activityRepositoryProvider);
      await repository.updateActivity(activity.toCompanion());
      ref.invalidate(activityListProvider);
    });

final deleteActivityProvider = FutureProvider.autoDispose.family<void, int>((
  ref,
  id,
) async {
  final repository = ref.watch(activityRepositoryProvider);
  await repository.deleteActivity(id);
  ref.invalidate(activityListProvider);
});

final activityValidationProvider = Provider<ActivityValidation>(
  (ref) => ActivityValidation(),
);
