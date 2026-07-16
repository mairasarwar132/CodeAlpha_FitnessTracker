import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/features/goals/presentation/providers/goals_provider.dart';

class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(goalsProvider);
    final notifier = ref.read(goalsProvider.notifier);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fitness Goals')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Daily Steps Goal',
                ),
                keyboardType: TextInputType.number,
                onChanged: notifier.updateDailyStepsGoal,
                controller: TextEditingController(
                  text: state.dailyStepsGoal.toString(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(labelText: 'Calories Goal'),
                keyboardType: TextInputType.number,
                onChanged: notifier.updateCaloriesGoal,
                controller: TextEditingController(
                  text: state.caloriesGoal.toString(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Distance Goal (km)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: notifier.updateDistanceGoal,
                controller: TextEditingController(
                  text: state.distanceGoal.toString(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Active Minutes Goal',
                ),
                keyboardType: TextInputType.number,
                onChanged: notifier.updateActiveMinutesGoal,
                controller: TextEditingController(
                  text: state.activeMinutesGoal.toString(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Water Intake Goal (L)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: notifier.updateWaterIntakeGoal,
                controller: TextEditingController(
                  text: state.waterIntakeGoal.toString(),
                ),
              ),
              const SizedBox(height: 24),
              if (state.error != null)
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              if (state.successMessage != null)
                Text(
                  state.successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        await notifier.saveGoals();
                      },
                      child: const Text('Save Goals'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => notifier.resetGoals(),
                      child: const Text('Reset Defaults'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
