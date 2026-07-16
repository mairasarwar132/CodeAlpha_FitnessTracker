import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker/core/constants/app_strings.dart';
import 'package:fitness_tracker/core/services/app_preferences.dart';

void main() {
  group('AppPreferences', () {
    setUp(() {
      // Reset the in-memory store before every test so tests are isolated.
      SharedPreferences.setMockInitialValues({});
    });

    // -------------------------------------------------------------------------
    // isFirstLaunch
    // -------------------------------------------------------------------------

    test('isFirstLaunch returns true when flag has never been written', () async {
      final prefs = await AppPreferences.create();

      expect(await prefs.isFirstLaunch(), isTrue);
    });

    test('isFirstLaunch returns false after setFirstLaunchCompleted is called',
        () async {
      final prefs = await AppPreferences.create();

      await prefs.setFirstLaunchCompleted();

      expect(await prefs.isFirstLaunch(), isFalse);
    });

    test('isFirstLaunch returns false when flag was pre-set to true', () async {
      // Simulate a device that already completed onboarding.
      SharedPreferences.setMockInitialValues({
        AppStrings.prefKeyFirstLaunchCompleted: true,
      });
      final prefs = await AppPreferences.create();

      expect(await prefs.isFirstLaunch(), isFalse);
    });

    // -------------------------------------------------------------------------
    // setFirstLaunchCompleted
    // -------------------------------------------------------------------------

    test('setFirstLaunchCompleted is idempotent – calling it twice is safe',
        () async {
      final prefs = await AppPreferences.create();

      await prefs.setFirstLaunchCompleted();
      await prefs.setFirstLaunchCompleted(); // second call must not throw

      expect(await prefs.isFirstLaunch(), isFalse);
    });

    // -------------------------------------------------------------------------
    // clearFirstLaunchFlag
    // -------------------------------------------------------------------------

    test('clearFirstLaunchFlag resets the flag so isFirstLaunch returns true',
        () async {
      final prefs = await AppPreferences.create();

      await prefs.setFirstLaunchCompleted();
      expect(await prefs.isFirstLaunch(), isFalse);

      await prefs.clearFirstLaunchFlag();
      expect(await prefs.isFirstLaunch(), isTrue);
    });

    // -------------------------------------------------------------------------
    // Persistence across instances
    // -------------------------------------------------------------------------

    test('flag persists across separate AppPreferences instances', () async {
      // Write via first instance.
      final prefs1 = await AppPreferences.create();
      await prefs1.setFirstLaunchCompleted();

      // Read via a new instance (same underlying SharedPreferences mock).
      final prefs2 = await AppPreferences.create();
      expect(await prefs2.isFirstLaunch(), isFalse);
    });
  });
}
