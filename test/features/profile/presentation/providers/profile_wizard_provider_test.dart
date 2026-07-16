import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/features/profile/presentation/providers/profile_wizard_provider.dart';

void main() {
  group('ProfileWizardNotifier Unit Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is set up with defaults', () {
      final state = container.read(profileWizardProvider);
      expect(state.currentStep, equals(0));
      expect(state.name, isEmpty);
      expect(state.ageText, isEmpty);
      expect(state.heightText, isEmpty);
      expect(state.weightText, isEmpty);
      expect(state.dailyStepGoalText, equals('10000'));
      expect(state.goal, isEmpty);
      expect(state.errors, isEmpty);
      expect(state.isSaving, isFalse);
    });

    test('update methods modify state values and clear respective errors', () {
      final notifier = container.read(profileWizardProvider.notifier);

      notifier.updateName('Alice');
      notifier.updateAge('30');
      notifier.updateHeight('170');
      notifier.updateWeight('65');
      notifier.updateDailyStepGoal('8000');
      notifier.updateGoal('Get fit');

      final state = container.read(profileWizardProvider);
      expect(state.name, equals('Alice'));
      expect(state.ageText, equals('30'));
      expect(state.heightText, equals('170'));
      expect(state.weightText, equals('65'));
      expect(state.dailyStepGoalText, equals('8000'));
      expect(state.goal, equals('Get fit'));
    });

    group('Step 0 Validation (Personal Info)', () {
      test('fails when name is shorter than 2 characters', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateName('A');
        notifier.updateAge('25');

        final isValid = notifier.validateStep(0);
        expect(isValid, isFalse);
        expect(container.read(profileWizardProvider).errors['name'], isNotNull);
      });

      test('fails when age is below 10', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateName('Bob');
        notifier.updateAge('9');

        final isValid = notifier.validateStep(0);
        expect(isValid, isFalse);
        expect(container.read(profileWizardProvider).errors['age'], isNotNull);
      });

      test('fails when age is above 100', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateName('Bob');
        notifier.updateAge('101');

        final isValid = notifier.validateStep(0);
        expect(isValid, isFalse);
        expect(container.read(profileWizardProvider).errors['age'], isNotNull);
      });

      test('passes with valid name and age', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateName('Bob');
        notifier.updateAge('25');

        final isValid = notifier.validateStep(0);
        expect(isValid, isTrue);
        expect(container.read(profileWizardProvider).errors, isEmpty);
      });
    });

    group('Step 1 Validation (Body Metrics)', () {
      test('fails when height is below 50 cm or above 300 cm', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateHeight('49');
        notifier.updateWeight('70');

        expect(notifier.validateStep(1), isFalse);
        expect(container.read(profileWizardProvider).errors['height'], isNotNull);

        notifier.updateHeight('301');
        expect(notifier.validateStep(1), isFalse);
        expect(container.read(profileWizardProvider).errors['height'], isNotNull);
      });

      test('fails when weight is below 20 kg or above 500 kg', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateHeight('170');
        notifier.updateWeight('19');

        expect(notifier.validateStep(1), isFalse);
        expect(container.read(profileWizardProvider).errors['weight'], isNotNull);

        notifier.updateWeight('501');
        expect(notifier.validateStep(1), isFalse);
        expect(container.read(profileWizardProvider).errors['weight'], isNotNull);
      });

      test('passes with valid height and weight metrics', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateHeight('170');
        notifier.updateWeight('70');

        expect(notifier.validateStep(1), isTrue);
        expect(container.read(profileWizardProvider).errors, isEmpty);
      });
    });

    group('Step 2 Validation (Goals)', () {
      test('fails when dailyStepGoal is 1000 or less', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateDailyStepGoal('1000');

        expect(notifier.validateStep(2), isFalse);
        expect(container.read(profileWizardProvider).errors['dailyStepGoal'], isNotNull);
      });

      test('passes when dailyStepGoal is greater than 1000', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateDailyStepGoal('1001');

        expect(notifier.validateStep(2), isTrue);
        expect(container.read(profileWizardProvider).errors, isEmpty);
      });
    });

    group('Wizard Navigation Actions', () {
      test('nextStep only transitions forward if current step validates successfully', () {
        final notifier = container.read(profileWizardProvider.notifier);
        
        // Invalid page 1 data -> nextStep should fail
        notifier.updateName('A');
        expect(notifier.nextStep(), isFalse);
        expect(container.read(profileWizardProvider).currentStep, equals(0));

        // Valid page 1 data -> nextStep succeeds
        notifier.updateName('Alice');
        notifier.updateAge('25');
        expect(notifier.nextStep(), isTrue);
        expect(container.read(profileWizardProvider).currentStep, equals(1));
      });

      test('previousStep moves backward in steps', () {
        final notifier = container.read(profileWizardProvider.notifier);
        notifier.updateName('Alice');
        notifier.updateAge('25');
        notifier.nextStep(); // Goes to 1
        expect(container.read(profileWizardProvider).currentStep, equals(1));

        notifier.previousStep(); // Goes back to 0
        expect(container.read(profileWizardProvider).currentStep, equals(0));
      });
    });
  });
}
