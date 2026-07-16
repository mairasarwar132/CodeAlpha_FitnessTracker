import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';

/// Representation of the state within the Profile wizard setup flow.
class ProfileWizardState {
  const ProfileWizardState({
    this.name = '',
    this.ageText = '',
    this.heightText = '',
    this.weightText = '',
    this.dailyStepGoalText = '10000',
    this.goal = '',
    this.currentStep = 0,
    this.errors = const {},
    this.isSaving = false,
  });

  final String name;
  final String ageText;
  final String heightText;
  final String weightText;
  final String dailyStepGoalText;
  final String goal;
  final int currentStep;
  final Map<String, String> errors;
  final bool isSaving;

  ProfileWizardState copyWith({
    String? name,
    String? ageText,
    String? heightText,
    String? weightText,
    String? dailyStepGoalText,
    String? goal,
    int? currentStep,
    Map<String, String>? errors,
    bool? isSaving,
  }) {
    return ProfileWizardState(
      name: name ?? this.name,
      ageText: ageText ?? this.ageText,
      heightText: heightText ?? this.heightText,
      weightText: weightText ?? this.weightText,
      dailyStepGoalText: dailyStepGoalText ?? this.dailyStepGoalText,
      goal: goal ?? this.goal,
      currentStep: currentStep ?? this.currentStep,
      errors: errors ?? this.errors,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// State notifier that manages step changes, validations, and saving the profile.
class ProfileWizardNotifier extends AutoDisposeNotifier<ProfileWizardState> {
  @override
  ProfileWizardState build() {
    return const ProfileWizardState();
  }

  void updateName(String val) {
    state = state.copyWith(
      name: val,
      errors: Map.from(state.errors)..remove('name'),
    );
  }

  void updateAge(String val) {
    state = state.copyWith(
      ageText: val,
      errors: Map.from(state.errors)..remove('age'),
    );
  }

  void updateHeight(String val) {
    state = state.copyWith(
      heightText: val,
      errors: Map.from(state.errors)..remove('height'),
    );
  }

  void updateWeight(String val) {
    state = state.copyWith(
      weightText: val,
      errors: Map.from(state.errors)..remove('weight'),
    );
  }

  void updateDailyStepGoal(String val) {
    state = state.copyWith(
      dailyStepGoalText: val,
      errors: Map.from(state.errors)..remove('dailyStepGoal'),
    );
  }

  void updateGoal(String val) {
    state = state.copyWith(goal: val);
  }

  /// Changes the wizard step. Checks validation prior to stepping forward.
  bool nextStep() {
    if (validateStep(state.currentStep)) {
      if (state.currentStep < 3) {
        state = state.copyWith(currentStep: state.currentStep + 1);
        return true;
      }
    }
    return false;
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  /// Form validation logic for each individual step.
  bool validateStep(int step) {
    final newErrors = <String, String>{};

    if (step == 0) {
      // Step 1: Personal Info
      if (state.name.trim().length < 2) {
        newErrors['name'] = 'Name must be at least 2 characters';
      }
      final age = int.tryParse(state.ageText);
      if (age == null || age < 10 || age > 100) {
        newErrors['age'] = 'Age must be between 10 and 100';
      }
    } else if (step == 1) {
      // Step 2: Body Metrics
      final height = double.tryParse(state.heightText);
      if (height == null || height < 50 || height > 300) {
        newErrors['height'] = 'Height must be between 50 and 300 cm';
      }
      final weight = double.tryParse(state.weightText);
      if (weight == null || weight < 20 || weight > 500) {
        newErrors['weight'] = 'Weight must be between 20 and 500 kg';
      }
    } else if (step == 2) {
      // Step 3: Goals
      final steps = int.tryParse(state.dailyStepGoalText);
      if (steps == null || steps <= 1000) {
        newErrors['dailyStepGoal'] = 'Step goal must be greater than 1000';
      }
    }

    state = state.copyWith(errors: newErrors);
    return newErrors.isEmpty;
  }

  /// Saves the validated profile values directly to the Drift database.
  Future<bool> saveProfile() async {
    // Validate everything first
    bool allValid = true;
    for (int s = 0; s < 3; s++) {
      if (!validateStep(s)) {
        state = state.copyWith(currentStep: s);
        allValid = false;
        break;
      }
    }
    if (!allValid) return false;

    state = state.copyWith(isSaving: true);

    try {
      final repository = ref.read(profileRepositoryProvider);

      final height = double.parse(state.heightText);
      final weight = double.parse(state.weightText);
      final steps = int.parse(state.dailyStepGoalText);

      final companion = UserProfileTableCompanion(
        name: drift.Value(state.name.trim()),
        height: drift.Value(height),
        weight: drift.Value(weight),
        dailyStepGoal: drift.Value(steps),
        goal: drift.Value(state.goal.isEmpty ? null : state.goal.trim()),
      );

      await repository.saveProfile(companion);
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        errors: {'save': 'Failed to save profile. Please try again.'},
      );
      return false;
    }
  }
}

/// Provider for the active state in Profile setup wizard.
final profileWizardProvider =
    AutoDisposeNotifierProvider<ProfileWizardNotifier, ProfileWizardState>(
  ProfileWizardNotifier.new,
);
