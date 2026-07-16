class StatisticsSummary {
  const StatisticsSummary({
    required this.filter,
    required this.totalSteps,
    required this.totalCalories,
    required this.totalDistance,
    required this.totalActiveMinutes,
    required this.totalActivities,
    required this.averageDailySteps,
    required this.averageCalories,
    required this.averageDistance,
    required this.averageActivityDuration,
    required this.bestPerformanceDay,
    required this.goalCompletionPercent,
    required this.streak,
    required this.activityDistribution,
    required this.dailyTrend,
    required this.weeklyTrend,
    required this.monthlyTrend,
  });

  final StatisticsFilter filter;
  final int totalSteps;
  final int totalCalories;
  final double totalDistance;
  final int totalActiveMinutes;
  final int totalActivities;
  final double averageDailySteps;
  final double averageCalories;
  final double averageDistance;
  final double averageActivityDuration;
  final String bestPerformanceDay;
  final double goalCompletionPercent;
  final StreakStatistics streak;
  final ActivityDistribution activityDistribution;
  final List<DailyStatistics> dailyTrend;
  final List<WeeklyStatistics> weeklyTrend;
  final List<MonthlyStatistics> monthlyTrend;

  factory StatisticsSummary.empty({required StatisticsFilter filter}) {
    return StatisticsSummary(
      filter: filter,
      totalSteps: 0,
      totalCalories: 0,
      totalDistance: 0.0,
      totalActiveMinutes: 0,
      totalActivities: 0,
      averageDailySteps: 0.0,
      averageCalories: 0.0,
      averageDistance: 0.0,
      averageActivityDuration: 0.0,
      bestPerformanceDay: 'No data',
      goalCompletionPercent: 0.0,
      streak: const StreakStatistics(currentStreak: 0, longestStreak: 0),
      activityDistribution: const ActivityDistribution(
        counts: {},
        mostFrequentActivity: 'No activity',
        totalActivities: 0,
      ),
      dailyTrend: const [],
      weeklyTrend: const [],
      monthlyTrend: const [],
    );
  }
}

class DailyStatistics {
  const DailyStatistics({
    required this.date,
    required this.totalSteps,
    required this.totalCalories,
    required this.totalDistance,
    required this.totalActiveMinutes,
    required this.totalActivities,
    required this.averageDuration,
  });

  final DateTime date;
  final int totalSteps;
  final int totalCalories;
  final double totalDistance;
  final int totalActiveMinutes;
  final int totalActivities;
  final double averageDuration;
}

class WeeklyStatistics {
  const WeeklyStatistics({
    required this.startDate,
    required this.endDate,
    required this.totalSteps,
    required this.totalCalories,
    required this.totalDistance,
    required this.totalActiveMinutes,
    required this.totalActivities,
  });

  final DateTime startDate;
  final DateTime endDate;
  final int totalSteps;
  final int totalCalories;
  final double totalDistance;
  final int totalActiveMinutes;
  final int totalActivities;
}

class MonthlyStatistics {
  const MonthlyStatistics({
    required this.monthLabel,
    required this.totalSteps,
    required this.totalCalories,
    required this.totalDistance,
    required this.totalActiveMinutes,
    required this.totalActivities,
  });

  final String monthLabel;
  final int totalSteps;
  final int totalCalories;
  final double totalDistance;
  final int totalActiveMinutes;
  final int totalActivities;
}

class ActivityDistribution {
  const ActivityDistribution({
    required this.counts,
    required this.mostFrequentActivity,
    required this.totalActivities,
  });

  final Map<String, int> counts;
  final String mostFrequentActivity;
  final int totalActivities;
}

class StreakStatistics {
  const StreakStatistics({
    required this.currentStreak,
    required this.longestStreak,
  });

  final int currentStreak;
  final int longestStreak;
}

enum StatisticsFilter { today, last7Days, last30Days, thisMonth, customRange }
