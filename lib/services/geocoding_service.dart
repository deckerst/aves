import 'dart:async';

import 'package:aves/locale/aves_locale.dart';
import 'package:aves/services/common/channel.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

abstract class GeocodingService {
  Future<List<Address>> getAddress(LatLng coordinates, AvesLocale locale);
}

// geocoding requires Google Play Services
class PlatformGeocodingService implements GeocodingService {
  static const _channel = AvesMethodChannel(AvesChannels.geocoding);

  @override
  Future<List<Address>> getAddress(LatLng coordinates, AvesLocale locale) async {
    try {
      final result = await _channel.invokeMethod('getAddress', <String, Object?>{
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'localeLanguageTag': locale.languageTag,
        // we only really need one address, but sometimes the native geocoder
        // returns nothing with `maxResults` of 1, but succeeds with `maxResults` of 2+
        'maxResults': 2,
      });
      if (result != null) return (result as List).cast<Map>().map(Address.fromMap).toList();
    } on PlatformException catch (e) {
      // do not report
      debugPrint('$runtimeType failed to get address for coordinates=$coordinates with error=$e');
    }
    return [];
  }
}

@immutable
class Address extends Equatable {
  final String? addressLine, adminArea, countryCode, countryName, featureName, locality, postalCode, subAdminArea, subLocality, subThoroughfare, thoroughfare;

  @override
  List<Object?> get props => [addressLine, adminArea, countryCode, countryName, featureName, locality, postalCode, subAdminArea, subLocality, subThoroughfare, thoroughfare];

  const new({
    this.addressLine,
    this.adminArea,
    this.countryCode,
    this.countryName,
    this.featureName,
    this.locality,
    this.postalCode,
    this.subAdminArea,
    this.subLocality,
    this.subThoroughfare,
    this.thoroughfare,
  });

  factory fromMap(Map map) => Address(
    addressLine: map['addressLine'],
    adminArea: map['adminArea'],
    countryCode: map['countryCode'],
    countryName: map['countryName'],
    featureName: map['featureName'],
    locality: map['locality'],
    postalCode: map['postalCode'],
    subAdminArea: map['subAdminArea'],
    subLocality: map['subLocality'],
    subThoroughfare: map['subThoroughfare'],
    thoroughfare: map['thoroughfare'],
  );
}
