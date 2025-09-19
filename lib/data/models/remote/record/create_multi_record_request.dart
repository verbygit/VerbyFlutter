import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';

class CreateMultiRecordRequest {
  List<CreateRecordRequest>? records;

  CreateMultiRecordRequest({this.records});

  CreateMultiRecordRequest.fromJson(Map<String, dynamic> json) {
    if (json['records'] != null) {
      records = <CreateRecordRequest>[];
      json['records'].forEach((v) {
        records!.add(CreateRecordRequest.fromJson(v));
      });
    }
  }



  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (records != null) {
      data['records'] = records!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
