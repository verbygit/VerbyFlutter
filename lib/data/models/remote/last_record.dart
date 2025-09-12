class LastRecords {
  int? employeeId;
  int? deviceId;
  int? action;
  int? perform;
  int? identity;
  String? time;

  LastRecords({
    this.employeeId,
    this.deviceId,
    this.action,
    this.perform,
    this.identity,
    this.time,
  });

  LastRecords.fromJson(Map<String, dynamic> json) {
    employeeId = json['employee_id'];
    deviceId = json['device_id'];
    action = json['action'];
    perform = json['perform'];
    identity = json['identity'];
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['employee_id'] = employeeId;
    data['device_id'] = deviceId;
    data['action'] = action;
    data['perform'] = perform;
    data['identity'] = identity;
    data['time'] = time;
    return data;
  }
}
