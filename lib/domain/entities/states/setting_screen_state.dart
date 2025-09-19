import 'package:verby_flutter/data/data_source/local/shared_preference_helper.dart';

class SettingScreenState {
  final String errorMessage;
  final String message;
  final bool isInternetConnected;
  final bool isFaceIdForAll;
  final bool isFaceForRegisterFace;
  final SharedPreferencesHelper? sharedPreferencesHelper;

  SettingScreenState({
    this.isInternetConnected = false,
    this.errorMessage = "",
    this.message = "",
    this.isFaceIdForAll = false,
    this.isFaceForRegisterFace = false,
    this.sharedPreferencesHelper
  });

  SettingScreenState copyWith({
    bool? isInternetConnected,
    bool? isFaceIdForAll,
    bool? isFaceForRegisterFace,
    String? errorMessage,
    String? message,
    SharedPreferencesHelper? sharedPreferencesHelper
  }) {
    return SettingScreenState(
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,
      isFaceIdForAll: isFaceIdForAll ?? this.isFaceIdForAll,
      isFaceForRegisterFace: isFaceForRegisterFace ?? this.isFaceForRegisterFace,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      sharedPreferencesHelper: sharedPreferencesHelper ?? this.sharedPreferencesHelper,
    );
  }
}
