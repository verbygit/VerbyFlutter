import 'package:verby_flutter/data/models/remote/calender/depa_restant.dart';

class RoomListScreenState {
  final String errorMessage;
  final String message;
  final bool isInternetConnected;
  final List<DepaRestant>? rooms;
  final List<DepaRestant>? filterRooms;

  RoomListScreenState({
    this.isInternetConnected = false,
    this.errorMessage = "",
    this.message = "",
    this.rooms,
    this.filterRooms,
  });

  RoomListScreenState copyWith({
    bool? isInternetConnected,
    String? errorMessage,
    String? message,
    List<DepaRestant>? rooms,
    List<DepaRestant>? filterRooms,
  }) {
    return RoomListScreenState(
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,

      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      rooms: rooms ?? this.rooms,
      filterRooms: filterRooms ?? this.filterRooms,
    );
  }
}
