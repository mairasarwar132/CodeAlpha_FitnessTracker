import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/core/constants/app_routes.dart';
import 'package:fitness_tracker/core/database/app_database.dart';
import 'package:fitness_tracker/core/providers/repository_providers.dart';
import 'package:fitness_tracker/features/profile/domain/repositories/profile_repository.dart';
import 'package:fitness_tracker/features/profile/presentation/pages/profile_wizard_screen.dart';

class FakeProfileRepository implements ProfileRepository {
  UserProfileTableCompanion? savedCompanion;

  @override
  Future<void> saveProfile(UserProfileTableCompanion entry) async {
    savedCompanion = entry;
  }

  @override
  Future<UserProfileTableData?> getProfile() async => null;

  @override
  Future<void> updateProfile(UserProfileTableCompanion entry) async {}

  @override
  Future<void> deleteProfile() async {}
}

void main() {
  group('ProfileWizardScreen Widget and Flow Tests', () {
    late FakeProfileRepository fakeRepository;
    late GoRouter testRouter;

    setUp(() {
      fakeRepository = FakeProfileRepository();
      testRouter = GoRouter(
        initialLocation: AppRoutes.profile,
        routes: [
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileWizardScreen(),
          ),
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const Scaffold(body: Text('Dashboard Screen')),
          ),
        ],
      );
    });

    testWidgets('renders first step textfields and navigates forward on validation success',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: MaterialApp.router(
            routerConfig: testRouter,
          ),
        ),
      );

      // Verify Step 1: Personal Info
      expect(find.text('Tell us about yourself'), findsOneWidget);
      expect(find.byKey(const Key('input_name_field')), findsOneWidget);
      expect(find.byKey(const Key('input_age_field')), findsOneWidget);

      // Tap Next without filling -> shows errors
      await tester.tap(find.byKey(const Key('wizard_next_button')));
      await tester.pumpAndSettle();

      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
      expect(find.text('Age must be between 10 and 100'), findsOneWidget);

      // Enter valid name and age
      await tester.enterText(find.byKey(const Key('input_name_field')), 'Bob');
      await tester.enterText(find.byKey(const Key('input_age_field')), '25');
      await tester.pumpAndSettle();

      // Tap Next -> moves to Step 2
      await tester.tap(find.byKey(const Key('wizard_next_button')));
      await tester.pumpAndSettle();

      // Verify Step 2: Body Metrics
      expect(find.text('Body Metrics'), findsNWidgets(2));
      expect(find.byKey(const Key('input_height_field')), findsOneWidget);
      expect(find.byKey(const Key('input_weight_field')), findsOneWidget);

      // Enter invalid height and weight
      await tester.enterText(find.byKey(const Key('input_height_field')), '45');
      await tester.enterText(find.byKey(const Key('input_weight_field')), '15');
      await tester.pumpAndSettle();

      // Tap Next -> shows step 2 validation errors
      await tester.tap(find.byKey(const Key('wizard_next_button')));
      await tester.pumpAndSettle();

      expect(find.text('Height must be between 50 and 300 cm'), findsOneWidget);
      expect(find.text('Weight must be between 20 and 500 kg'), findsOneWidget);

      // Enter valid body metrics
      await tester.enterText(find.byKey(const Key('input_height_field')), '180');
      await tester.enterText(find.byKey(const Key('input_weight_field')), '80');
      await tester.pumpAndSettle();

      // Tap Next -> moves to Step 3
      await tester.tap(find.byKey(const Key('wizard_next_button')));
      await tester.pumpAndSettle();

      // Verify Step 3: Goals
      expect(find.text('Set Your Targets'), findsOneWidget);
      expect(find.byKey(const Key('input_step_field')), findsOneWidget);
      expect(find.byKey(const Key('input_goal_field')), findsOneWidget);

      // Clear steps and type invalid
      await tester.enterText(find.byKey(const Key('input_step_field')), '900');
      await tester.pumpAndSettle();

      // Tap Next -> shows steps validation errors
      await tester.tap(find.byKey(const Key('wizard_next_button')));
      await tester.pumpAndSettle();

      expect(find.text('Step goal must be greater than 1000'), findsOneWidget);

      // Enter valid steps and goal
      await tester.enterText(find.byKey(const Key('input_step_field')), '12000');
      await tester.enterText(find.byKey(const Key('input_goal_field')), 'Run a 10k race');
      await tester.pumpAndSettle();

      // Tap Next -> moves to Step 4: Review
      await tester.tap(find.byKey(const Key('wizard_next_button')));
      await tester.pumpAndSettle();

      // Verify Step 4: Review Details
      expect(find.text('Review Details'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('25 years old'), findsOneWidget);
      expect(find.text('180 cm'), findsOneWidget);
      expect(find.text('80 kg'), findsOneWidget);
      expect(find.text('12000 steps'), findsOneWidget);
      expect(find.text('Run a 10k race'), findsOneWidget);

      // Tap Save & Finish -> invokes repository save and redirects
      await tester.tap(find.byKey(const Key('wizard_next_button')));
      await tester.pumpAndSettle();

      // Verify saved variables inside database repository
      expect(fakeRepository.savedCompanion, isNotNull);
      expect(fakeRepository.savedCompanion!.name.value, equals('Bob'));
      expect(fakeRepository.savedCompanion!.height.value, equals(180.0));
      expect(fakeRepository.savedCompanion!.weight.value, equals(80.0));
      expect(fakeRepository.savedCompanion!.dailyStepGoal.value, equals(12000));
      expect(fakeRepository.savedCompanion!.goal.value, equals('Run a 10k race'));

      // Check redirection to Dashboard
      expect(find.text('Dashboard Screen'), findsOneWidget);
    });

    testWidgets('back button allows navigation to previous steps in wizard',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(fakeRepository),
          ],
          child: MaterialApp.router(
            routerConfig: testRouter,
          ),
        ),
      );

      // Enter Step 1 values
      await tester.enterText(find.byKey(const Key('input_name_field')), 'Bob');
      await tester.enterText(find.byKey(const Key('input_age_field')), '25');
      await tester.pumpAndSettle();

      // Next -> Step 2
      await tester.tap(find.byKey(const Key('wizard_next_button')));
      await tester.pumpAndSettle();

      expect(find.text('Body Metrics'), findsNWidgets(2));

      // Press Back -> Step 1
      await tester.tap(find.byKey(const Key('wizard_back_button')));
      await tester.pumpAndSettle();

      expect(find.text('Tell us about yourself'), findsOneWidget);
    });
  });
}
