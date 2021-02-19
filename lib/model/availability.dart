import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:package_info/package_info.dart';
import 'package:version/version.dart';

final AvesAvailability availability = AvesAvailability._private();

class AvesAvailability {
  bool _isConnected, _hasPlayServices, _isNewVersionAvailable;

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
  Future<bool> get canLocatePlaces => Future.wait<bool>([isConnected, hasPlayServices]).then((results) => results.every((result) => result));

  Future<bool> get isNewVersionAvailable async {
    if (_isNewVersionAvailable != null) return SynchronousFuture(_isNewVersionAvailable);

    final now = DateTime.now();
    final dueDate = settings.lastVersionCheckDate.add(Durations.lastVersionCheckInterval);
    if (now.isBefore(dueDate)) {
      _isNewVersionAvailable = false;
      return SynchronousFuture(_isNewVersionAvailable);
    }

    if (!(await isConnected)) return false;

    Version version(String s) => Version.parse(s.replaceFirst('v', ''));
    final currentTag = (await PackageInfo.fromPlatform()).version;
    final latestTag = (await GitHub().repositories.getLatestRelease(RepositorySlug('deckerst', 'aves'))).tagName;
    _isNewVersionAvailable = version(latestTag) > version(currentTag);
    if (_isNewVersionAvailable) {
      debugPrint('Aves $latestTag is available on github');
    } else {
      debugPrint('Aves $currentTag is the latest version');
      settings.lastVersionCheckDate = now;
    }
    return _isNewVersionAvailable;
  }
}
