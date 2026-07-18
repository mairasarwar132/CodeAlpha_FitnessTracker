import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fitness_tracker/features/goals/presentation/providers/goals_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('goals provider exposes default values', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);

    // Read initial state (loading)
    var state = container.read(goalsProvider);
    expect(state.isLoading, true);

    // Wait for async _loadGoals to complete
    await Future(() {});
    await Future(() {});

    state = container.read(goalsProvider);
    expect(state.dailyStepsGoal, greaterThan(0));
    expect(state.waterIntakeGoal, greaterThan(0));
  });
}
