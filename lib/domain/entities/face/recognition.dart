class Recognition {
  final int id;
  final String name;
  final double distance;
  List<double> embedding;

  Recognition(this.id, this.name, this.distance, this.embedding);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'distance': distance,
      'embedding': embedding,
    };
  }

  factory Recognition.fromJson(Map<String, dynamic> json) {
    return Recognition(
      json['id'],
      json['name'],
      json['distance'],
      (json['embedding'] as List).cast<double>(),
    );
  }

  @override
  String toString() {
    return '[id: $id, name: $name, distance: ${distance.toStringAsFixed(2)}]';
  }
}