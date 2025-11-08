import 'dart:convert';

class Plan {
  int employeeId;
  List<String> time;

  Plan({this.employeeId = -1, this.time = const []});

  factory Plan.fromJson(Map<String, dynamic> map) {
    return Plan(
      employeeId: map['employeeId'] is int
          ? map['employeeId']
          : int.tryParse(map['employeeId'].toString()) ?? -1,
      time: (map['time'] is String)
          ? (jsonDecode(map['time']) as List).cast<String>()
          : (map['time'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'time': jsonEncode(time),
    };
  }
}
