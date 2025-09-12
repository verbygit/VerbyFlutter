class UserModel {
  int? id;
  String? email;
  int? deviceID;

  UserModel({this.id, this.email,this.deviceID});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    deviceID = json['deviceID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['deviceID'] = deviceID;
    return data;
  }
}