import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/service/lock_task_service.dart';

class LockTaskState {
  final bool isLocked;
  final bool isLoading;
  final String? errorMessage;

  const LockTaskState({
    this.isLocked = false,
    this.isLoading = false,
    this.errorMessage,
  });

  LockTaskState copyWith({
    bool? isLocked,
    bool? isLoading,
    String? errorMessage,
  }) {
    return LockTaskState(
      isLocked: isLocked ?? this.isLocked,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LockTaskNotifier extends StateNotifier<LockTaskState> {
  final LockTaskService _lockTaskService;

  LockTaskNotifier(this._lockTaskService) : super(const LockTaskState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _lockTaskService.initialize();
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to initialize lock task service: $e',
      );
    }
  }

  Future<void> startLockTask() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _lockTaskService.startLockTask();
      if (success) {
        state = state.copyWith(
          isLocked: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to start lock task',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error starting lock task: $e',
      );
    }
  }

  Future<void> stopLockTask() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _lockTaskService.stopLockTask();
      if (success) {
        state = state.copyWith(
          isLocked: false,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to stop lock task',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error stopping lock task: $e',
      );
    }
  }

  Future<void> toggleLockTask() async {
    if (state.isLocked) {
      // Use force stop to prevent automatic restart
      await _lockTaskService.forceStopLockTask();
      state = state.copyWith(
        isLocked: false,
        isLoading: false,
      );
    } else {
      await startLockTask();
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

final lockTaskServiceProvider = Provider<LockTaskService>((ref) {
  return LockTaskService();
});

final lockTaskProvider = StateNotifierProvider<LockTaskNotifier, LockTaskState>((ref) {
  final lockTaskService = ref.watch(lockTaskServiceProvider);
  return LockTaskNotifier(lockTaskService);
});
