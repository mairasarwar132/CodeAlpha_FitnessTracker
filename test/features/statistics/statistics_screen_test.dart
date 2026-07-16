import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/features/statistics/domain/models/statistics_models.dart';
import 'package:fitness_tracker/features/statistics/presentation/pages/statistics_screen.dart';
import 'package:fitness_tracker/features/statistics/presentation/providers/statistics_providers.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('statistics screen renders main sections', (tester) async {
    final router = GoRouter(
      initialLocation: AppRoutes.statistics,
      routes: [
        GoRoute(
          path: AppRoutes.statistics,
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          statisticsProvider(StatisticsFilter.today).overrideWith((ref) async {
            return const StatisticsSummary(
              filter: StatisticsFilter.today,
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
              streak: StreakStatistics(currentStreak: 0, longestStreak: 0),
              activityDistribution: ActivityDistribution(
                counts: {},
                mostFrequentActivity: 'No activity',
                totalActivities: 0,
              ),
              dailyTrend: [],
              weeklyTrend: [],
              monthlyTrend: [],
            );
          }),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Statistics'), findsOneWidget);
    expect(find.text('No statistics yet'), findsOneWidget);
  });
}
