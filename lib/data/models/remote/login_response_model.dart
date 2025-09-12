import 'package:verby_flutter/data/models/remote/user_model.dart';

class LoginResponseModel {
  UserModel? user;
  String? token;
  int? deviceId;

  LoginResponseModel({this.user, this.token, this.deviceId});

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? UserModel.fromJson(json['user']) : null;
    token = json['token'];
    deviceId = json['device_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['token'] = token;
    data['device_id'] = deviceId;
    return data;
  }
}
