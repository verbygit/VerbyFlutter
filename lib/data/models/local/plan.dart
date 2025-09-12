class Plan {
  int employeeId;
  String time;

  Plan({this.employeeId = -1, this.time = ""});

  factory Plan.fromJson(Map<String, dynamic> map) {
    return Plan(employeeId: int.parse(map['employeeId']), time: map['time']);
  }

  Map<String, dynamic> toJson() {
    return {'employeeId': employeeId, 'time': time};
  }
}
