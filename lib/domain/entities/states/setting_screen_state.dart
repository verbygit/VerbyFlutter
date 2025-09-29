import 'package:verby_flutter/data/data_source/local/shared_preference_helper.dart';
import 'package:verby_flutter/data/models/local/face_model.dart';

class SettingScreenState {
  final String errorMessage;
  final String message;
  final bool isLoading;
  final bool isInternetConnected;
  final bool isFaceIdForAll;
  final bool isFaceForRegisterFace;
  final double faceVerificationTries;
  final List<FaceModel>? faces;
  final SharedPreferencesHelper? sharedPreferencesHelper;

  SettingScreenState({
    this.isInternetConnected = false,
    this.isLoading = false,
    this.errorMessage = "",
    this.message = "",
    this.isFaceIdForAll = false,
    this.isFaceForRegisterFace = false,
    this.faces,
    this.sharedPreferencesHelper,
    this.faceVerificationTries=6,
  });

  SettingScreenState copyWith({
    bool? isInternetConnected,
    bool? isFaceIdForAll,
    bool? isFaceForRegisterFace,
    bool? isLoading,
    String? errorMessage,
    String? message,
    double? faceVerificationTries,
    SharedPreferencesHelper? sharedPreferencesHelper,
    List<FaceModel>? faces,
  }) {
    return SettingScreenState(
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,
      isFaceIdForAll: isFaceIdForAll ?? this.isFaceIdForAll,
      isLoading: isLoading ?? this.isLoading,
      isFaceForRegisterFace:
          isFaceForRegisterFace ?? this.isFaceForRegisterFace,
      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      sharedPreferencesHelper:
          sharedPreferencesHelper ?? this.sharedPreferencesHelper,
      faces: faces ?? this.faces,
      faceVerificationTries: faceVerificationTries ?? this.faceVerificationTries,
    );
  }
}
