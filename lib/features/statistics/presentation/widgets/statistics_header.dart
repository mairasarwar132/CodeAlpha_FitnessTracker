import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/features/statistics/domain/models/statistics_models.dart';
import 'package:fitness_tracker/features/statistics/presentation/providers/statistics_providers.dart';

class StatisticsHeader extends ConsumerWidget {
  const StatisticsHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedFilterProvider);
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your progress overview',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        DropdownButton<StatisticsFilter>(
          value: selected,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(
              value: StatisticsFilter.today,
              child: Text('Today'),
            ),
            DropdownMenuItem(
              value: StatisticsFilter.last7Days,
              child: Text('Last 7 days'),
            ),
            DropdownMenuItem(
              value: StatisticsFilter.last30Days,
              child: Text('Last 30 days'),
            ),
            DropdownMenuItem(
              value: StatisticsFilter.thisMonth,
              child: Text('This month'),
            ),
            DropdownMenuItem(
              value: StatisticsFilter.customRange,
              child: Text('Custom range'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              ref.read(selectedFilterProvider.notifier).state = value;
            }
          },
        ),
      ],
    );
  }
}
