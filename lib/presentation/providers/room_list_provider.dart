import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/models/remote/calender/depa_restant.dart';

import '../../data/models/local/depa_restant_model.dart';
import '../../domain/entities/states/room_list_screen_state.dart';

class RoomListProviderNotifier
    extends StateNotifier<RoomListScreenState> {
  RoomListProviderNotifier()
    : super(
        RoomListScreenState(
          rooms:rooms ,
          filterRooms: rooms
        ),
      );

  void filterItems(String query) {
    print("room checklist provider:  query ===> $query");
    final List<DepaRestant>? filteredItems;
    if (query.isNotEmpty) {
      filteredItems = state.rooms?.where((item) {
        return item.name?.toLowerCase().contains(query) == true;
      }).toList();
    } else {
      filteredItems = state.rooms;
    }
    state = state.copyWith(filterRooms: filteredItems ?? []);
  }
}

final roomlistProvider =
    StateNotifierProvider<
      RoomListProviderNotifier,
      RoomListScreenState
    >((ref) {
      return RoomListProviderNotifier();
    });

final rooms = [
  DepaRestant(
    id: 1,
    name: "room1",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(id: 2, name: "room2", category: 1, extra: 1),
  DepaRestant(
    id: 3,
    name: "room3",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),

  DepaRestant(id: 4, name: "room4", category: 1, status: 1),

  DepaRestant(id: 5, name: "room5", category: 1, status: 1),

  DepaRestant(id: 6, name: "room6", status: 1),

  DepaRestant(
    id: 7,
    name: "room7",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(
    id: 8,
    name: "room8",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(
    id: 9,
    name: "room9",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(
    id: 10,
    name: "room10",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(
    id: 11,
    name: "room11",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(
    id: 12,
    name: "room12",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(
    id: 13,
    name: "room13",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(
    id: 14,
    name: "room14",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
  DepaRestant(
    id: 15,
    name: "room15",
    category: 1,
    extra: 1,
    volunteer: 1,
    status: 1,
  ),
];