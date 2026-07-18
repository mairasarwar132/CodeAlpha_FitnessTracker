import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fitness_tracker/core/constants/app_colors.dart';
import 'package:fitness_tracker/core/constants/app_dimens.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key, required this.quote});

  final String quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppDimens.space5),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quote,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimens.space4),
                Text(
                  'Stay active and keep the momentum going with every step.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.surface.withValues(alpha: 0.82),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimens.space4),
          Expanded(
            flex: 5,
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusButton),
                child: Container(
                  color: AppColors.background,
                  child: Lottie.network(
                    'https://assets10.lottiefiles.com/packages/lf20_jcikwtux.json',
                    fit: BoxFit.cover,
                    repeat: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
