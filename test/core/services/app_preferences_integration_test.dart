import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';
import 'package:fitness_tracker/core/services/app_preferences.dart';

/// Integration-level tests that verify the full read-write-read lifecycle of
/// [AppPreferences] against the SharedPreferences mock store.
void main() {
  group('AppPreferences – first launch integration', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('full first-launch flow: detect → complete → verify', () async {
      final prefs = await AppPreferences.create();

      // Step 1: fresh install → first launch expected.
      expect(await prefs.isFirstLaunch(), isTrue,
          reason: 'Should be first launch on a clean install');

      // Step 2: user completes onboarding.
      await prefs.setFirstLaunchCompleted();

      // Step 3: subsequent launches should skip onboarding.
      expect(await prefs.isFirstLaunch(), isFalse,
          reason: 'Should NOT be first launch after completing onboarding');
    });

    test('full reset flow: set → clear → detect as first launch again',
        () async {
      final prefs = await AppPreferences.create();

      await prefs.setFirstLaunchCompleted();
      expect(await prefs.isFirstLaunch(), isFalse);

      // Simulate debug/account reset.
      await prefs.clearFirstLaunchFlag();
      expect(await prefs.isFirstLaunch(), isTrue,
          reason: 'Should be treated as first launch after flag is cleared');
    });

    test('persistence: new instance reads value written by previous instance',
        () async {
      // Write via first AppPreferences instance.
      final prefs1 = await AppPreferences.create();
      await prefs1.setFirstLaunchCompleted();

      // Create a brand-new instance (same underlying shared_preferences mock).
      final prefs2 = await AppPreferences.create();
      expect(await prefs2.isFirstLaunch(), isFalse,
          reason: 'Flag must persist across separate service instances');
    });

    test(
        'stores correct key name in SharedPreferences',
        () async {
      final prefs = await AppPreferences.create();
      await prefs.setFirstLaunchCompleted();

      // Verify the concrete key used in the store matches AppStrings.
      final raw = await SharedPreferences.getInstance();
      expect(
        raw.getBool(AppStrings.prefKeyFirstLaunchCompleted),
        isTrue,
        reason:
            'The key "${AppStrings.prefKeyFirstLaunchCompleted}" must exist in SharedPreferences',
      );
    });
  });
}
