class Employee {
  int? id;
  String? name;
  String? surname;
  int? role;
  String? pin;
  // String? card;
  // Null? camera;
  int? apiMonitoring;
  String? fullname;

  Employee({
    this.id,
    this.name,
    this.surname,
    this.role,
    this.pin,
    // this.card,
    // this.camera,
    this.apiMonitoring,
    this.fullname,
  });

  Employee.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    surname = json['surname'];
    role = json['role'];
    pin = json['pin'];
    // card = json['card'];
    // camera = json['camera'];
    apiMonitoring = json['api_monitoring'];
    fullname = json['fullname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['surname'] = this.surname;
    data['role'] = this.role;
    data['pin'] = this.pin;
    // data['card'] = this.card;
    // data['camera'] = this.camera;
    data['api_monitoring'] = this.apiMonitoring;
    data['fullname'] = this.fullname;
    return data;
  }
}
