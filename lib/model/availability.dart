import 'package:aves/model/device.dart';
import 'package:aves_services_platform/aves_services_platform.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

abstract class AvesAvailability {
  void onResume();

  Future<bool> get isConnected;

  Future<bool> get canLocatePlaces;

  Future<bool> get canUseDeviceMaps;
}

class LiveAvesAvailability implements AvesAvailability {
  bool? _isConnected;

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

  // local geocoding with `geocoder` seems to require Google Play Services
  // what about devices with Huawei Mobile Services?
  @override
  Future<bool> get canLocatePlaces => Future.wait<bool>([
        isConnected,
        PlatformMobileServices().isServiceAvailable(),
      ]).then((results) => results.every((result) => result));

  @override
  Future<bool> get canUseDeviceMaps async => device.canRenderGoogleMaps && await PlatformMobileServices().isServiceAvailable();
}
