import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/features/settings/presentation/providers/settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('settings provider exposes default values', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(settingsProvider);
    expect(state.notificationsEnabled, isTrue);
    expect(state.remindersEnabled, isTrue);
  });
}
