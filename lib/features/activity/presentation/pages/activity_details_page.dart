import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/features/activity/presentation/providers/activity_providers.dart';

class ActivityDetailsPage extends ConsumerWidget {
  const ActivityDetailsPage({super.key, required this.activityId});

  final int activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncActivities = ref.watch(activityListProvider);
    final activity = asyncActivities.whenOrNull(
      data: (items) => items.where((item) => item.id == activityId).firstOrNull,
    );

    if (asyncActivities.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (asyncActivities.hasError) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load activity: ${asyncActivities.error}'),
        ),
      );
    }

    if (activity == null) {
      return const Scaffold(body: Center(child: Text('Activity not found')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Activity Details')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                key: const Key('activity_details'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.activityType,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Duration: ${activity.duration} min'),
                      Text('Calories: ${activity.calories} kcal'),
                      Text('Steps: ${activity.steps}'),
                      Text('Distance: ${activity.distance} km'),
                      Text('Date: ${activity.activityDateTime.toLocal()}'),
                      if (activity.notes != null && activity.notes!.isNotEmpty)
                        Text('Notes: ${activity.notes}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const Key('btn_edit_activity'),
                      onPressed: () =>
                          context.push('/edit-activity/${activity.id}'),
                      child: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonal(
                      key: const Key('btn_delete_activity'),
                      onPressed: () async {
                        await ref.read(
                          deleteActivityProvider(activity.id).future,
                        );
                        if (context.mounted) {
                          context.pop();
                        }
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
