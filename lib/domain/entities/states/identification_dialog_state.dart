import 'package:verby_flutter/data/models/remote/login_response_model.dart';

class IdentificationDialogState {
  final bool isLoading;
  final String? error;

  IdentificationDialogState({this.isLoading = false, this.error = ""});

  IdentificationDialogState copyWith({bool? isLoading, String? error}) {
    return IdentificationDialogState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
