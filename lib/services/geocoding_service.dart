import 'dart:async';
import 'dart:ui';

import 'package:aves/services/common/channel.dart';
import 'package:aves/services/common/channel_isolate.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

abstract class GeocodingService {
  Future<List<Address>> getAddress(LatLng coordinates, Locale locale);
}

// geocoding requires Google Play Services
class PlatformGeocodingService implements GeocodingService {
  final _channelIsolate = ChannelIsolate(AvesChannels.geocoding);

  @override
  Future<List<Address>> getAddress(LatLng coordinates, Locale locale) async {
    try {
      final result = await _channelIsolate.invokeMethod('getAddress', <String, Object?>{
        'latitude': coordinates.latitude,
        'longitude': coordinates.longitude,
        'localeLanguageTag': locale.toLanguageTag(),
        // we only really need one address, but sometimes the native geocoder
        // returns nothing with `maxResults` of 1, but succeeds with `maxResults` of 2+
        'maxResults': 2,
      });
      if (result != null) return (result as List).cast<Map>().map(Address.fromMap).toList();
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
