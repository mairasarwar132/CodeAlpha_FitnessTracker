import 'package:flutter/material.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';

/// Premium goal progress card with gradient ring and glass effect.
class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    super.key,
    required this.currentSteps,
    required this.goalSteps,
    required this.progress,
    required this.remainingSteps,
    required this.isGoalComplete,
  });

  final int currentSteps;
  final int goalSteps;
  final double progress;
  final int remainingSteps;
  final bool isGoalComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = isGoalComplete ? AppColors.success : AppColors.accent;

    return Semantics(
      label: '${AppStrings.dashboardDailyGoal}: $currentSteps of $goalSteps steps',
      child: Container(
        key: const Key('goal_progress_card'),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E293B), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(50),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // ── Circular Progress ──
              SizedBox(
                width: 88,
                height: 88,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surface.withAlpha(30),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: progressColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              // ── Text Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.dashboardDailyGoal,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.surface.withAlpha(180),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _formatNumber(currentSteps),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.surface,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    Text(
                      'of ${_formatNumber(goalSteps)} steps',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.surface.withAlpha(150),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (isGoalComplete)
                      _GoalBadge(label: AppStrings.dashboardGoalComplete)
                    else
                      Text(
                        '${_formatNumber(remainingSteps)} ${AppStrings.dashboardStepsRemaining}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: progressColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int n) {
    if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(n % 1000 == 0 ? 0 : 1)}k';
    }
    return n.toString();
  }
}

class _GoalBadge extends StatelessWidget {
  const _GoalBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withAlpha(100)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.success,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
