import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/features/statistics/domain/models/statistics_models.dart';
import 'package:fitness_tracker/features/statistics/domain/repositories/statistics_repository.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  const StatisticsRepositoryImpl({required AppDatabase database})
    : _database = database;

  final AppDatabase _database;

  @override
  Future<StatisticsSummary> getStatisticsSummary({
    required StatisticsFilter filter,
    required int dailyStepGoal,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final range = _resolveRange(filter, startDate, endDate);
    final activities = await _database.getActivitiesByDateRange(
      range.start,
      range.end,
    );

    if (activities.isEmpty) {
      return StatisticsSummary.empty(filter: filter);
    }

    final sorted = activities.toList()
      ..sort((a, b) => a.activityDateTime.compareTo(b.activityDateTime));

    final totalSteps = sorted.fold<int>(0, (sum, item) => sum + item.steps);
    final totalCalories = sorted.fold<int>(
      0,
      (sum, item) => sum + item.calories,
    );
    final totalDistance = sorted.fold<double>(
      0,
      (sum, item) => sum + item.distance,
    );
    final totalActiveMinutes = sorted.fold<int>(
      0,
      (sum, item) => sum + item.duration,
    );
    final totalActivities = sorted.length;

    final uniqueDays = <DateTime>{};
    for (final activity in sorted) {
      final day = DateTime(
        activity.activityDateTime.year,
        activity.activityDateTime.month,
        activity.activityDateTime.day,
      );
      uniqueDays.add(day);
    }

    final averageDailySteps = uniqueDays.isEmpty
        ? 0.0
        : totalSteps / uniqueDays.length;
    final averageCalories = totalActivities == 0
        ? 0.0
        : totalCalories / totalActivities;
    final averageDistance = totalActivities == 0
        ? 0.0
        : totalDistance / totalActivities;
    final averageActivityDuration = totalActivities == 0
        ? 0.0
        : totalActiveMinutes / totalActivities;

    final dailyTrend = _buildDailyTrend(sorted);
    final weeklyTrend = _buildWeeklyTrend(sorted);
    final monthlyTrend = _buildMonthlyTrend(sorted);

    final distribution = _buildActivityDistribution(sorted);
    final streak = _calculateStreak(sorted);
    DateTime? bestDayDate;
    if (dailyTrend.isNotEmpty) {
      bestDayDate = dailyTrend
          .reduce((a, b) => a.totalSteps >= b.totalSteps ? a : b)
          .date;
    }

    final bestPerformanceDay = bestDayDate == null
        ? 'No data'
        : '${bestDayDate.year}-${bestDayDate.month.toString().padLeft(2, '0')}-${bestDayDate.day.toString().padLeft(2, '0')}';

    final goalCompletionPercent = dailyStepGoal <= 0
        ? 0.0
        : (totalSteps / dailyStepGoal) * 100;

    return StatisticsSummary(
      filter: filter,
      totalSteps: totalSteps,
      totalCalories: totalCalories,
      totalDistance: totalDistance,
      totalActiveMinutes: totalActiveMinutes,
      totalActivities: totalActivities,
      averageDailySteps: averageDailySteps,
      averageCalories: averageCalories,
      averageDistance: averageDistance,
      averageActivityDuration: averageActivityDuration,
      bestPerformanceDay: bestPerformanceDay,
      goalCompletionPercent: goalCompletionPercent.clamp(0.0, 100.0),
      streak: streak,
      activityDistribution: distribution,
      dailyTrend: dailyTrend,
      weeklyTrend: weeklyTrend,
      monthlyTrend: monthlyTrend,
    );
  }

  ({DateTime start, DateTime end}) _resolveRange(
    StatisticsFilter filter,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    final now = DateTime.now();
    switch (filter) {
      case StatisticsFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        return (
          start: start,
          end: start
              .add(const Duration(days: 1))
              .subtract(const Duration(milliseconds: 1)),
        );
      case StatisticsFilter.last7Days:
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        final start = end.subtract(const Duration(days: 6));
        return (start: DateTime(start.year, start.month, start.day), end: end);
      case StatisticsFilter.last30Days:
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        final start = end.subtract(const Duration(days: 29));
        return (start: DateTime(start.year, start.month, start.day), end: end);
      case StatisticsFilter.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return (start: start, end: end);
      case StatisticsFilter.customRange:
        final from = startDate ?? DateTime(now.year, now.month, 1);
        final to = endDate ?? DateTime(now.year, now.month, now.day);
        return (
          start: DateTime(from.year, from.month, from.day),
          end: DateTime(to.year, to.month, to.day, 23, 59, 59),
        );
    }
  }

  List<DailyStatistics> _buildDailyTrend(List<ActivitiesTableData> activities) {
    final grouped = <DateTime, _DailyAccumulator>{};
    for (final activity in activities) {
      final date = DateTime(
        activity.activityDateTime.year,
        activity.activityDateTime.month,
        activity.activityDateTime.day,
      );
      final current = grouped.putIfAbsent(date, () => _DailyAccumulator());
      current.totalSteps += activity.steps;
      current.totalCalories += activity.calories;
      current.totalDistance += activity.distance;
      current.totalActiveMinutes += activity.duration;
      current.totalActivities += 1;
      current.totalDuration += activity.duration;
    }

    return grouped.entries
        .map(
          (entry) => DailyStatistics(
            date: entry.key,
            totalSteps: entry.value.totalSteps,
            totalCalories: entry.value.totalCalories,
            totalDistance: entry.value.totalDistance,
            totalActiveMinutes: entry.value.totalActiveMinutes,
            totalActivities: entry.value.totalActivities,
            averageDuration:
                entry.value.totalDuration / entry.value.totalActivities,
          ),
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<WeeklyStatistics> _buildWeeklyTrend(
    List<ActivitiesTableData> activities,
  ) {
    final grouped = <String, _WeeklyAccumulator>{};
    for (final activity in activities) {
      final date = activity.activityDateTime;
      final weekStart = date.subtract(Duration(days: date.weekday - 1));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final key = '${weekStart.year}-${weekStart.month}-${weekStart.day}';
      final current = grouped.putIfAbsent(key, () => _WeeklyAccumulator());
      current.totalSteps += activity.steps;
      current.totalCalories += activity.calories;
      current.totalDistance += activity.distance;
      current.totalActiveMinutes += activity.duration;
      current.totalActivities += 1;
      current.startDate = weekStart;
      current.endDate = weekEnd;
    }

    return grouped.entries.map((entry) {
      final value = entry.value;
      return WeeklyStatistics(
        startDate: value.startDate ?? DateTime.now(),
        endDate: value.endDate ?? DateTime.now(),
        totalSteps: value.totalSteps,
        totalCalories: value.totalCalories,
        totalDistance: value.totalDistance,
        totalActiveMinutes: value.totalActiveMinutes,
        totalActivities: value.totalActivities,
      );
    }).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  List<MonthlyStatistics> _buildMonthlyTrend(
    List<ActivitiesTableData> activities,
  ) {
    final grouped = <String, _MonthlyAccumulator>{};
    for (final activity in activities) {
      final key =
          '${activity.activityDateTime.year}-${activity.activityDateTime.month}';
      final current = grouped.putIfAbsent(key, () => _MonthlyAccumulator());
      current.totalSteps += activity.steps;
      current.totalCalories += activity.calories;
      current.totalDistance += activity.distance;
      current.totalActiveMinutes += activity.duration;
      current.totalActivities += 1;
      current.monthLabel =
          '${activity.activityDateTime.year}-${activity.activityDateTime.month.toString().padLeft(2, '0')}';
    }

    return grouped.entries.map((entry) {
      final value = entry.value;
      return MonthlyStatistics(
        monthLabel: value.monthLabel ?? entry.key,
        totalSteps: value.totalSteps,
        totalCalories: value.totalCalories,
        totalDistance: value.totalDistance,
        totalActiveMinutes: value.totalActiveMinutes,
        totalActivities: value.totalActivities,
      );
    }).toList()..sort((a, b) => a.monthLabel.compareTo(b.monthLabel));
  }

  ActivityDistribution _buildActivityDistribution(
    List<ActivitiesTableData> activities,
  ) {
    final counts = <String, int>{};
    for (final activity in activities) {
      final type = activity.activityType.trim().isEmpty
          ? 'Other'
          : activity.activityType;
      counts[type] = (counts[type] ?? 0) + 1;
    }

    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ActivityDistribution(
      counts: counts,
      mostFrequentActivity: sorted.isEmpty ? 'No activity' : sorted.first.key,
      totalActivities: activities.length,
    );
  }

  StreakStatistics _calculateStreak(List<ActivitiesTableData> activities) {
    if (activities.isEmpty) {
      return const StreakStatistics(currentStreak: 0, longestStreak: 0);
    }

    final uniqueDays =
        activities
            .map(
              (activity) => DateTime(
                activity.activityDateTime.year,
                activity.activityDateTime.month,
                activity.activityDateTime.day,
              ),
            )
            .toSet()
            .toList()
          ..sort();

    int currentStreak = 1;
    int longestStreak = 1;
    int run = 1;

    for (int i = 1; i < uniqueDays.length; i++) {
      final diff = uniqueDays[i].difference(uniqueDays[i - 1]).inDays;
      if (diff == 1) {
        run += 1;
        currentStreak = run;
        longestStreak = longestStreak < run ? run : longestStreak;
      } else {
        run = 1;
        currentStreak = 1;
      }
    }

    return StreakStatistics(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
    );
  }
}

class _DailyAccumulator {
  int totalSteps = 0;
  int totalCalories = 0;
  double totalDistance = 0.0;
  int totalActiveMinutes = 0;
  int totalActivities = 0;
  int totalDuration = 0;
}

class _WeeklyAccumulator {
  int totalSteps = 0;
  int totalCalories = 0;
  double totalDistance = 0.0;
  int totalActiveMinutes = 0;
  int totalActivities = 0;
  DateTime? startDate;
  DateTime? endDate;
}

class _MonthlyAccumulator {
  int totalSteps = 0;
  int totalCalories = 0;
  double totalDistance = 0.0;
  int totalActiveMinutes = 0;
  int totalActivities = 0;
  String? monthLabel;
}
