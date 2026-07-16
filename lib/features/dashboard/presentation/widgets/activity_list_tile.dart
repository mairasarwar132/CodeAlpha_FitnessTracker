import 'package:flutter/material.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/core/database/app_database.dart';

/// Activity type → icon mapping.
IconData _iconForType(String type) {
  switch (type.toLowerCase()) {
    case 'running':
      return Icons.directions_run_rounded;
    case 'cycling':
      return Icons.directions_bike_rounded;
    case 'swimming':
      return Icons.pool_rounded;
    case 'walking':
      return Icons.directions_walk_rounded;
    case 'gym':
    case 'workout':
      return Icons.fitness_center_rounded;
    case 'yoga':
      return Icons.self_improvement_rounded;
    case 'hiking':
      return Icons.terrain_rounded;
    default:
      return Icons.sports_rounded;
  }
}

/// Activity type → color mapping.
Color _colorForType(String type) {
  switch (type.toLowerCase()) {
    case 'running':
      return AppColors.secondary;
    case 'cycling':
      return AppColors.accentDark;
    case 'swimming':
      return const Color(0xFF0EA5E9);
    case 'walking':
      return AppColors.accent;
    case 'gym':
    case 'workout':
      return AppColors.error;
    case 'yoga':
      return const Color(0xFF8B5CF6);
    case 'hiking':
      return AppColors.warning;
    default:
      return AppColors.textSecondary;
  }
}

/// A premium list tile representing a single activity entry.
class ActivityListTile extends StatelessWidget {
  const ActivityListTile({
    super.key,
    required this.activity,
  });

  final ActivitiesTableData activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForType(activity.activityType);
    final icon = _iconForType(activity.activityType);

    return Semantics(
      label: '${activity.activityType}: ${activity.duration} minutes, ${activity.calories} calories',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            // ── Activity Icon ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withAlpha(50)),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            // ── Activity Info ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _capitalize(activity.activityType),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${activity.duration} min  •  ${activity.steps} steps',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // ── Calories Badge ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${activity.calories}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color.withAlpha(180),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}
