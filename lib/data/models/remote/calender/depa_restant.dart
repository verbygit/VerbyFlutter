class DepaRestant {
  int? id;
  String? name;
  int? category;
  int? extra;
  int? volunteer;
  int? status;

  DepaRestant({
    this.id,
    this.name,
    this.category,
    this.extra,
    this.volunteer,
    this.status,
  });

  DepaRestant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    category = json['category'];
    extra = json['extra'];
    volunteer = json['volunteer'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['category'] = category;
    data['extra'] = extra;
    if (volunteer != null && volunteer != 0) {
      data['volunteer'] = volunteer;
    }
    data['status'] = status;
    return data;
  }
}
