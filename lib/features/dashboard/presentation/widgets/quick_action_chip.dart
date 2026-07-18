import 'package:flutter/material.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/core/constants/app_dimens.dart';

class QuickActionChip extends StatelessWidget {
  const QuickActionChip({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isPrimary ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusButton),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusButton),
        child: Container(
          width: 120,
          padding: const EdgeInsets.symmetric(
            vertical: AppDimens.space4,
            horizontal: AppDimens.space4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusButton),
            border: Border.all(
              color: isPrimary
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.textSecondary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? AppColors.surface : AppColors.primary,
                size: 24,
              ),
              const SizedBox(height: AppDimens.space2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isPrimary ? AppColors.surface : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}