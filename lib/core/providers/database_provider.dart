import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/database/app_database.dart';

/// Singleton [AppDatabase] provider.
///
/// Exposed as a [Provider] so every feature reads from the same
/// database connection throughout the app's lifetime.
final databaseProvider = Provider<AppDatabase>(
  (ref) {
    final db = AppDatabase();

    // Dispose the database connection when the provider is destroyed.
    ref.onDispose(db.close);

    return db;
  },
);
