import 'dart:async';

import 'package:latlong2/latlong.dart';

class AvesMapController {
  final StreamController _streamController = StreamController.broadcast();

  Stream<dynamic> get _events => _streamController.stream;

  Stream<MapControllerMoveEvent> get moveEvents => _events.where((event) => event is MapControllerMoveEvent).cast<MapControllerMoveEvent>();

  void dispose() {
    _streamController.close();
  }

  void moveTo(LatLng latLng) => _streamController.add(MapControllerMoveEvent(latLng));
}

class MapControllerMoveEvent {
  final LatLng latLng;

  MapControllerMoveEvent(this.latLng);
}
