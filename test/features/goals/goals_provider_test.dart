import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/features/goals/presentation/providers/goals_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('goals provider exposes default values', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final state = container.read(goalsProvider);
    expect(state.dailyStepsGoal, greaterThan(0));
    expect(state.waterIntakeGoal, greaterThan(0));
  });
}
