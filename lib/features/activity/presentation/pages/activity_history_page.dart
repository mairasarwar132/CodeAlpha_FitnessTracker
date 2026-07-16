import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/features/activity/presentation/providers/activity_providers.dart';

class ActivityHistoryPage extends ConsumerWidget {
  const ActivityHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncActivities = ref.watch(activityListProvider);
    final searchQuery = ref.watch(activitySearchProvider);
    final selectedFilter = ref.watch(activityFilterProvider);
    final sortMode = ref.watch(activitySortProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Activity History')),
      floatingActionButton: FloatingActionButton(
        key: const Key('btn_add_activity'),
        onPressed: () => context.push(AppRoutes.addActivity),
        child: const Icon(Icons.add),
      ),
      body: asyncActivities.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) =>
            Center(child: Text('Failed to load activities: $error')),
        data: (items) {
          var filtered = items.where((item) {
            final matchesSearch =
                item.activityType.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ||
                (item.notes ?? '').toLowerCase().contains(
                  searchQuery.toLowerCase(),
                );
            final matchesFilter =
                selectedFilter == null || selectedFilter == item.activityType;
            return matchesSearch && matchesFilter;
          }).toList();

          filtered.sort((a, b) {
            switch (sortMode) {
              case 'oldest':
                return a.activityDateTime.compareTo(b.activityDateTime);
              case 'calories':
                return b.calories.compareTo(a.calories);
              case 'duration':
                return b.duration.compareTo(a.duration);
              case 'newest':
              default:
                return b.activityDateTime.compareTo(a.activityDateTime);
            }
          });

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      key: const Key('activity_search'),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search activities',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) =>
                          ref.read(activitySearchProvider.notifier).state =
                              value,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            key: const Key('activity_filter'),
                            initialValue: selectedFilter,
                            decoration: const InputDecoration(
                              labelText: 'Filter by type',
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All'),
                              ),
                              ...const [
                                'Walking',
                                'Running',
                                'Cycling',
                                'Gym Workout',
                                'Yoga',
                                'Swimming',
                                'Hiking',
                                'Other',
                              ].map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                ref
                                        .read(activityFilterProvider.notifier)
                                        .state =
                                    value,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: sortMode,
                            decoration: const InputDecoration(
                              labelText: 'Sort',
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'newest',
                                child: Text('Newest'),
                              ),
                              DropdownMenuItem(
                                value: 'oldest',
                                child: Text('Oldest'),
                              ),
                              DropdownMenuItem(
                                value: 'calories',
                                child: Text('Calories'),
                              ),
                              DropdownMenuItem(
                                value: 'duration',
                                child: Text('Duration'),
                              ),
                            ],
                            onChanged: (value) =>
                                ref.read(activitySortProvider.notifier).state =
                                    value ?? 'newest',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  key: const Key('activity_list'),
                  child: filtered.isEmpty
                      ? const Center(child: Text('No activities found'))
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final activity = filtered[index];
                            return ListTile(
                              key: Key('activity_tile_${activity.id}'),
                              onTap: () => context.push(
                                '${AppRoutes.history}/${activity.id}',
                              ),
                              title: Text(activity.activityType),
                              subtitle: Text(
                                '${activity.duration} min • ${activity.calories} kcal',
                              ),
                              trailing: Text(
                                '${activity.activityDateTime.day}/${activity.activityDateTime.month}',
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
