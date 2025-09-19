import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verby_flutter/data/data_source/local/shared_preference_helper.dart';
import '../../domain/entities/states/setting_screen_state.dart';

class SettingStateProvider extends StateNotifier<SettingScreenState> {
  SettingStateProvider() : super(SettingScreenState()) {
    setSharedPreferencesHelper();
  }

  void setSharedPreferencesHelper() async {
    final sharedPreferencesHelper = SharedPreferencesHelper(
      await SharedPreferences.getInstance(),
    );
    final isFaceForAll = await sharedPreferencesHelper.isFaceIdForAll();
    final isFaceForRegisterFace = await sharedPreferencesHelper
        .isFaceIdForRegisterFace();
    state = state.copyWith(
      sharedPreferencesHelper: sharedPreferencesHelper,
      isFaceIdForAll: isFaceForAll,
      isFaceForRegisterFace: isFaceForRegisterFace,
    );
  }

  Future<void> setFaceIDForAll(bool value) async {
    final sharedPreferencesHelper = state.sharedPreferencesHelper;
    if (sharedPreferencesHelper != null) {
      await sharedPreferencesHelper.setFaceIdForAll(value);
    }
    if (value) {
      await setFaceIDForRegisterFace(false);
    }
    state = state.copyWith(isFaceIdForAll: value);
  }

  Future<void> setFaceIDForRegisterFace(bool value) async {
    final sharedPreferencesHelper = state.sharedPreferencesHelper;
    if (sharedPreferencesHelper != null) {
      await sharedPreferencesHelper.setFaceIdForRegisterFace(value);
    }
    if (value) {
      await setFaceIDForAll(false);
    }
    state = state.copyWith(isFaceForRegisterFace: value);
  }

  void setInternetConnected(bool value) {
    state = state.copyWith(isInternetConnected: value);
  }

  void setErrorMessage(String value) {
    state = state.copyWith(errorMessage: value);
  }
}

final settingScreenStateProvider =
    StateNotifierProvider.autoDispose<SettingStateProvider, SettingScreenState>(
      (ref) {
        return SettingStateProvider();
      },
    );
