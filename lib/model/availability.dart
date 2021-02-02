import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:google_api_availability/google_api_availability.dart';

final AvesAvailability availability = AvesAvailability._private();

class AvesAvailability {
  bool _isConnected, _hasPlayServices;

  AvesAvailability._private() {
    Connectivity().onConnectivityChanged.listen(_updateConnectivityFromResult);
  }

  void onResume() => _isConnected = null;

  Future<bool> get isConnected async {
    if (_isConnected != null) return SynchronousFuture(_isConnected);
    final result = await (Connectivity().checkConnectivity());
    _updateConnectivityFromResult(result);
    return _isConnected;
  }

  void _updateConnectivityFromResult(ConnectivityResult result) {
    final newValue = result != ConnectivityResult.none;
    if (_isConnected != newValue) {
      _isConnected = newValue;
      debugPrint('Device is connected=$_isConnected');
    }
  }

  Future<bool> get hasPlayServices async {
    if (_hasPlayServices != null) return SynchronousFuture(_hasPlayServices);
    final result = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
    _hasPlayServices = result == GooglePlayServicesAvailability.success;
    debugPrint('Device has Play Services=$_hasPlayServices');
    return _hasPlayServices;
  }

  // local geolocation with `geocoder` requires Play Services
  Future<bool> get canGeolocate => Future.wait<bool>([isConnected, hasPlayServices]).then((results) => results.every((result) => result));
}
