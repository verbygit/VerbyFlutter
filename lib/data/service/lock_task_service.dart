import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class LockTaskService {
  static final LockTaskService _instance = LockTaskService._internal();
  factory LockTaskService() => _instance;
  LockTaskService._internal();

  bool _isInLockTaskMode = false;
  Timer? _checkTimer;
  static const MethodChannel _channel = MethodChannel('lock_task_service');

  /// Get the current lock task mode status
  bool get isInLockTaskMode => _isInLockTaskMode;

  /// Initialize the lock task service
  Future<void> initialize() async {
    try {
      // For now, just initialize the service
      // In a real implementation, you would check device capabilities here
      print('Lock task service initialized');
    } catch (e) {
      print('Error initializing lock task service: $e');
    }
  }

  /// Start lock task mode (kiosk mode)
  Future<bool> startLockTask() async {
    try {
      if (Platform.isAndroid) {
        // Try to use Android's lock task mode
        final result = await _channel.invokeMethod('startLockTask');
        if (result == true) {
          _isInLockTaskMode = true;
          // Only start timer if this is a kiosk mode app
          // _startCheckTimer(); // Commented out to prevent infinite loops
          return true;
        }
      } else if (Platform.isIOS) {
        // iOS doesn't support programmatic lock task
        // Show user instructions for Guided Access
        _isInLockTaskMode = true;
        print('iOS: Lock task not supported. User must enable Guided Access manually.');
        return true;
      }
      
      // If Android method fails, just set the state
      _isInLockTaskMode = true;
      print('Lock task mode activated (UI only)');
      return true;
    } catch (e) {
      print('Error starting lock task: $e');
      // Even if native method fails, we can still provide UI feedback
      _isInLockTaskMode = true;
      return true;
    }
  }

  /// Stop lock task mode
  Future<bool> stopLockTask() async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('stopLockTask');
        if (result == true) {
          _isInLockTaskMode = false;
          _stopCheckTimer();
          return true;
        }
      }
      
      _isInLockTaskMode = false;
      _stopCheckTimer();
      print('Lock task mode deactivated');
      return true;
    } catch (e) {
      print('Error stopping lock task: $e');
      _isInLockTaskMode = false;
      _stopCheckTimer();
      return true;
    }
  }

  /// Force stop lock task mode (for manual user action)
  Future<bool> forceStopLockTask() async {
    _isInLockTaskMode = false;
    _stopCheckTimer();
    print('Lock task mode force stopped by user');
    return true;
  }

  /// Enable timer-based monitoring (for kiosk mode apps)
  void enableTimerMonitoring() {
    if (_isInLockTaskMode) {
      _startCheckTimer();
      print('Timer monitoring enabled for lock task');
    }
  }

  /// Disable timer-based monitoring
  void disableTimerMonitoring() {
    _stopCheckTimer();
    print('Timer monitoring disabled');
  }

  /// Check if lock task is still active
  Future<bool> checkLockTask() async {
    try {
      if (Platform.isAndroid) {
        final result = await _channel.invokeMethod('checkLockTask');
        if (result == false && _isInLockTaskMode) {
          // Lock task was disabled, update our state but don't restart automatically
          // This prevents infinite loops when the user manually exits lock task mode
          _isInLockTaskMode = false;
          _stopCheckTimer();
          print('Lock task was manually disabled by user');
        }
        return result == true;
      } else if (Platform.isIOS) {
        // iOS doesn't support programmatic lock task checking
        return _isInLockTaskMode;
      }
      return _isInLockTaskMode;
    } catch (e) {
      print('Error checking lock task: $e');
      return _isInLockTaskMode;
    }
  }

  /// Start the periodic check timer
  void _startCheckTimer() {
    _stopCheckTimer();
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      await checkLockTask();
    });
  }

  /// Stop the periodic check timer
  void _stopCheckTimer() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  /// Dispose resources
  void dispose() {
    _stopCheckTimer();
  }
}
