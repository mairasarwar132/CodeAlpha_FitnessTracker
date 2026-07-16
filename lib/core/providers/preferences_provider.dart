import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/core/services/app_preferences.dart';

/// Provides a fully-initialised [AppPreferences] singleton.
///
/// Backed by a [FutureProvider] so that the async platform call to
/// [SharedPreferences.getInstance] is handled automatically by Riverpod.
/// Consumers can call [ref.watch] / [ref.read] on this provider and receive
/// the value once resolved.
///
/// The provider is intentionally **not** autoDispose so that the singleton
/// lives for the entire application lifetime.
final appPreferencesProvider = FutureProvider<AppPreferences>((ref) async {
  return AppPreferences.create();
});
