import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/providers/database_provider.dart';
import 'package:fitness_tracker/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:fitness_tracker/features/statistics/domain/models/statistics_models.dart';
import 'package:fitness_tracker/features/statistics/domain/repositories/statistics_repository.dart';

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepositoryImpl(database: ref.watch(databaseProvider));
});

final selectedFilterProvider = StateProvider<StatisticsFilter>(
  (ref) => StatisticsFilter.today,
);

final statisticsProvider =
    FutureProvider.family<StatisticsSummary, StatisticsFilter>((
      ref,
      filter,
    ) async {
      final repository = ref.watch(statisticsRepositoryProvider);
      final stepGoal = ref.watch(dailyStepGoalProvider);
      return repository.getStatisticsSummary(
        filter: filter,
        dailyStepGoal: stepGoal,
      );
    });

final dailyStatisticsProvider = Provider<DailyStatistics?>((ref) => null);
final weeklyStatisticsProvider = Provider<WeeklyStatistics?>((ref) => null);
final monthlyStatisticsProvider = Provider<MonthlyStatistics?>((ref) => null);
final activityDistributionProvider = Provider<ActivityDistribution?>(
  (ref) => null,
);
final streakProvider = Provider<StreakStatistics?>((ref) => null);

final dailyStepGoalProvider = Provider<int>((ref) => 10000);
