import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';
import 'package:fitness_tracker/features/activity/presentation/pages/activity_details_page.dart';
import 'package:fitness_tracker/features/activity/presentation/pages/activity_form_page.dart';
import 'package:fitness_tracker/features/activity/presentation/pages/activity_history_page.dart';
import 'package:fitness_tracker/features/activity/domain/repositories/activity_repository.dart';
import 'package:fitness_tracker/core/database/app_database.dart';

class _FakeActivityRepository implements ActivityRepository {
  _FakeActivityRepository(this.items);
  final List<ActivitiesTableData> items;

  @override
  Future<List<ActivitiesTableData>> getActivitiesByDateRange(
    DateTime s,
    DateTime e,
  ) async => items;
  @override
  Future<int> insertActivity(ActivitiesTableCompanion e) async => 1;
  @override
  Future<List<ActivitiesTableData>> getAllActivities() async => items;
  @override
  Future<void> updateActivity(ActivitiesTableCompanion e) async {}
  @override
  Future<void> deleteActivity(int id) async {}
}

Widget _buildTestApp() {
  final router = GoRouter(
    initialLocation: AppRoutes.history,
    routes: [
      GoRoute(
        path: AppRoutes.history,
        builder: (context, _) => const ActivityHistoryPage(),
      ),
      GoRoute(
        path: AppRoutes.addActivity,
        builder: (context, _) => const ActivityFormPage(),
      ),
      GoRoute(
        path: '${AppRoutes.history}/:id',
        builder: (context, state) => ActivityDetailsPage(
          activityId: int.parse(state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/edit-activity/:id',
        builder: (context, state) => ActivityFormPage(activity: null),
      ),
    ],
  );

  return ProviderScope(
    overrides: [
      activityRepositoryProvider.overrideWithValue(
        _FakeActivityRepository(const []),
      ),
    ],
    child: MaterialApp.router(routerConfig: router),
  );
}

void main() {
  testWidgets('activity history page renders search and list controls', (
    tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('activity_search')), findsOneWidget);
    expect(find.byKey(const Key('activity_filter')), findsOneWidget);
    expect(find.byKey(const Key('activity_list')), findsOneWidget);
  });
}
