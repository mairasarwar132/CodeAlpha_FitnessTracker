import 'package:fitness_tracker/core/database/app_database.dart';

/// Contract for all user-profile data operations.
///
/// Implementations live in the data layer; use-cases depend only on this
/// abstract interface (Dependency Inversion).
abstract class ProfileRepository {
  /// Persist (insert or update) the user profile.
  Future<void> saveProfile(UserProfileTableCompanion entry);

  /// Return the stored user profile, or null if none exists yet.
  Future<UserProfileTableData?> getProfile();

  /// Update the existing user profile row.
  Future<void> updateProfile(UserProfileTableCompanion entry);

  /// Permanently delete the user profile.
  Future<void> deleteProfile();
}
