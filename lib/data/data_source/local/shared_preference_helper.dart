import 'dart:convert';
import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:verby_flutter/data/models/remote/login_response_model.dart';
import 'package:verby_flutter/data/models/remote/user_model.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SharedPreferencesHelper {
  final SharedPreferences _sharedPreferences;
  final String LEVEL_KEY = "level";
  final String STYLE_KEY = "style";
  final String QUESTION_PROGRESS_KEY = "question_progress";
  final String SWITCH_INDICES_KEY = "indices";
  final String USER_DETAILS_KEY = "user_details";
  static final String DEVICE_ID_KEY = "device_id";
  static final String TOKEN_KEY = "token";
  final String USER_PASSWORD = "user_password";
  final String FACE_TRIES = "face_tries";
  final String IS_FACE_ID_FOR_ALL_KEY = "face_id_for_all";
  final String IS_FACE_ID_FOR_REGISTER_FACE_KEY = "face_id_for_register_face";
  final key = encrypt.Key.fromUtf8(
    'jetverbyverbiccajetverbyverbicca',
  ); // 32 characters for AES-256
  final iv = encrypt.IV.fromLength(16); // AES requires 16 bytes for IV

  SharedPreferencesHelper(this._sharedPreferences);

  Future<void> saveString(String key, String value) async {
    await _sharedPreferences.setString(key, value);
  }

  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _sharedPreferences.setInt(key, value);
  }

  int? getInt(String key) {
    return _sharedPreferences.getInt(key);
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

  Future<void> setFaceVerificationTries(double value) async {
    await _sharedPreferences.setDouble(FACE_TRIES, value);
  }

  Future<double?> getFaceTries() async =>
      _sharedPreferences.getDouble(FACE_TRIES);


  Future<void> setFaceIdForAll(bool value) async {
    await _sharedPreferences.setBool(IS_FACE_ID_FOR_ALL_KEY, value);
  }

  Future<bool?> isFaceIdForAll() async =>
      _sharedPreferences.getBool(IS_FACE_ID_FOR_ALL_KEY);

  Future<void> setFaceIdForRegisterFace(bool value) async {
    await _sharedPreferences.setBool(IS_FACE_ID_FOR_REGISTER_FACE_KEY, value);
  }

  Future<bool?> isFaceIdForRegisterFace() async =>
      _sharedPreferences.getBool(IS_FACE_ID_FOR_REGISTER_FACE_KEY);

  Future<String?> getToken() async => _sharedPreferences.getString(TOKEN_KEY);

  Future<void> setToken(String token) async =>
      _sharedPreferences.setString(TOKEN_KEY, token);

  Future<void> saveUser(
    LoginResponseModel loginResponse,
    String password,
  ) async {
    final user = UserModel(
      id: loginResponse.user?.id,
      email: loginResponse.user?.email,
      deviceID: loginResponse.deviceId,
    );
    final userJson = jsonEncode(user.toJson() ?? "");
    await _sharedPreferences.setString(USER_DETAILS_KEY, userJson);
    await _sharedPreferences.setInt(
      DEVICE_ID_KEY,
      loginResponse.deviceId ?? -1,
    );
    await _sharedPreferences.setString(TOKEN_KEY, loginResponse.token ?? "");
    savePassword(password);
  }

  UserModel? getUser() {
    final userJson = _sharedPreferences.getString(USER_DETAILS_KEY);
    if (userJson != null) {
      final Map<String, dynamic> json = jsonDecode(userJson);
      return UserModel.fromJson(json);
    }
    return null;
  }

  // Encrypt the password
  String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  // Decrypt the password
  String decryptPassword(String encryptedPassword) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
  }

  // Save encrypted password in SharedPreferences
  Future<void> savePassword(String password) async {
    await _sharedPreferences.setString(USER_PASSWORD, password);
  }

  // Get decrypted password from SharedPreferences
  Future<String?> getPassword() async {
    return _sharedPreferences.getString(USER_PASSWORD);
  }
}
