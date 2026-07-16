import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker/features/settings/presentation/providers/settings_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: const Text('Notifications'),
              value: state.notificationsEnabled,
              onChanged: notifier.setNotificationsEnabled,
            ),
            SwitchListTile(
              title: const Text('Reminders'),
              value: state.remindersEnabled,
              onChanged: notifier.setRemindersEnabled,
            ),
            ListTile(
              title: const Text('Distance Unit'),
              subtitle: Text(state.distanceUnit),
              trailing: DropdownButton<String>(
                value: state.distanceUnit,
                items: const ['km', 'miles']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) async {
                  if (value != null) await notifier.setDistanceUnit(value);
                },
              ),
            ),
            ListTile(
              title: const Text('Weight Unit'),
              subtitle: Text(state.weightUnit),
              trailing: DropdownButton<String>(
                value: state.weightUnit,
                items: const ['kg', 'lb']
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
                onChanged: (value) async {
                  if (value != null) await notifier.setWeightUnit(value);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Reset Profile'),
              trailing: const Icon(Icons.person_remove),
              onTap: () => notifier.resetProfile(),
            ),
            ListTile(
              title: const Text('Reset Activities'),
              trailing: const Icon(Icons.delete_sweep),
              onTap: () => notifier.resetActivities(),
            ),
            ListTile(
              title: const Text('Reset Statistics'),
              trailing: const Icon(Icons.insights),
              onTap: () => notifier.resetStatistics(),
            ),
            ListTile(
              title: const Text('Reset All App Data'),
              trailing: const Icon(Icons.restart_alt),
              onTap: () => notifier.resetAllAppData(),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (state.successMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  state.successMessage!,
                  style: const TextStyle(color: Colors.green),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
