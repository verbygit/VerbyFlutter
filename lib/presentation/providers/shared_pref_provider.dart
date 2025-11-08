import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/data_source/local/shared_preference_helper.dart';

class SharedPreferencesNotifier extends AsyncNotifier<SharedPreferencesHelper> {
  @override
  Future<SharedPreferencesHelper> build() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesHelper(prefs);
  }


}

final sharedPreferencesProvider =
    AsyncNotifierProvider<SharedPreferencesNotifier, SharedPreferencesHelper>(
  () => SharedPreferencesNotifier(),
);

// Synchronous provider for SharedPreferencesHelper
final sharedPreferencesHelperProvider = Provider<SharedPreferencesHelper>((ref) {
  final asyncValue = ref.watch(sharedPreferencesProvider);
  return asyncValue.when(
    data: (helper) => helper,
    loading: () => throw Exception('SharedPreferences not initialized'),
    error: (error, stack) => throw Exception('Failed to initialize SharedPreferences: $error'),
  );
});
