class EmployeeActionState {
  int id;
  bool hadAPause;
  bool checkedIn;
  bool checkedOut;
  bool pausedIn;
  bool pausedOut;
  String lastActionTime;
  String checkInTime;

  EmployeeActionState({
    this.id = -1,
    this.hadAPause = true,
    this.checkedIn = true,
    this.checkedOut = true,
    this.pausedIn = true,
    this.pausedOut = true,
    this.lastActionTime = "",
    this.checkInTime = "",
  });

  factory EmployeeActionState.fromJson(Map<String, dynamic> map) {
    return EmployeeActionState(
      id: int.parse(map['id']),
      hadAPause: map['hadAPause'] == 1 ? true : false,
      checkedIn: map['checkedIn'] == 1 ? true : false,
      checkedOut: map['checkedOut'] == 1 ? true : false,
      pausedIn: map['pausedIn'] == 1 ? true : false,
      pausedOut: map['pausedOut'] == 1 ? true : false,
      lastActionTime: map['lastActionTime'],
      checkInTime: map['checkInTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hadAPause': hadAPause?1:0,
      'checkedIn': checkedIn?1:0,
      'checkedOut': checkedOut?1:0,
      'pausedIn': pausedIn?1:0,
      'pausedOut': pausedOut?1:0,
      'lastActionTime': lastActionTime,
      'checkInTime': checkInTime,
    };
  }
}
