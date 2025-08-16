import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SharedPreferencesHelper {
  final SharedPreferences _sharedPreferences;
  final String LEVEL_KEY = "level";
  final String STYLE_KEY = "style";
  final String QUESTION_PROGRESS_KEY = "question_progress";
  final String SWITCH_INDICES_KEY = "indices";
  final String USER_DETAILS_KEY = "userDetails";
  final bool isUpdated;

  SharedPreferencesHelper(this._sharedPreferences, this.isUpdated);

  Future<void> saveString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
  }

  bool? getBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  Future<void> clear() async {
    await _sharedPreferences.clear();
  }

  Future<void> remove(String key) async {
    await _sharedPreferences.remove(key);
  }

  // Future<void> saveUser(User user) async {
  //   // Convert User to UserModel to use toJson
  //   final userModel = UserModel(
  //     firstName: user.firstName,
  //     lastName: user.lastName,
  //     //dob: user.dob,
  //     email: user.email,
  //   );
  //   final userJson = jsonEncode(userModel.toJson());
  //   await _sharedPreferences.setString(USER_DETAILS_KEY, userJson);
  // }
  //
  // User? getUser() {
  //   final userJson = _sharedPreferences.getString(USER_DETAILS_KEY);
  //   if (userJson != null) {
  //     final Map<String, dynamic> json = jsonDecode(userJson);
  //     // Use UserModel's fromJson method to create a User object
  //     return UserModel.fromJson(json);
  //   }
  //   return null;
  // }


}
