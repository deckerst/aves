import 'dart:async';
import 'dart:ui';

import 'package:aves/geo/countries.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/metadata/address.dart';
import 'package:aves/services/common/service_policy.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/services/geocoding_service.dart';
import 'package:country_code/country_code.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

extension ExtraAvesEntryLocation on AvesEntry {
  LatLng? get latLng => hasGps ? LatLng(catalogMetadata!.latitude!, catalogMetadata!.longitude!) : null;

  Future<void> locate({required bool background, required bool force, required Locale geocoderLocale}) async {
    if (hasGps) {
      await _locateCountry(force: force);
      if (await availability.canLocatePlaces) {
        await locatePlace(background: background, force: force, geocoderLocale: geocoderLocale);
      }
    } else {
      addressDetails = null;
    }
  }

  // quick reverse geocoding to find the country, using an offline asset
  Future<void> _locateCountry({required bool force}) async {
    if (!hasGps || (hasAddress && !force)) return;
    final countryCode = await countryTopology.countryCode(latLng!);
    setCountry(countryCode);
  }

  void setCountry(CountryCode? countryCode) {
    if (hasFineAddress || countryCode == null) return;
    addressDetails = AddressDetails(
      id: id,
      countryCode: countryCode.alpha2,
      countryName: countryCode.alpha3,
    );
  }

  // full reverse geocoding, requiring Play Services and some connectivity
  Future<void> locatePlace({required bool background, required bool force, required Locale geocoderLocale}) async {
    if (!hasGps || (hasFineAddress && !force)) return;
    try {
      Future<List<Address>> call() => GeocodingService.getAddress(latLng!, geocoderLocale);
      final addresses = await (background
          ? servicePolicy.call(
              call,
              priority: ServiceCallPriority.getLocation,
            )
          : call());
      if (addresses.isNotEmpty) {
        final v = addresses.first;
        var locality = v.locality ?? v.subLocality ?? v.featureName;
        if (locality == null || locality == v.subThoroughfare) {
          locality = v.subAdminArea ?? v.addressLine;
        }
        addressDetails = AddressDetails(
          id: id,
          countryCode: v.countryCode?.toUpperCase(),
          countryName: v.countryName,
          adminArea: v.adminArea,
          locality: locality,
        );
      }
    } catch (error, stack) {
      debugPrint('$runtimeType locate failed with path=$path coordinates=$latLng error=$error\n$stack');
    }
  }

  Future<String?> findAddressLine({required Locale geocoderLocale}) async {
    if (!hasGps) return null;

    try {
      final addresses = await GeocodingService.getAddress(latLng!, geocoderLocale);
      if (addresses.isNotEmpty) {
        final address = addresses.first;
        return address.addressLine;
      }
    } catch (error, stack) {
      debugPrint('$runtimeType findAddressLine failed with path=$path coordinates=$latLng error=$error\n$stack');
    }
    return null;
  }
}
