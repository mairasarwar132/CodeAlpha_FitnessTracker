import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/features/profile/presentation/providers/profile_wizard_provider.dart';

/// Multi-step setup wizard screen for user profile creation.
class ProfileWizardScreen extends ConsumerWidget {
  const ProfileWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileWizardProvider);
    final theme = Theme.of(context);

    // Display list of steps
    final steps = [
      const _PersonalInfoStep(),
      const _BodyMetricsStep(),
      const _GoalsStep(),
      const _ReviewStep(),
    ];

    final stepTitles = [
      'Personal Info',
      'Body Metrics',
      'Set Goals',
      'Review & Save',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Profile'),
      ),
      body: SafeArea(
        child: state.isSaving
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Saving your profile...'),
                  ],
                ),
              )
            : Column(
                children: [
                  // Step Progress Indicator
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              stepTitles[state.currentStep],
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            Text(
                              'Step ${state.currentStep + 1} of 4',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (state.currentStep + 1) / 4,
                          backgroundColor: theme.colorScheme.primary.withAlpha(40),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Dynamic step content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: steps[state.currentStep],
                    ),
                  ),

                  // Display overall save error if any
                  if (state.errors.containsKey('save'))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        state.errors['save']!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Bottom Control Buttons
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Back Button
                        state.currentStep > 0
                            ? OutlinedButton(
                                key: const Key('wizard_back_button'),
                                onPressed: () {
                                  ref
                                      .read(profileWizardProvider.notifier)
                                      .previousStep();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                child: const Text('Back'),
                              )
                            : const SizedBox.shrink(),

                        // Next or Save Button
                        ElevatedButton(
                          key: const Key('wizard_next_button'),
                          onPressed: () async {
                            final notifier =
                                ref.read(profileWizardProvider.notifier);
                            if (state.currentStep < 3) {
                              notifier.nextStep();
                            } else {
                              final success = await notifier.saveProfile();
                              if (success && context.mounted) {
                                context.go(AppRoutes.dashboard);
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(state.currentStep == 3
                              ? 'Save & Finish'
                              : 'Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PersonalInfoStep extends ConsumerWidget {
  const _PersonalInfoStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileWizardProvider);
    final notifier = ref.read(profileWizardProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Tell us about yourself',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Enter your name and age to personalize your experience.'),
          const SizedBox(height: 32),
          TextFormField(
            key: const Key('input_name_field'),
            initialValue: state.name,
            decoration: InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. John Doe',
              errorText: state.errors['name'],
              prefixIcon: const Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            onChanged: notifier.updateName,
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const Key('input_age_field'),
            initialValue: state.ageText,
            decoration: InputDecoration(
              labelText: 'Age',
              hintText: 'e.g. 25',
              errorText: state.errors['age'],
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            onChanged: notifier.updateAge,
          ),
        ],
      ),
    );
  }
}

class _BodyMetricsStep extends ConsumerWidget {
  const _BodyMetricsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileWizardProvider);
    final notifier = ref.read(profileWizardProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Body Metrics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text('We use height and weight to calculate performance indicators.'),
          const SizedBox(height: 32),
          TextFormField(
            key: const Key('input_height_field'),
            initialValue: state.heightText,
            decoration: InputDecoration(
              labelText: 'Height (cm)',
              hintText: 'e.g. 175',
              errorText: state.errors['height'],
              prefixIcon: const Icon(Icons.height),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: notifier.updateHeight,
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const Key('input_weight_field'),
            initialValue: state.weightText,
            decoration: InputDecoration(
              labelText: 'Weight (kg)',
              hintText: 'e.g. 70',
              errorText: state.errors['weight'],
              prefixIcon: const Icon(Icons.monitor_weight),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: notifier.updateWeight,
          ),
        ],
      ),
    );
  }
}

class _GoalsStep extends ConsumerWidget {
  const _GoalsStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileWizardProvider);
    final notifier = ref.read(profileWizardProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Set Your Targets',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Set a daily step target and optional health focus goal.'),
          const SizedBox(height: 32),
          TextFormField(
            key: const Key('input_step_field'),
            initialValue: state.dailyStepGoalText,
            decoration: InputDecoration(
              labelText: 'Daily Step Goal',
              hintText: 'e.g. 10000',
              errorText: state.errors['dailyStepGoal'],
              prefixIcon: const Icon(Icons.directions_walk),
            ),
            keyboardType: TextInputType.number,
            onChanged: notifier.updateDailyStepGoal,
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const Key('input_goal_field'),
            initialValue: state.goal,
            decoration: const InputDecoration(
              labelText: 'Personal Health Goal (Optional)',
              hintText: 'e.g. Lose weight, Run a 5k marathon',
              prefixIcon: Icon(Icons.emoji_events),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            onChanged: notifier.updateGoal,
          ),
        ],
      ),
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  const _ReviewStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileWizardProvider);
    final theme = Theme.of(context);

    Widget buildReviewRow(String label, String value, IconData icon) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: theme.textTheme.bodySmall),
                  Text(
                    value.isEmpty ? 'Not set' : value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Review Details',
            style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          const Text('Check your information below before saving.'),
          const SizedBox(height: 24),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  buildReviewRow('Name', state.name, Icons.person),
                  const Divider(),
                  buildReviewRow('Age', '${state.ageText} years old', Icons.calendar_today),
                  const Divider(),
                  buildReviewRow('Height', '${state.heightText} cm', Icons.height),
                  const Divider(),
                  buildReviewRow('Weight', '${state.weightText} kg', Icons.monitor_weight),
                  const Divider(),
                  buildReviewRow(
                    'Daily Step Goal',
                    '${state.dailyStepGoalText} steps',
                    Icons.directions_walk,
                  ),
                  const Divider(),
                  buildReviewRow(
                    'Health Goal',
                    state.goal,
                    Icons.emoji_events,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
