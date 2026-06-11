import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  final _controller = StreamController<bool>.broadcast();

  bool get isOnline => _isOnline;
  bool get isOffline => !_isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void initialize() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      if (wasOnline != _isOnline) {
        _controller.add(_isOnline);
      }
    });

    _connectivity.checkConnectivity().then((results) {
      final wasOnline = _isOnline;
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      if (wasOnline != _isOnline) {
        _controller.add(_isOnline);
      }
    });
  }

  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      return _isOnline;
    } catch (e) {
      debugPrint('Connectivity check error: $e');
      return _isOnline;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
