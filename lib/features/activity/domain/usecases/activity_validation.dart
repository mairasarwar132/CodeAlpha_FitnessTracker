/// Shared validation helpers for activity input.
class ActivityValidation {
  static String? validateActivityType(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select an activity type';
    }
    return null;
  }

  static String? validateDuration(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Duration must be greater than 0';
    }
    return null;
  }

  static String? validateCalories(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0) {
      return 'Calories cannot be negative';
    }
    return null;
  }

  static String? validateSteps(String? value) {
    final parsed = int.tryParse(value ?? '');
    if (parsed == null || parsed < 0) {
      return 'Steps cannot be negative';
    }
    return null;
  }

  static String? validateDistance(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || parsed < 0) {
      return 'Distance cannot be negative';
    }
    return null;
  }

  static String? validateNotes(String? value) {
    if (value != null && value.length > 250) {
      return 'Notes must be 250 characters or less';
    }
    return null;
  }
}
