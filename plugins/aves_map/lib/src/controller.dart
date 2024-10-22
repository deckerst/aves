import 'dart:async';

import 'package:aves_map/src/zoomed_bounds.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class AvesMapController {
  final StreamController _streamController = StreamController.broadcast();
  ZoomedBounds? _idleBounds;

  ZoomedBounds? get idleBounds => _idleBounds;

  Stream<dynamic> get _events => _streamController.stream;

  Stream<MapControllerMoveEvent> get moveCommands => _events.where((event) => event is MapControllerMoveEvent).cast<MapControllerMoveEvent>();

  Stream<MapControllerZoomEvent> get zoomCommands => _events.where((event) => event is MapControllerZoomEvent).cast<MapControllerZoomEvent>();

  Stream<MapControllerRotationResetEvent> get rotationResetCommands => _events.where((event) => event is MapControllerRotationResetEvent).cast<MapControllerRotationResetEvent>();

  Stream<MapIdleUpdate> get idleUpdates => _events.where((event) => event is MapIdleUpdate).cast<MapIdleUpdate>();

  Stream<MapMarkerLocationChangeEvent> get markerLocationChanges => _events.where((event) => event is MapMarkerLocationChangeEvent).cast<MapMarkerLocationChangeEvent>();

  AvesMapController() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'aves',
        className: '$AvesMapController',
        object: this,
      );
    }
  }

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _streamController.close();
  }

  void moveTo(LatLng latLng) => _streamController.add(MapControllerMoveEvent(latLng));

  void zoomBy(double delta) => _streamController.add(MapControllerZoomEvent(delta));

  void resetRotation() => _streamController.add(MapControllerRotationResetEvent());

  void notifyIdle(ZoomedBounds bounds) {
    _idleBounds = bounds;
    _streamController.add(MapIdleUpdate(bounds));
  }

  void notifyMarkerLocationChange() => _streamController.add(MapMarkerLocationChangeEvent());
}

class MapControllerMoveEvent {
  final LatLng latLng;

  MapControllerMoveEvent(this.latLng);
}

class MapControllerZoomEvent {
  final double delta;

  MapControllerZoomEvent(this.delta);
}

class MapControllerRotationResetEvent {}

class MapIdleUpdate {
  final ZoomedBounds bounds;

  MapIdleUpdate(this.bounds);
}

class MapMarkerLocationChangeEvent {}
