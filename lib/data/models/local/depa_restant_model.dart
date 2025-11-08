import 'package:verby_flutter/domain/entities/room_status.dart';

import '../remote/calender/depa_restant.dart';

class DepaRestantModel extends DepaRestant {
  final String employeeId;
  final bool isDepa;

  DepaRestantModel(this.employeeId, this.isDepa, DepaRestant depaRestant)
    : super(
        id: depaRestant.id,
        name: depaRestant.name,
        category: depaRestant.category,
        extra: depaRestant.extra,
        status: depaRestant.status,
      );

  factory DepaRestantModel.fromJson(Map<String, dynamic> json) {
    return DepaRestantModel(
      json['employeeId'],
      json['isDepa'] == 1 ? true : false,
      DepaRestant.fromJson(json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data['employeeId'] = employeeId;
    data['isDepa'] = isDepa ? 1 : 0;
    return data;
  }
}
