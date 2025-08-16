import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/data_source/local/shared_preference_helper.dart';

class SharedPreferencesNotifier extends AsyncNotifier<SharedPreferencesHelper> {
  @override
  Future<SharedPreferencesHelper> build() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesHelper(prefs, false);
  }

  void setUpdated(bool value) async {
    state = AsyncValue.data(
        SharedPreferencesHelper(await SharedPreferences.getInstance(), value));
  }
}

final sharedPreferencesProvider =
    AsyncNotifierProvider<SharedPreferencesNotifier, SharedPreferencesHelper>(
  () => SharedPreferencesNotifier(),
);
