import 'dart:async';

import 'package:aves_map/src/zoomed_bounds.dart';
import 'package:latlong2/latlong.dart';

class AvesMapController {
  final StreamController _streamController = StreamController.broadcast();

  Stream<dynamic> get _events => _streamController.stream;

  Stream<MapControllerMoveEvent> get moveCommands => _events.where((event) => event is MapControllerMoveEvent).cast<MapControllerMoveEvent>();

  Stream<MapIdleUpdate> get idleUpdates => _events.where((event) => event is MapIdleUpdate).cast<MapIdleUpdate>();

  Stream<MapMarkerLocationChangeEvent> get markerLocationChanges => _events.where((event) => event is MapMarkerLocationChangeEvent).cast<MapMarkerLocationChangeEvent>();

  void dispose() {
    _streamController.close();
  }

  void moveTo(LatLng latLng) => _streamController.add(MapControllerMoveEvent(latLng));

  void notifyIdle(ZoomedBounds bounds) => _streamController.add(MapIdleUpdate(bounds));

  void notifyMarkerLocationChange() => _streamController.add(MapMarkerLocationChangeEvent());
}

class MapControllerMoveEvent {
  final LatLng latLng;

  MapControllerMoveEvent(this.latLng);
}

class MapIdleUpdate {
  final ZoomedBounds bounds;

  MapIdleUpdate(this.bounds);
}

class MapMarkerLocationChangeEvent {}
