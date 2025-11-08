import 'dart:io';

import 'package:verby_flutter/data/models/remote/calender/depa_restant.dart';

class RoomChecklistScreenState {
  final String errorMessage;
  final String message;
  final bool isInternetConnected;
  final DepaRestant? room;
  final Map<String, bool>? checkList;
  final List<File>? selectedImages;

  RoomChecklistScreenState({
    this.isInternetConnected = false,
    this.errorMessage = "",
    this.message = "",
    this.room,
    this.checkList,
    this.selectedImages,
  });

  RoomChecklistScreenState copyWith({
    bool? isInternetConnected,
    String? errorMessage,
    String? message,
    DepaRestant? room,
    Map<String, bool>? checkList,
    List<File>? selectedImages

  }) {
    return RoomChecklistScreenState(
      isInternetConnected: isInternetConnected ?? this.isInternetConnected,

      errorMessage: errorMessage ?? this.errorMessage,
      message: message ?? this.message,
      room: room ?? this.room,
      checkList: checkList ?? this.checkList,
      selectedImages: selectedImages ?? this.selectedImages,
    );
  }
}
