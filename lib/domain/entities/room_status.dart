enum RoomStatus {
  DEFAULT(0),
  CLEANED(1),
  REDCARCD(2),
  VOLUNTER(3);

  final int roomStatus;

  const RoomStatus(this.roomStatus);

  int getRoomStatusValue() => roomStatus;

  static RoomStatus getRoomStatus(int roomStatus) {
    return RoomStatus.values.firstWhere((act) => act.roomStatus == roomStatus);
  }
}
