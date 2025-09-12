import 'package:verby_flutter/data/models/remote/calender/depa_restant.dart';

class CalenderResponse {
  List<DepaRestant>? depa;
  List<DepaRestant>? restant;

  CalenderResponse({this.depa, this.restant});

  CalenderResponse.fromJson(Map<String, dynamic> json) {
    if (json['depa'] != null) {
      depa = <DepaRestant>[];
      json['depa'].forEach((v) {
        depa!.add(DepaRestant.fromJson(v));
      });
    }
    if (json['restant'] != null) {
      restant = <DepaRestant>[];
      json['restant'].forEach((v) {
        restant!.add(DepaRestant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (depa != null) {
      data['depa'] = depa!.map((v) => v.toJson()).toList();
    }
    if (restant != null) {
      data['restant'] = restant!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
