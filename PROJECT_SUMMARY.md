# Project Summary

Fitness Tracker is a Flutter app for logging activities, tracking daily progress, managing a user profile, and viewing fitness statistics.

## Core Features

- Activity logging with duration, calories, steps, distance, and timestamps
- Dashboard summary for daily steps, calories, distance, active minutes, and goals
- Profile management with height, weight, BMI, and personal preferences
- Statistics views for activity and calorie trends
- Settings for app preferences

## Technical Stack

- Flutter and Dart
- Riverpod for state management
- Drift and SQLite for local persistence
- GoRouter for navigation
- SharedPreferences for lightweight preferences

## Verification

Before release, run:

```sh
flutter analyze
flutter test
```
