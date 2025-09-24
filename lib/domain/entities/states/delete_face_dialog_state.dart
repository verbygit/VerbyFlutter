
class DeleteFaceDialogState {
  final bool isLoading;
  final String? error;

  DeleteFaceDialogState({this.isLoading = false, this.error = ""});

  DeleteFaceDialogState copyWith({bool? isLoading, String? error}) {
    return DeleteFaceDialogState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
