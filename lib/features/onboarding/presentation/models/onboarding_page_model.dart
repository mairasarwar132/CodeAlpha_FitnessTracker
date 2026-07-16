import 'package:flutter/widgets.dart';

/// Data representation of an individual onboarding page.
///
/// Kept purely as a presentation model containing display data:
/// titles, subtitles, and icons.
class OnboardingPageModel {
  const OnboardingPageModel({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}
