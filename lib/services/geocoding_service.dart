import 'dart:async';

import 'package:aves/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const platform = MethodChannel('deckers.thibault/aves/geocoding');

  // geocoding requires Google Play Services
  static Future<List<Address>> getAddress(LatLng coordinates, String locale) async {
    try {
      final result = await platform.invokeMethod('getAddress', <String, dynamic>{
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'locale': locale,
        // we only really need one address, but sometimes the native geocoder
        // returns nothing with `maxResults` of 1, but succeeds with `maxResults` of 2+
        'maxResults': 2,
      });
      return (result as List).cast<Map>().map((map) => Address.fromMap(map)).toList();
    } on PlatformException catch (e) {
      await reportService.recordChannelError('getAddress', e);
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
