import 'package:flutter/material.dart';
import 'package:fitness_tracker/features/onboarding/presentation/models/onboarding_page_model.dart';

/// A presentation widget that displays a single page of onboarding content.
///
/// It uses a layout responsive to screen heights and weights, dynamically scaling
/// the icon and text spacing, and is fully styled according to the context's
/// active theme.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    required this.model,
    super.key,
  });

  final OnboardingPageModel model;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Responsive scaling based on viewport size
    final double iconSize = size.height * 0.18;
    final double spacing = size.height * 0.04;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon Container with elegant rounded design
              Container(
                width: iconSize * 1.3,
                height: iconSize * 1.3,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    model.icon,
                    size: iconSize,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(height: spacing * 1.5),
              // Onboarding Title
              Text(
                model.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: spacing * 0.5),
              // Onboarding Subtitle
              Text(
                model.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.63),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
