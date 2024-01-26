import 'dart:async';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const _platform = MethodChannel('deckers.thibault/aves/geocoding');

  // geocoding requires Google Play Services
  static Future<List<Address>> getAddress(LatLng coordinates, Locale locale) async {
    try {
      final result = await _platform.invokeMethod('getAddress', <String, dynamic>{
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'locale': locale.toString(),
        // we only really need one address, but sometimes the native geocoder
        // returns nothing with `maxResults` of 1, but succeeds with `maxResults` of 2+
        'maxResults': 2,
      });
      return (result as List).cast<Map>().map(Address.fromMap).toList();
    } on PlatformException catch (_) {
      // do not report
    }
    return [];
  }
}

@immutable
class Address extends Equatable {
  final String? addressLine, adminArea, countryCode, countryName, featureName, locality, postalCode, subAdminArea, subLocality, subThoroughfare, thoroughfare;

  @override
  List<Object?> get props => [addressLine, adminArea, countryCode, countryName, featureName, locality, postalCode, subAdminArea, subLocality, subThoroughfare, thoroughfare];

  const Address({
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

  factory Address.fromMap(Map map) => Address(
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
