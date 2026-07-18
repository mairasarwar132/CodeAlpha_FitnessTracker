import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';

class _QuickActionMenuItem {
  const _QuickActionMenuItem({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

/// Responsive quick-action buttons: Add Activity, View History, Stats, etc.
class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  @override
  Widget build(BuildContext context) {
    // All 6 quick action items
    final items = [
      _QuickActionMenuItem(
        label: AppStrings.dashboardAddActivity,
        icon: Icons.add_circle_rounded,
        route: AppRoutes.addActivity,
      ),
      _QuickActionMenuItem(
        label: AppStrings.dashboardViewHistory,
        icon: Icons.history_rounded,
        route: AppRoutes.history,
      ),
      _QuickActionMenuItem(
        label: 'Stats',
        icon: Icons.insights_rounded,
        route: AppRoutes.statistics,
      ),
      _QuickActionMenuItem(
        label: AppStrings.dashboardEditProfile,
        icon: Icons.person_rounded,
        route: AppRoutes.profile,
      ),
      _QuickActionMenuItem(
        label: 'Goals',
        icon: Icons.flag_rounded,
        route: AppRoutes.goals,
      ),
      _QuickActionMenuItem(
        label: 'Settings',
        icon: Icons.settings_rounded,
        route: AppRoutes.settings,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        // 3 columns on small screens, 6 on larger screens
        final crossAxisCount = totalWidth < 600 ? 3 : 6;
        final spacing = 8.0;
        final totalSpacing = spacing * (crossAxisCount - 1);
        final childWidth = (totalWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: childWidth,
                child: _QuickActionButton(
                  buttonKey: Key(
                    'btn_${item.label.toLowerCase().replaceAll(' ', '_')}',
                  ),
                  label: item.label,
                  icon: item.icon,
                  isPrimary: item.route == AppRoutes.addActivity,
                  onTap: () => context.push(item.route),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.buttonKey,
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final Key buttonKey;
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.accent, AppColors.accentDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.31),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: buttonKey,
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle_rounded,
                    color: AppColors.surface,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: buttonKey,
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: AppColors.primary),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}