import 'package:aves/model/device.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_api_availability/google_api_availability.dart';

abstract class AvesAvailability {
  void onResume();

  Future<bool> get isConnected;

  Future<bool> get hasPlayServices;

  Future<bool> get canLocatePlaces;

  Future<bool> get canUseGoogleMaps;
}

class LiveAvesAvailability implements AvesAvailability {
  bool? _isConnected, _hasPlayServices;

  LiveAvesAvailability() {
    Connectivity().onConnectivityChanged.listen(_updateConnectivityFromResult);
  }

  @override
  void onResume() => _isConnected = null;

  @override
  Future<bool> get isConnected async {
    if (_isConnected != null) return SynchronousFuture(_isConnected!);
    final result = await (Connectivity().checkConnectivity());
    _updateConnectivityFromResult(result);
    return _isConnected!;
  }

  void _updateConnectivityFromResult(ConnectivityResult result) {
    final newValue = result != ConnectivityResult.none;
    if (_isConnected != newValue) {
      _isConnected = newValue;
      debugPrint('Device is connected=$_isConnected');
    }
  }

  @override
  Future<bool> get hasPlayServices async {
    if (_hasPlayServices != null) return SynchronousFuture(_hasPlayServices!);
    final result = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
    _hasPlayServices = result == GooglePlayServicesAvailability.success;
    debugPrint('Device has Play Services=$_hasPlayServices');
    return _hasPlayServices!;
  }

  // local geocoding with `geocoder` requires Play Services
  @override
  Future<bool> get canLocatePlaces => Future.wait<bool>([isConnected, hasPlayServices]).then((results) => results.every((result) => result));

  @override
  Future<bool> get canUseGoogleMaps async => device.canRenderGoogleMaps && await hasPlayServices;
}
