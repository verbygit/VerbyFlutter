import '../../local/depa_restant_model.dart';

class RestantRecord {
  int? roomId;
  int? extra;
  int? status;
  int? volunteer;

  RestantRecord({this.roomId, this.extra, this.volunteer, this.status});

  RestantRecord.fromDepaRestantModel(DepaRestantModel? depaRestantModel) {
    roomId = depaRestantModel?.id ?? 0;
    extra = 0;
    volunteer = depaRestantModel?.volunteer ?? -1;
    status = depaRestantModel?.status;
  }

  RestantRecord.fromJson(Map<String, dynamic> json) {
    roomId = json['room_id'];
    extra = json['extra'];
    volunteer = json['volunteer'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['room_id'] = roomId;
    data['extra'] = extra;
    if (volunteer != -1) {
      data['volunteer'] = volunteer;
    }
    data['status'] = status;
    return data;
  }
}
