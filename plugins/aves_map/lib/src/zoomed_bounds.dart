import 'dart:math';

import 'package:aves_map/src/geo_utils.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

@immutable
class ZoomedBounds extends Equatable {
  final LatLng sw, ne;
  final double zoom, rotation;

  // returns [southwestLng, southwestLat, northeastLng, northeastLat], as expected by Fluster
  List<double> get boundingBox => [sw.longitude, sw.latitude, ne.longitude, ne.latitude];

  // Map services (Google Maps, OpenStreetMap) use the spherical Mercator projection (EPSG 3857).
  static const _crs = Epsg3857();

  // The projected center appears visually in the middle of the bounds.
  LatLng get projectedCenter {
    final swPoint = _crs.latLngToPoint(sw, zoom);
    final nePoint = _crs.latLngToPoint(ne, zoom);
    // assume no padding around bounds
    final projectedCenter = _crs.pointToLatLng((swPoint + nePoint) / 2, zoom);
    return projectedCenter ?? GeoUtils.getLatLngCenter([sw, ne]);
  }

  @override
  List<Object?> get props => [sw, ne, zoom, rotation];

  const ZoomedBounds({
    required this.sw,
    required this.ne,
    required this.zoom,
    required this.rotation,
  });

  static const _collocationMaxDeltaThreshold = 360 / (2 << 19);

  factory ZoomedBounds.fromPoints({
    required Set<LatLng> points,
    double collocationZoom = 20,
  }) {
    var west = .0, south = .0, east = .0, north = .0;
    var zoom = collocationZoom;

    if (points.isNotEmpty) {
      final first = points.first;
      west = first.longitude;
      south = first.latitude;
      east = first.longitude;
      north = first.latitude;

      for (var point in points) {
        final lng = point.longitude;
        final lat = point.latitude;
        if (lng < west) west = lng;
        if (lat < south) south = lat;
        if (lng > east) east = lng;
        if (lat > north) north = lat;
      }

      final boundsDelta = max(north - south, east - west);
      if (boundsDelta > _collocationMaxDeltaThreshold) {
        zoom = max(1, log(360) / ln2 - log(boundsDelta) / ln2);
      }
    }
    return ZoomedBounds(
      sw: LatLng(south, west),
      ne: LatLng(north, east),
      zoom: zoom,
      rotation: 0,
    );
  }

  ZoomedBounds copyWith({
    LatLng? sw,
    LatLng? ne,
    double? zoom,
    double? rotation,
  }) {
    return ZoomedBounds(
      sw: sw ?? this.sw,
      ne: ne ?? this.ne,
      zoom: zoom ?? this.zoom,
      rotation: rotation ?? this.rotation,
    );
  }

  bool contains(LatLng point) => GeoUtils.contains(sw, ne, point);
}
