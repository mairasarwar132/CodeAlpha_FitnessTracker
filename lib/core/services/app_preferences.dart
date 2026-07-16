import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';

/// Service layer for persistent app preferences backed by SharedPreferences.
///
/// Handles all key–value reads and writes in one place, keeping implementation
/// details out of feature code.  Use the [AppPreferencesProvider] Riverpod
/// provider to obtain an instance instead of calling the constructor directly.
class AppPreferences {
  const AppPreferences._(this._prefs);

  final SharedPreferences _prefs;

  /// Creates an [AppPreferences] instance by awaiting [SharedPreferences.getInstance].
  ///
  /// Throws a [StateError] if the underlying platform call fails.
  static Future<AppPreferences> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences._(prefs);
  }

  // ---------------------------------------------------------------------------
  // First-Launch Detection
  // ---------------------------------------------------------------------------

  /// Returns `true` if this is the first time the app has been launched.
  ///
  /// Specifically, returns `true` when the [AppStrings.prefKeyFirstLaunchCompleted]
  /// key has **not** yet been set (i.e., defaults to `null`/`false`).
  /// Returns `false` once [setFirstLaunchCompleted] has been called.
  Future<bool> isFirstLaunch() async {
    try {
      final completed =
          _prefs.getBool(AppStrings.prefKeyFirstLaunchCompleted) ?? false;
      return !completed;
    } catch (e) {
      // Defensive fallback: treat as first launch so the user always sees
      // onboarding rather than being silently dropped into the dashboard.
      return true;
    }
  }

  /// Marks the first launch as completed so that subsequent launches navigate
  /// directly to the dashboard.
  ///
  /// Safe to call multiple times — subsequent calls are idempotent.
  Future<void> setFirstLaunchCompleted() async {
    try {
      await _prefs.setBool(AppStrings.prefKeyFirstLaunchCompleted, true);
    } catch (e) {
      // Non-fatal: if writing fails the user will see onboarding once more
      // on the next launch, which is the safer failure mode.
      // Errors are swallowed intentionally; in a real app wire up your logger
      // here (e.g. Firebase Crashlytics).
    }
  }

  /// Clears the first-launch flag.  Intended for testing and debug reset flows.
  Future<void> clearFirstLaunchFlag() async {
    try {
      await _prefs.remove(AppStrings.prefKeyFirstLaunchCompleted);
    } catch (_) {}
  }
}
