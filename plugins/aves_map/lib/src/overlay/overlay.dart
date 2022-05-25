import 'package:aves_map/src/overlay/tile.dart';
import 'package:flutter/painting.dart';
import 'package:latlong2/latlong.dart';

mixin MapOverlay {
  String get id;

  bool get canOverlay;

  LatLng? get topLeft;

  LatLng? get bottomRight;

  ImageProvider get imageProvider;

  Future<MapTile?> getTile(int tx, int ty, int? zoomLevel);
}
