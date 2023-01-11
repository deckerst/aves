import 'package:aves_map/src/geo_entry.dart';
import 'package:aves_map/src/marker/key.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

typedef ButtonPanelBuilder = Widget Function(VoidCallback resetRotation);
typedef MarkerClusterBuilder<T> = Map<MarkerKey<T>, GeoEntry<T>> Function();
typedef MarkerWidgetBuilder<T> = Widget Function(MarkerKey<T> key);
typedef MarkerImageReadyChecker<T> = bool Function(MarkerKey<T> key);
typedef UserZoomChangeCallback = void Function(double zoom);
typedef MapTapCallback = void Function(LatLng location);
typedef MarkerTapCallback<T> = void Function(GeoEntry<T> geoEntry);
typedef MarkerLongPressCallback<T> = void Function(GeoEntry<T> geoEntry, LatLng tapLocation);
