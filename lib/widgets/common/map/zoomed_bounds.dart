import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

@immutable
class ZoomedBounds extends Equatable {
  final double west, south, east, north, zoom;

  List<double> get boundingBox => [west, south, east, north];

  LatLng get center => LatLng((north + south) / 2, (east + west) / 2);

  @override
  List<Object?> get props => [west, south, east, north, zoom];

  const ZoomedBounds({
    required this.west,
    required this.south,
    required this.east,
    required this.north,
    required this.zoom,
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
      west: west,
      south: south,
      east: east,
      north: north,
      zoom: zoom,
    );
  }
}
