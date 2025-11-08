import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verby_flutter/data/models/remote/calender/depa_restant.dart';
import 'package:verby_flutter/domain/entities/states/room_checklist_screen_state.dart';

import '../../data/models/local/depa_restant_model.dart';
import '../../domain/entities/states/room_list_screen_state.dart';

class RoomCheckListProviderNotifier
    extends StateNotifier<RoomChecklistScreenState> {
  RoomCheckListProviderNotifier()
    : super(
        RoomChecklistScreenState(
          checkList: {
            "general_cleanliness": true,
            "sheet_fold": true,
            "towels": true,
            "WC": true,
            "missing_item": true,
          },
        ),
      );

  void checkItem(String itemName, bool value) {
    state = state.copyWith(checkList: {...state.checkList!, itemName: value});
  }

  void addImage(File file) {
    state.selectedImages!.add(file);
    state = state.copyWith(selectedImages: List.from(state.selectedImages!));
  }

  void removeImage(int index) {
    state.selectedImages!.removeAt(index);
    state = state.copyWith(selectedImages: List.from(state.selectedImages!));
  }
}

final roomChecklistProvider =
    StateNotifierProvider<
      RoomCheckListProviderNotifier,
      RoomChecklistScreenState
    >((ref) {
      return RoomCheckListProviderNotifier();
    });
