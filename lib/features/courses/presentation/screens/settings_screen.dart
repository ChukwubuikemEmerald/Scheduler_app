import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/preference_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final darkModeState = ref.watch(darkModeProvider);
    return Scaffold(
      appBar: AppBar(title: Text('flutter demo: Settings')),

      body: ListView(
        children: [
          darkModeState.when(
            loading: () => const CircularProgressIndicator(),
            error: (error, stackTrace) =>
                Text('Error loading settings, please try again.'),
            data: (darkMode) => SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Change the app visual theme'),
              value: darkMode,
              onChanged: (_) async {
                try {
                  await ref.read(darkModeProvider.notifier).toggleDarkMode();
                } catch (error) {
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to toggle dark mode. Try again.'),
                    ),
                  );
                }
              },
              secondary: Icon(darkMode ? Icons.dark_mode : Icons.light_mode),
            ),
          ),
        ],
      ),
    );
  }
}
