import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/features/profile/presentation/providers/profile_management_provider.dart';

class ProfileManagementPage extends ConsumerWidget {
  const ProfileManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileManagementProvider);
    final notifier = ref.read(profileManagementProvider.notifier);
    final bmi = ref.watch(bmiProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                initialValue: state.name,
                onChanged: notifier.updateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                initialValue: state.ageText,
                onChanged: notifier.updateAge,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: state.gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const ['Prefer not to say', 'Female', 'Male', 'Other']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) =>
                    notifier.updateGender(value ?? state.gender),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                initialValue: state.heightText,
                onChanged: notifier.updateHeight,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                initialValue: state.weightText,
                onChanged: notifier.updateWeight,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Goal Weight (kg)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                initialValue: state.goalWeightText,
                onChanged: notifier.updateGoalWeight,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: state.activityLevel,
                decoration: const InputDecoration(labelText: 'Activity Level'),
                items: const ['Low', 'Moderate', 'High']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) =>
                    notifier.updateActivityLevel(value ?? state.activityLevel),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BMI: ${bmi.value.toStringAsFixed(1)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('Category: ${bmi.category}'),
                      Text(bmi.healthIndicator),
                    ],
                  ),
                ),
              ),
              if (state.error != null) ...[
                const SizedBox(height: 12),
                Text(state.error!, style: const TextStyle(color: Colors.red)),
              ],
              if (state.successMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: state.isSaving
                          ? null
                          : () async {
                              await notifier.saveProfile();
                            },
                      child: state.isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Save Profile'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => notifier.resetProfile(),
                      child: const Text('Reset'),
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
