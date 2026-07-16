import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/core/providers/preferences_provider.dart';

/// Provider that runs the splash screen initialization logic.
///
/// Performs a 3-second minimum delay (to allow the animation to complete)
/// and checks [AppPreferences.isFirstLaunch] to decide where to navigate:
///
/// * First launch  → [AppRoutes.onboarding]
/// * Return launch → [AppRoutes.dashboard]
///
/// The provider is [FutureProvider.autoDispose] so its state is released
/// as soon as the splash screen is removed from the widget tree.
final splashInitializationProvider =
    FutureProvider.autoDispose<String>((ref) async {
  // 1. Minimum 3-second delay – run concurrently with the prefs read.
  final delayFuture = Future<void>.delayed(const Duration(seconds: 3));

  // 2. Await the preferences singleton (resolved once on app start).
  final prefsAsync = ref.watch(appPreferencesProvider);

  // If SharedPreferences hasn't initialised yet, wait for it.
  final prefs = await prefsAsync.when(
    data: (p) async => p,
    loading: () => ref.watch(appPreferencesProvider.future),
    // ignore: avoid_types_on_closure_parameters
    error: (e, _) => ref.watch(appPreferencesProvider.future),
  );

  // 3. Check first-launch status concurrently with the splash delay.
  final results = await Future.wait<dynamic>([
    delayFuture,
    prefs.isFirstLaunch(),
  ]);

  final isFirst = results[1] as bool;

  return isFirst ? AppRoutes.onboarding : AppRoutes.dashboard;
});
