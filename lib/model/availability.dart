import 'package:aves/model/settings/enums/map_style.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves_map/aves_map.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

abstract class AvesAvailability {
  void onResume();

  Future<bool> get isConnected;

  Future<bool> get canLocatePlaces;

  List<EntryMapStyle> get mapStyles;
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
  Future<bool> get canLocatePlaces async => mobileServices.isServiceAvailable && await isConnected;

  @override
  List<EntryMapStyle> get mapStyles => [
        ...mobileServices.mapStyles,
        ...EntryMapStyle.values.where((v) => !v.needMobileService),
      ];
}
