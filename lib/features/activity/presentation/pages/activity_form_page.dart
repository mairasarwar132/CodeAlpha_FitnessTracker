import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fitness_tracker/features/activity/domain/models/activity_model.dart';
import 'package:fitness_tracker/features/activity/domain/usecases/activity_validation.dart';
import 'package:fitness_tracker/features/activity/presentation/providers/activity_providers.dart';

class ActivityFormPage extends ConsumerStatefulWidget {
  const ActivityFormPage({super.key, this.activity, this.activityId});

  final ActivityModel? activity;
  final int? activityId;

  @override
  ConsumerState<ActivityFormPage> createState() => _ActivityFormPageState();
}

class _ActivityFormPageState extends ConsumerState<ActivityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _typeController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _stepsController = TextEditingController();
  final _distanceController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedType;
  bool _hasLoadedInitialValues = false;

  @override
  void initState() {
    super.initState();
    _populateFromActivity(widget.activity);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedInitialValues) {
      final editingActivity =
          widget.activity ??
          (widget.activityId != null
              ? ref.watch(activityDetailsProvider(widget.activityId!))
              : null);
      _populateFromActivity(editingActivity);
    }
  }

  void _populateFromActivity(ActivityModel? activity) {
    if (activity == null || _hasLoadedInitialValues) {
      return;
    }
    _selectedType = activity.activityType;
    _typeController.text = activity.activityType;
    _durationController.text = activity.duration.toString();
    _caloriesController.text = activity.calories.toString();
    _stepsController.text = activity.steps.toString();
    _distanceController.text = activity.distance.toString();
    _notesController.text = activity.notes ?? '';
    _selectedDate = activity.activityDateTime;
    _selectedTime = TimeOfDay.fromDateTime(activity.activityDateTime);
    _hasLoadedInitialValues = true;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _stepsController.dispose();
    _distanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final activity = ActivityModel(
      id: widget.activity?.id ?? 0,
      activityType: _selectedType ?? 'Other',
      duration: int.parse(_durationController.text),
      calories: int.parse(_caloriesController.text),
      steps: int.parse(_stepsController.text),
      distance: double.parse(_distanceController.text),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      activityDateTime: dateTime,
      createdAt: widget.activity?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (widget.activity == null) {
      await ref.read(createActivityProvider(activity).future);
    } else {
      await ref.read(updateActivityProvider(activity).future);
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.activity != null || widget.activityId != null;
    final asyncActivities = ref.watch(activityListProvider);
    final editingActivity =
        widget.activity ??
        (widget.activityId != null
            ? asyncActivities.whenOrNull(
                data: (items) => items
                    .where((item) => item.id == widget.activityId)
                    .firstOrNull,
              )
            : null);

    if (widget.activityId != null && asyncActivities.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.activityId != null && asyncActivities.hasError) {
      return Scaffold(
        body: Center(
          child: Text('Failed to load activity: ${asyncActivities.error}'),
        ),
      );
    }

    if (widget.activityId != null && editingActivity == null) {
      return const Scaffold(body: Center(child: Text('Activity not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Activity' : 'Add Activity')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Card(
                  key: const Key('activity_form'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          key: const Key('activity_type'),
                          initialValue: _selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Activity Type',
                          ),
                          items:
                              const [
                                    'Walking',
                                    'Running',
                                    'Cycling',
                                    'Gym Workout',
                                    'Yoga',
                                    'Swimming',
                                    'Hiking',
                                    'Other',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedType = value),
                          validator: (value) =>
                              ActivityValidation.validateActivityType(value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('activity_duration'),
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Duration (min)',
                          ),
                          validator: (value) =>
                              ActivityValidation.validateDuration(value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('activity_steps'),
                          controller: _stepsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Steps'),
                          validator: (value) =>
                              ActivityValidation.validateSteps(value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('activity_distance'),
                          controller: _distanceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Distance (km)',
                          ),
                          validator: (value) =>
                              ActivityValidation.validateDistance(value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('activity_calories'),
                          controller: _caloriesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Calories',
                          ),
                          validator: (value) =>
                              ActivityValidation.validateCalories(value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const Key('activity_notes'),
                          controller: _notesController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Notes'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: _pickDate,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Date',
                                  ),
                                  child: Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: _pickTime,
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Time',
                                  ),
                                  child: Text(_selectedTime.format(context)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                key: const Key('btn_cancel_activity'),
                                onPressed: () => context.pop(),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                key: const Key('btn_save_activity'),
                                onPressed: _submit,
                                child: Text(
                                  isEditing ? 'Save Changes' : 'Save Activity',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
