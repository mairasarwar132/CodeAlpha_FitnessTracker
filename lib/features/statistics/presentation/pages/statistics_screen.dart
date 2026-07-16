import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/activity_pie_chart.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/analytics_card.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/calories_chart.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/empty_statistics_widget.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/statistics_card.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/statistics_header.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/streak_card.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/steps_chart.dart';
import 'package:fitness_tracker/features/statistics/presentation/widgets/trend_chart.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(selectedFilterProvider);
    final statsAsync = ref.watch(statisticsProvider(filter));
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Statistics'),
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (error, _) => EmptyStatisticsWidget(
          onRetry: () => ref.invalidate(statisticsProvider(filter)),
        ),
        data: (summary) {
          if (summary.totalActivities == 0) {
            return EmptyStatisticsWidget(
              onRetry: () => ref.invalidate(statisticsProvider(filter)),
            );
          }

          return RefreshIndicator(
            color: AppColors.accent,
            backgroundColor: AppColors.surface,
            onRefresh: () async => ref.invalidate(statisticsProvider(filter)),
            child: ListView(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              children: [
                const StatisticsHeader(),
                const SizedBox(height: 16),
                _buildStatsGrid(context, summary, isSmallScreen),
                const SizedBox(height: 16),
                StepsChart(data: summary.dailyTrend),
                const SizedBox(height: 12),
                CaloriesChart(data: summary.dailyTrend),
                const SizedBox(height: 12),
                ActivityPieChart(distribution: summary.activityDistribution),
                const SizedBox(height: 12),
                TrendChart(
                  title: 'Weekly trend',
                  values: summary.weeklyTrend
                      .map((e) => e.totalSteps.toDouble())
                      .toList(),
                ),
                const SizedBox(height: 12),
                TrendChart(
                  title: 'Monthly trend',
                  values: summary.monthlyTrend
                      .map((e) => e.totalSteps.toDouble())
                      .toList(),
                ),
                const SizedBox(height: 12),
                StreakCard(
                  currentStreak: summary.streak.currentStreak,
                  longestStreak: summary.streak.longestStreak,
                ),
                const SizedBox(height: 12),
                AnalyticsCard(
                  title: 'Best day',
                  value: summary.bestPerformanceDay,
                  subtitle: 'Top day by steps',
                ),
                const SizedBox(height: 8),
                AnalyticsCard(
                  title: 'Goal completion',
                  value:
                      '${summary.goalCompletionPercent.toStringAsFixed(0)}%',
                  subtitle: 'Against your daily step goal',
                ),
                const SizedBox(height: 8),
                AnalyticsCard(
                  title: 'Most frequent activity',
                  value: summary.activityDistribution.mostFrequentActivity,
                  subtitle: 'Most common workout type',
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid(
    BuildContext context,
    dynamic summary,
    bool isSmallScreen,
  ) {
    final spacing = isSmallScreen ? 10.0 : 12.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: StatisticsCard(
                label: 'Steps',
                value: summary.totalSteps.toString(),
                icon: Icons.directions_walk_rounded,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatisticsCard(
                label: 'Calories',
                value: summary.totalCalories.toString(),
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatisticsCard(
                label: 'Distance',
                value: summary.totalDistance.toStringAsFixed(1),
                icon: Icons.route_rounded,
                color: AppColors.accentDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatisticsCard(
                label: 'Active Min',
                value: summary.totalActiveMinutes.toString(),
                icon: Icons.timer_rounded,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        );
      },
    );
  }
}
