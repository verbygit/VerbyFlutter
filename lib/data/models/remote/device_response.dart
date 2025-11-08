class DeviceResponse {
  final int id;
  final String name;

  DeviceResponse({required this.id, required this.name});

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    return DeviceResponse(id: json['id'] as int, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
