import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:fitness_tracker/features/dashboard/presentation/widgets/stat_card.dart';
import 'package:fitness_tracker/features/dashboard/presentation/widgets/goal_progress_card.dart';
import 'package:fitness_tracker/features/dashboard/presentation/widgets/activity_list_tile.dart';
import 'package:fitness_tracker/features/dashboard/presentation/widgets/quick_actions_bar.dart';

/// Main dashboard / home screen with premium fitness styling.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
        },
        child: statsAsync.when(
          loading: () => const _LoadingBody(),
          error: (e, _) => _ErrorBody(error: e.toString()),
          data: (stats) => _DashboardBody(stats: stats),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading state
// ---------------------------------------------------------------------------
class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.accent),
          SizedBox(height: 16),
          Text(
            'Loading your stats…',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------
class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error});
  final String error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load dashboard',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loaded body
// ---------------------------------------------------------------------------
class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.stats});
  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final greeting = _greeting(now.hour);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return CustomScrollView(
      key: const Key('dashboard_scroll_view'),
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // ── Premium Header ──
        SliverAppBar(
          expandedHeight: 150,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 4,
          shadowColor: AppColors.primary.withValues(alpha: 0.24),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.gradientDark),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    MediaQuery.of(context).padding.top + 8,
                    20,
                    12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        greeting,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AppStrings.dashboardTitle,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: AppColors.surface,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Body Content ──
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 12 : 16,
            20,
            isSmallScreen ? 12 : 16,
            100,
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Stats Grid (responsive 2-column) ──
              _StatsGrid(stats: stats, isSmallScreen: isSmallScreen),

              const SizedBox(height: 16),

              // ── Goal Progress ──
              GoalProgressCard(
                currentSteps: stats.totalSteps,
                goalSteps: stats.dailyStepGoal,
                progress: stats.goalProgress,
                remainingSteps: stats.remainingSteps,
                isGoalComplete: stats.isGoalComplete,
              ),

              const SizedBox(height: 20),

              // ── Quick Actions ──
              const QuickActionsBar(key: Key('quick_actions_bar')),

              const SizedBox(height: 24),

              // ── Today's Activities Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.dashboardTodaysActivities,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${stats.activities.length} logged',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.accentDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── Activities List or Empty State ──
              if (stats.activities.isEmpty)
                const _EmptyActivitiesState()
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListView.separated(
                      key: const Key('activities_list'),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: stats.activities.length,
                      separatorBuilder: (context, _) =>
                          const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, index) =>
                          ActivityListTile(activity: stats.activities[index]),
                    ),
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }

  static String _greeting(int hour) {
    if (hour < 12) return AppStrings.dashboardGreetingMorning;
    if (hour < 17) return AppStrings.dashboardGreetingAfternoon;
    return AppStrings.dashboardGreetingEvening;
  }
}

// ---------------------------------------------------------------------------
// Responsive Stats Grid
// ---------------------------------------------------------------------------
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.isSmallScreen});

  final DashboardStats stats;
  final bool isSmallScreen;

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = isSmallScreen ? 10.0 : 12.0;
        final availableWidth = constraints.maxWidth - spacing;
        final cardWidth = availableWidth / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: StatCard(
                key: const Key('stat_steps'),
                label: AppStrings.dashboardSteps,
                value: _formatNumber(stats.totalSteps),
                unit: 'steps',
                icon: Icons.directions_walk_rounded,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                key: const Key('stat_calories'),
                label: AppStrings.dashboardCalories,
                value: stats.totalCalories.toString(),
                unit: 'kcal',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                key: const Key('stat_distance'),
                label: AppStrings.dashboardDistance,
                value: stats.totalDistanceKm.toString(),
                unit: 'km',
                icon: Icons.route_rounded,
                color: AppColors.accentDark,
              ),
            ),
            SizedBox(
              width: cardWidth,
              child: StatCard(
                key: const Key('stat_active_min'),
                label: AppStrings.dashboardActiveMinutes,
                value: stats.totalActiveMinutes.toString(),
                unit: 'min',
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

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------
class _EmptyActivitiesState extends StatelessWidget {
  const _EmptyActivitiesState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: AppStrings.dashboardNoActivities,
      child: Container(
        key: const Key('empty_activities_state'),
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 40,
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.dashboardNoActivities,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.dashboardNoActivitiesSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
