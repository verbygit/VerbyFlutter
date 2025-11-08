import 'dart:convert';
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
      // Handle both string (from database) and list (from API) formats
      if (json['depa'] is String) {
        // Parse JSON string from database
        final List<dynamic> depaList = jsonDecode(json['depa']);
        depa = depaList.map((v) => DepaRecord.fromJson(v)).toList();
      } else {
        // Handle list from API
        depa = <DepaRecord>[];
        json['depa'].forEach((v) {
          depa!.add(DepaRecord.fromJson(v));
        });
      }
    }
    if (json['restant'] != null) {
      // Handle both string (from database) and list (from API) formats
      if (json['restant'] is String) {
        // Parse JSON string from database
        final List<dynamic> restantList = jsonDecode(json['restant']);
        restant = restantList.map((v) => RestantRecord.fromJson(v)).toList();
      } else {
        // Handle list from API
        restant = <RestantRecord>[];
        json['restant'].forEach((v) {
          restant!.add(RestantRecord.fromJson(v));
        });
      }
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

  /// Converts the object to a JSON map suitable for database storage
  /// This method serializes complex objects (depa, restant) to JSON strings
  Map<String, dynamic> toDatabaseJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employee'] = employee;
    data['device'] = device;
    data['action'] = action;
    data['perform'] = perform;
    data['identity'] = identity;
    data['time'] = time;
    if (depa != null) {
      data['depa'] = jsonEncode(depa!.map((v) => v.toJson()).toList());
    }
    if (restant != null) {
      data['restant'] = jsonEncode(restant!.map((v) => v.toJson()).toList());
    }
    return data;
  }
}
