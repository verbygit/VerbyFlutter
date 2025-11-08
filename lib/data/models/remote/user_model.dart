class UserModel {
  int? id;
  String? email;
  String? deviceName;
  int? deviceID;

  UserModel({this.id, this.email,this.deviceID,this.deviceName});

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    deviceName = json['deviceName'];
    deviceID = json['deviceID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['deviceName'] = deviceName;
    data['deviceID'] = deviceID;
    return data;
  }
}