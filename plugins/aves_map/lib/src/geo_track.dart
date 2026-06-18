import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

@immutable
class GeoTrack {
  final List<LatLng> points;
  final Color color;

  const GeoTrack({
    required this.points,
    required this.color,
  });

  static const defaultStart = Color(0xFF216DFF); // cold indigo
  static const defaultEnd = Color(0xFF856DCC); // warm indigo

  static List<GeoTrack> buildTracks(
    List<List<LatLng>> trackPoints, {
    Color startColor = defaultStart,
    Color endColor = defaultEnd,
  }) {
    final count = trackPoints.length.toDouble();
    return trackPoints
        .mapIndexed(
          (i, points) => GeoTrack(
            points: points,
            color: Color.lerp(startColor, endColor, i / count)!,
          ),
        )
        .toList();
  }
}
