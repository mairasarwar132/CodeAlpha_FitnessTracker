import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _notificationsKey = 'settings.notifications';
const _remindersKey = 'settings.reminders';
const _distanceUnitKey = 'settings.distance_unit';
const _weightUnitKey = 'settings.weight_unit';

class SettingsState {
  const SettingsState({
    this.notificationsEnabled = true,
    this.remindersEnabled = true,
    this.distanceUnit = 'km',
    this.weightUnit = 'kg',
    this.isLoading = true,
    this.error,
    this.successMessage,
  });

  final bool notificationsEnabled;
  final bool remindersEnabled;
  final String distanceUnit;
  final String weightUnit;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? remindersEnabled,
    String? distanceUnit,
    String? weightUnit,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      weightUnit: weightUnit ?? this.weightUnit,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this.ref) : super(const SettingsState()) {
    _loadSettings();
  }

  final Ref ref;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = SettingsState(
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? true,
      remindersEnabled: prefs.getBool(_remindersKey) ?? true,
      distanceUnit: prefs.getString(_distanceUnitKey) ?? 'km',
      weightUnit: prefs.getString(_weightUnitKey) ?? 'kg',
      isLoading: false,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    state = state.copyWith(notificationsEnabled: value, successMessage: null);
  }

  Future<void> setRemindersEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersKey, value);
    state = state.copyWith(remindersEnabled: value, successMessage: null);
  }

  Future<void> setDistanceUnit(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_distanceUnitKey, value);
    state = state.copyWith(distanceUnit: value, successMessage: null);
  }

  Future<void> setWeightUnit(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_weightUnitKey, value);
    state = state.copyWith(weightUnit: value, successMessage: null);
  }

  Future<void> resetProfile() async {
    final profileRepo = ref.read(profileRepositoryProvider);
    await profileRepo.deleteProfile();
    state = state.copyWith(successMessage: 'Profile reset.');
  }

  Future<void> resetActivities() async {
    final activityRepo = ref.read(activityRepositoryProvider);
    final activities = await activityRepo.getAllActivities();
    for (final activity in activities) {
      await activityRepo.deleteActivity(activity.id);
    }
    state = state.copyWith(successMessage: 'Activities cleared.');
  }

  Future<void> resetStatistics() async {
    await resetActivities();
    state = state.copyWith(successMessage: 'Statistics cleared.');
  }

  Future<void> resetAllAppData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await resetProfile();
    await resetActivities();
    state = state.copyWith(successMessage: 'All app data reset.');
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(ref),
);
