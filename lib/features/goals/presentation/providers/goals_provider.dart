import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _dailyStepsKey = 'goals.daily_steps';
const _caloriesKey = 'goals.calories';
const _distanceKey = 'goals.distance';
const _activeMinutesKey = 'goals.active_minutes';
const _waterIntakeKey = 'goals.water_intake';

class GoalsState {
  const GoalsState({
    this.dailyStepsGoal = 10000,
    this.caloriesGoal = 2000,
    this.distanceGoal = 8.0,
    this.activeMinutesGoal = 45,
    this.waterIntakeGoal = 2.5,
    this.isLoading = true,
    this.error,
    this.successMessage,
  });

  final int dailyStepsGoal;
  final int caloriesGoal;
  final double distanceGoal;
  final int activeMinutesGoal;
  final double waterIntakeGoal;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  GoalsState copyWith({
    int? dailyStepsGoal,
    int? caloriesGoal,
    double? distanceGoal,
    int? activeMinutesGoal,
    double? waterIntakeGoal,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return GoalsState(
      dailyStepsGoal: dailyStepsGoal ?? this.dailyStepsGoal,
      caloriesGoal: caloriesGoal ?? this.caloriesGoal,
      distanceGoal: distanceGoal ?? this.distanceGoal,
      activeMinutesGoal: activeMinutesGoal ?? this.activeMinutesGoal,
      waterIntakeGoal: waterIntakeGoal ?? this.waterIntakeGoal,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class GoalsNotifier extends StateNotifier<GoalsState> {
  GoalsNotifier() : super(const GoalsState()) {
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final prefs = await SharedPreferences.getInstance();
    state = GoalsState(
      dailyStepsGoal: prefs.getInt(_dailyStepsKey) ?? 10000,
      caloriesGoal: prefs.getInt(_caloriesKey) ?? 2000,
      distanceGoal: prefs.getDouble(_distanceKey) ?? 8.0,
      activeMinutesGoal: prefs.getInt(_activeMinutesKey) ?? 45,
      waterIntakeGoal: prefs.getDouble(_waterIntakeKey) ?? 2.5,
      isLoading: false,
    );
  }

  void updateDailyStepsGoal(String value) {
    final intValue = int.tryParse(value);
    state = state.copyWith(
      dailyStepsGoal: intValue ?? state.dailyStepsGoal,
      error: null,
      successMessage: null,
    );
  }

  void updateCaloriesGoal(String value) {
    final intValue = int.tryParse(value);
    state = state.copyWith(
      caloriesGoal: intValue ?? state.caloriesGoal,
      error: null,
      successMessage: null,
    );
  }

  void updateDistanceGoal(String value) {
    final doubleValue = double.tryParse(value);
    state = state.copyWith(
      distanceGoal: doubleValue ?? state.distanceGoal,
      error: null,
      successMessage: null,
    );
  }

  void updateActiveMinutesGoal(String value) {
    final intValue = int.tryParse(value);
    state = state.copyWith(
      activeMinutesGoal: intValue ?? state.activeMinutesGoal,
      error: null,
      successMessage: null,
    );
  }

  void updateWaterIntakeGoal(String value) {
    final doubleValue = double.tryParse(value);
    state = state.copyWith(
      waterIntakeGoal: doubleValue ?? state.waterIntakeGoal,
      error: null,
      successMessage: null,
    );
  }

  Future<bool> saveGoals() async {
    if (state.dailyStepsGoal <= 0 ||
        state.caloriesGoal <= 0 ||
        state.activeMinutesGoal <= 0 ||
        state.distanceGoal <= 0 ||
        state.waterIntakeGoal <= 0) {
      state = state.copyWith(error: 'All goals must be greater than zero.');
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_dailyStepsKey, state.dailyStepsGoal);
      await prefs.setInt(_caloriesKey, state.caloriesGoal);
      await prefs.setDouble(_distanceKey, state.distanceGoal);
      await prefs.setInt(_activeMinutesKey, state.activeMinutesGoal);
      await prefs.setDouble(_waterIntakeKey, state.waterIntakeGoal);
      state = state.copyWith(successMessage: 'Goals saved successfully.');
      return true;
    } catch (_) {
      state = state.copyWith(error: 'Unable to save goals right now.');
      return false;
    }
  }

  Future<void> resetGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dailyStepsKey);
      await prefs.remove(_caloriesKey);
      await prefs.remove(_distanceKey);
      await prefs.remove(_activeMinutesKey);
      await prefs.remove(_waterIntakeKey);
      state = const GoalsState(
        isLoading: false,
        successMessage: 'Goals reset to defaults.',
      );
    } catch (_) {
      state = state.copyWith(error: 'Unable to reset goals.');
    }
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>(
  (ref) => GoalsNotifier(),
);
