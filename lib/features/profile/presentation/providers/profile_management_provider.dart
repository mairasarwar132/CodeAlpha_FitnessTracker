import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefAgeKey = 'profile.age';
const _prefGenderKey = 'profile.gender';
const _prefGoalWeightKey = 'profile.goal_weight';
const _prefActivityLevelKey = 'profile.activity_level';

class ProfileManagementState {
  const ProfileManagementState({
    this.name = '',
    this.ageText = '',
    this.gender = 'Prefer not to say',
    this.heightText = '',
    this.weightText = '',
    this.goalWeightText = '',
    this.activityLevel = 'Moderate',
    this.isLoading = true,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  final String name;
  final String ageText;
  final String gender;
  final String heightText;
  final String weightText;
  final String goalWeightText;
  final String activityLevel;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  ProfileManagementState copyWith({
    String? name,
    String? ageText,
    String? gender,
    String? heightText,
    String? weightText,
    String? goalWeightText,
    String? activityLevel,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) {
    return ProfileManagementState(
      name: name ?? this.name,
      ageText: ageText ?? this.ageText,
      gender: gender ?? this.gender,
      heightText: heightText ?? this.heightText,
      weightText: weightText ?? this.weightText,
      goalWeightText: goalWeightText ?? this.goalWeightText,
      activityLevel: activityLevel ?? this.activityLevel,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
    );
  }

  BmiResult get bmiResult {
    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);
    if (height == null || height <= 0 || weight == null || weight <= 0) {
      return const BmiResult(
        value: 0,
        category: 'Add measurements',
        healthIndicator: 'Enter your height and weight to calculate BMI.',
      );
    }

    final bmi = weight / ((height / 100) * (height / 100));
    String category;
    String healthIndicator;

    if (bmi < 18.5) {
      category = 'Underweight';
      healthIndicator = 'Consider increasing calories and strength training.';
    } else if (bmi < 25) {
      category = 'Healthy';
      healthIndicator = 'Your BMI is in a healthy range.';
    } else if (bmi < 30) {
      category = 'Overweight';
      healthIndicator = 'A light activity increase can help.';
    } else {
      category = 'Obese';
      healthIndicator = 'A balanced plan and professional guidance may help.';
    }

    return BmiResult(
      value: bmi,
      category: category,
      healthIndicator: healthIndicator,
    );
  }
}

class BmiResult {
  const BmiResult({
    required this.value,
    required this.category,
    required this.healthIndicator,
  });

  final double value;
  final String category;
  final String healthIndicator;
}

class ProfileManagementNotifier extends StateNotifier<ProfileManagementState> {
  ProfileManagementNotifier(this.ref) : super(const ProfileManagementState()) {
    _loadProfile();
  }

  final Ref ref;

  Future<void> _loadProfile() async {
    final profileRepo = ref.read(profileRepositoryProvider);
    final profile = await profileRepo.getProfile();
    final prefs = await SharedPreferences.getInstance();

    state = ProfileManagementState(
      name: profile?.name ?? '',
      ageText: prefs.getInt(_prefAgeKey)?.toString() ?? '',
      gender: prefs.getString(_prefGenderKey) ?? 'Prefer not to say',
      heightText: profile?.height.toString() ?? '',
      weightText: profile?.weight.toString() ?? '',
      goalWeightText: prefs.getDouble(_prefGoalWeightKey)?.toString() ?? '',
      activityLevel: prefs.getString(_prefActivityLevelKey) ?? 'Moderate',
      isLoading: false,
    );
  }

  void updateName(String value) {
    state = state.copyWith(name: value, error: null, successMessage: null);
  }

  void updateAge(String value) {
    state = state.copyWith(ageText: value, error: null, successMessage: null);
  }

  void updateGender(String value) {
    state = state.copyWith(gender: value, error: null, successMessage: null);
  }

  void updateHeight(String value) {
    state = state.copyWith(
      heightText: value,
      error: null,
      successMessage: null,
    );
  }

  void updateWeight(String value) {
    state = state.copyWith(
      weightText: value,
      error: null,
      successMessage: null,
    );
  }

  void updateGoalWeight(String value) {
    state = state.copyWith(
      goalWeightText: value,
      error: null,
      successMessage: null,
    );
  }

  void updateActivityLevel(String value) {
    state = state.copyWith(
      activityLevel: value,
      error: null,
      successMessage: null,
    );
  }

  Future<bool> saveProfile() async {
    if (state.name.trim().length < 2) {
      state = state.copyWith(error: 'Please provide a full name.');
      return false;
    }

    final age = int.tryParse(state.ageText);
    if (age == null || age < 10 || age > 100) {
      state = state.copyWith(error: 'Age must be between 10 and 100.');
      return false;
    }

    final height = double.tryParse(state.heightText);
    if (height == null || height < 50 || height > 300) {
      state = state.copyWith(error: 'Height must be between 50 and 300 cm.');
      return false;
    }

    final weight = double.tryParse(state.weightText);
    if (weight == null || weight < 20 || weight > 500) {
      state = state.copyWith(error: 'Weight must be between 20 and 500 kg.');
      return false;
    }

    final goalWeight = state.goalWeightText.isEmpty
        ? null
        : double.tryParse(state.goalWeightText);
    if (goalWeight != null && (goalWeight < 20 || goalWeight > 500)) {
      state = state.copyWith(
        error: 'Goal weight must be between 20 and 500 kg.',
      );
      return false;
    }

    state = state.copyWith(isSaving: true, error: null, successMessage: null);

    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      final companion = UserProfileTableCompanion(
        name: drift.Value(state.name.trim()),
        height: drift.Value(height),
        weight: drift.Value(weight),
      );

      await profileRepo.saveProfile(companion);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefAgeKey, age);
      await prefs.setString(_prefGenderKey, state.gender);
      if (goalWeight != null) {
        await prefs.setDouble(_prefGoalWeightKey, goalWeight);
      } else {
        await prefs.remove(_prefGoalWeightKey);
      }
      await prefs.setString(_prefActivityLevelKey, state.activityLevel);

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Profile saved successfully.',
      );
      return true;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        error: 'Unable to save profile right now.',
      );
      return false;
    }
  }

  Future<void> resetProfile() async {
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.deleteProfile();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefAgeKey);
      await prefs.remove(_prefGenderKey);
      await prefs.remove(_prefGoalWeightKey);
      await prefs.remove(_prefActivityLevelKey);
      state = const ProfileManagementState(
        isLoading: false,
        successMessage: 'Profile reset complete.',
      );
    } catch (_) {
      state = state.copyWith(error: 'Unable to reset profile.');
    }
  }
}

final profileManagementProvider =
    StateNotifierProvider<ProfileManagementNotifier, ProfileManagementState>(
      (ref) => ProfileManagementNotifier(ref),
    );

final bmiProvider = Provider<BmiResult>((ref) {
  final state = ref.watch(profileManagementProvider);
  return state.bmiResult;
});
