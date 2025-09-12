import 'package:verby_flutter/data/models/local/depa_restant_model.dart';

class DepaRecord {
  int? roomId;
  int? extra;
  int? volunteer;
  int? status;

  DepaRecord({this.roomId, this.extra, this.volunteer, this.status});

  DepaRecord.fromDepaRestantModel(DepaRestantModel? depaRestantModel) {
    roomId = depaRestantModel?.id ?? 0;
    extra = 0;
    volunteer = depaRestantModel?.volunteer;
    status = depaRestantModel?.status;
  }

  DepaRecord.fromJson(Map<String, dynamic> json) {
    roomId = json['room_id'];
    extra = json['extra'];
    volunteer = json['volunteer'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['room_id'] = roomId;
    data['extra'] = extra;
    if (volunteer != null && volunteer != -1) {
      data['volunteer'] = volunteer;
    }
    data['status'] = status;
    return data;
  }
}
