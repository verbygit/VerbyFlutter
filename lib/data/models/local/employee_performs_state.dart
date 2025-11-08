class EmployeePerformState {
  int id;
  bool isStewarding;
  bool isMaintenance;
  bool isRoomControl;
  bool isRoomCleaning;
  bool isBuro;

  // Constructor
  EmployeePerformState({
    this.id = -1,
    this.isStewarding = false,
    this.isMaintenance = false,
    this.isRoomControl = false,
    this.isRoomCleaning = false,
    this.isBuro = false,
  });

  // Factory method to create an instance from a JSON object
  factory EmployeePerformState.fromJson(Map<String, dynamic> json) {
    return EmployeePerformState(
      id: int.parse(json['id']),
      isStewarding: json['isStewarding']==1? true: false,
      isMaintenance: json['isMaintenance']==1? true: false,
      isRoomControl: json['isRoomControl']==1? true: false,
      isRoomCleaning: json['isRoomCleaning']==1? true: false,
      isBuro: json['isBuro']==1? true: false,
    );
  }

  // Method to convert the instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isStewarding': isStewarding?1:0,
      'isMaintenance': isMaintenance?1:0,
      'isRoomControl': isRoomControl?1:0,
      'isRoomCleaning': isRoomCleaning?1:0,
      'isBuro': isBuro?1:0,
    };
  }
}
