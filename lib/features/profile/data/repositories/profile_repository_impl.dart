import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/features/profile/domain/repositories/profile_repository.dart';

/// Concrete implementation of [ProfileRepository].
///
/// Delegates all persistence operations to [AppDatabase].
/// Contains no business logic – only data-access concerns.
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required AppDatabase database})
      : _database = database;

  final AppDatabase _database;

  // ---------------------------------------------------------------------------
  // Validation helpers
  // ---------------------------------------------------------------------------

  /// Throws [ArgumentError] if any numeric field violates the basic rules:
  ///   height > 0, weight > 0, dailyStepGoal > 0.
  void _validateProfile(UserProfileTableCompanion entry) {
    if (entry.height.present && entry.height.value <= 0) {
      throw ArgumentError.value(
        entry.height.value,
        'height',
        'height must be > 0',
      );
    }
    if (entry.weight.present && entry.weight.value <= 0) {
      throw ArgumentError.value(
        entry.weight.value,
        'weight',
        'weight must be > 0',
      );
    }
    if (entry.dailyStepGoal.present && entry.dailyStepGoal.value <= 0) {
      throw ArgumentError.value(
        entry.dailyStepGoal.value,
        'dailyStepGoal',
        'dailyStepGoal must be > 0',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // ProfileRepository implementation
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveProfile(UserProfileTableCompanion entry) async {
    _validateProfile(entry);
    await _database.saveProfile(entry);
  }

  @override
  Future<UserProfileTableData?> getProfile() => _database.getProfile();

  @override
  Future<void> updateProfile(UserProfileTableCompanion entry) async {
    _validateProfile(entry);
    await _database.updateProfile(entry);
  }

  @override
  Future<void> deleteProfile() async {
    await _database.deleteProfile();
  }
}
