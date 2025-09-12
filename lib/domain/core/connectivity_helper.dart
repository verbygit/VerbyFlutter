import 'dart:async';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Enum to represent connectivity status
enum ConnectivityStatus { online, offline }

class ConnectivityHelper {
  // Singleton instance
  static final ConnectivityHelper _instance = ConnectivityHelper._internal();
  factory ConnectivityHelper() => _instance;
  ConnectivityHelper._internal();

  // Stream controller for connectivity changes
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  Stream<ConnectivityStatus> get onStatusChange => _controller.stream;

  // Latest connectivity status
  ConnectivityStatus _currentStatus = ConnectivityStatus.offline;
  ConnectivityStatus get currentStatus => _currentStatus;

  // Subscription for internet status
  StreamSubscription<InternetConnectionStatus>? _internetSubscription;

  /// Initialize the helper
  Future<void> initialize() async {
    try {
      // Get initial status immediately
      final initialStatus = await InternetConnectionChecker.instance.connectionStatus;
      _updateStatus(initialStatus);
      
      // Listen for internet status changes
      _internetSubscription = InternetConnectionChecker.instance
          .onStatusChange
          .listen((InternetConnectionStatus status) {
        _updateStatus(status);
      });
    } catch (e) {
      print('ConnectivityHelper initialization error: $e');
      // Set default status if initialization fails
      _currentStatus = ConnectivityStatus.offline;
    }
  }


  /// Update status based on internet checker
  void _updateStatus(InternetConnectionStatus status) {
    ConnectivityStatus newStatus = status == InternetConnectionStatus.connected
        ? ConnectivityStatus.online
        : ConnectivityStatus.offline;

    if (newStatus != _currentStatus) {
      _currentStatus = newStatus;
      _controller.add(newStatus);
    }
  }

  /// Check if device is online
  bool get isConnected => _currentStatus == ConnectivityStatus.online;

  /// Dispose of subscriptions
  void dispose() {
    _internetSubscription?.cancel();
    _controller.close();
  }
}