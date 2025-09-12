import 'last_record.dart';

class RecordResponse {
  List<LastRecords>? lastRecords;

  RecordResponse({this.lastRecords});

  RecordResponse.fromJson(Map<String, dynamic> json) {
    if (json['last_records'] != null) {
      lastRecords = <LastRecords>[];
      json['last_records'].forEach((v) {
        lastRecords!.add(LastRecords.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (lastRecords != null) {
      data['last_records'] = lastRecords!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}