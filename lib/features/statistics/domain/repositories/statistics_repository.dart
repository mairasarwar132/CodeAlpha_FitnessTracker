import 'package:fitness_tracker/features/statistics/domain/models/statistics_models.dart';

abstract class StatisticsRepository {
  Future<StatisticsSummary> getStatisticsSummary({
    required StatisticsFilter filter,
    required int dailyStepGoal,
    DateTime? startDate,
    DateTime? endDate,
  });
}
