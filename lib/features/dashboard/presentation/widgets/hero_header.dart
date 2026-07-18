import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';

/// A premium Hero header that shows a motivational quote, animation,
/// and today's goal progress summary.
class HeroHeader extends StatelessWidget {
  const HeroHeader({
    super.key,
    required this.quote,
    required this.currentSteps,
    required this.goalSteps,
    required this.progress,
  });

  final String quote;
  final int currentSteps;
  final int goalSteps;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Lottie animation (left)
          SizedBox(
            width: 120,
            height: 120,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                color: AppColors.surface,
                child: Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_jcikwtux.json',
                  fit: BoxFit.cover,
                  repeat: true,
                  delegates: LottieDelegates(
                    values: [
                      // Keep default; delegate placeholders for performance tuning
                    ],
                  ),
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.directions_run_rounded,
                      size: 48,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Textual info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.dashboardTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Motivational quote
                Text(
                  quote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 12),

                // Today's Goal small summary
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$currentSteps',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'of $goalSteps steps',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            SizedBox(
                              width: 56,
                              height: 56,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: progress,
                                    strokeWidth: 6,
                                    backgroundColor: AppColors.divider,
                                    valueColor: AlwaysStoppedAnimation(
                                      AppColors.accent,
                                    ),
                                  ),
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}%',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Lightweight placeholder to avoid importing provider internals in this file.