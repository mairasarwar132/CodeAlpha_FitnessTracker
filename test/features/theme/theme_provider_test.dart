import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker/features/theme/presentation/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme provider defaults to system mode', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Initial state is ThemeMode.system before async _loadTheme completes
    var mode = container.read(themeProvider);
    expect(mode, ThemeMode.system);

    // Wait for async _loadTheme to complete
    await Future(() {});
    await Future(() {});

    mode = container.read(themeProvider);
    expect(mode, ThemeMode.system);
  });
}
