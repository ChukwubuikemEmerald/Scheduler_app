import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_app_project/preferences_repository.dart';

final preferencesRepositoryProvider = Provider<PreferencesRepository>(
  (ref) => PreferencesRepository(),
);

final darkModeProvider = AsyncNotifierProvider<DarkModeNotifier, bool>(
  DarkModeNotifier.new,
);

class DarkModeNotifier extends AsyncNotifier<bool> {
  PreferencesRepository get _repo => ref.read(preferencesRepositoryProvider);

  @override
  Future<bool> build() async {
    return _repo.getDarkMode();
  }

  Future<bool> toggleDarkMode() async {
    final currentDarkMode = state.value ?? false;
    final newDarkMode = !currentDarkMode;
    try {
      await _repo.setDarkMode(newDarkMode);
      state = AsyncData(newDarkMode);
      return newDarkMode;
    } catch (error, stackTrace) {
      print('The Error: $error');
      print('The Stack Trace: $stackTrace');

      state = AsyncData(currentDarkMode);
      rethrow;
    }
  }
}
