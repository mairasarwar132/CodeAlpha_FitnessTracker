import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/core/providers/database_provider.dart';
import 'package:fitness_tracker/features/profile/presentation/providers/profile_management_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('profile management provider initial state is loadable', () async {
    SharedPreferences.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final profileLoaded = Completer<void>();
    final subscription = container.listen<ProfileManagementState>(
      profileManagementProvider,
      (_, next) {
        if (!next.isLoading && !profileLoaded.isCompleted) {
          profileLoaded.complete();
        }
      },
    );
    addTearDown(subscription.close);

    final state = container.read(profileManagementProvider);
    expect(state.isLoading, isTrue);

    await profileLoaded.future.timeout(const Duration(seconds: 5));
  });
}
