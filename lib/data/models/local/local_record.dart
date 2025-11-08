import 'package:verby_flutter/data/models/remote/record/CreateRecordRequest.dart';

class LocalRecord extends CreateRecordRequest {
  final int id;

  LocalRecord({required this.id, required CreateRecordRequest request})
    : super(
        employee: request.employee,
        device: request.device,
        action: request.action,
        perform: request.perform,
        identity: request.identity,
        time: request.time,
        depa: request.depa,
        restant: request.restant,
      );

  factory LocalRecord.fromJson(Map<String, dynamic> json) {
    return LocalRecord(
      id: json['id'],
      request: CreateRecordRequest.fromJson(json),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['id'] = id;
    return data;
  }
}
