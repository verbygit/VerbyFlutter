import 'package:verby_flutter/data/models/remote/record/restant_record.dart';
import 'depa_record.dart';

class CreateRecordRequest {
  int? employee;
  int? device;
  int? action;
  int? perform;
  int? identity;
  String? time;
  List<DepaRecord>? depa;
  List<RestantRecord>? restant;

  CreateRecordRequest({
    this.employee,
    this.device,
    this.action,
    this.perform,
    this.identity,
    this.time,
    this.depa,
    this.restant,
  });

  CreateRecordRequest.fromJson(Map<String, dynamic> json) {
    employee = json['employee'];
    device = json['device'];
    action = json['action'];
    perform = json['perform'];
    identity = json['identity'];
    time = json['time'];
    if (json['depa'] != null) {
      depa = <DepaRecord>[];
      json['depa'].forEach((v) {
        depa!.add(DepaRecord.fromJson(v));
      });
    }
    if (json['restant'] != null) {
      restant = <RestantRecord>[];
      json['restant'].forEach((v) {
        restant!.add(RestantRecord.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employee'] = employee;
    data['device'] = device;
    data['action'] = action;
    data['perform'] = perform;
    data['identity'] = identity;
    data['time'] = time;
    if (depa != null) {
      data['depa'] = depa!.map((v) => v.toJson()).toList();
    }
    if (restant != null) {
      data['restant'] = restant!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
