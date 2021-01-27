import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';

final AvesConnectivity connectivity = AvesConnectivity._private();

class AvesConnectivity {
  bool _isConnected;

  AvesConnectivity._private() {
    Connectivity().onConnectivityChanged.listen(_updateFromResult);
  }

  void onResume() => _isConnected = null;

  Future<bool> get isConnected async {
    if (_isConnected != null) return SynchronousFuture(_isConnected);
    final result = await (Connectivity().checkConnectivity());
    _updateFromResult(result);
    return _isConnected;
  }

  Future<bool> get canGeolocate => isConnected;

  void _updateFromResult(ConnectivityResult result) {
    _isConnected = result != ConnectivityResult.none;
    debugPrint('Device is connected=$_isConnected');
  }
}
