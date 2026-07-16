import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/features/theme/presentation/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('theme provider defaults to system mode', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final mode = container.read(themeProvider);
    expect(mode, ThemeMode.system);
  });
}
