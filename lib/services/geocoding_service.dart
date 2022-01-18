import 'dart:async';
import 'dart:ui';

import 'package:aves/services/common/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const platform = MethodChannel('deckers.thibault/aves/geocoding');

  // geocoding requires Google Play Services
  static Future<List<Address>> getAddress(LatLng coordinates, Locale locale) async {
    try {
      final result = await platform.invokeMethod('getAddress', <String, dynamic>{
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'locale': locale.toString(),
        // we only really need one address, but sometimes the native geocoder
        // returns nothing with `maxResults` of 1, but succeeds with `maxResults` of 2+
        'maxResults': 2,
      });
      return (result as List).cast<Map>().map((map) => Address.fromMap(map)).toList();
    } on PlatformException catch (e, stack) {
      if (e.code != 'getAddress-empty' && e.code != 'getAddress-network') {
        await reportService.recordError(e, stack);
      }
    }
    return [];
  }
}

@immutable
class Address {
  final String? addressLine, adminArea, countryCode, countryName, featureName, locality, postalCode, subAdminArea, subLocality, subThoroughfare, thoroughfare;

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
