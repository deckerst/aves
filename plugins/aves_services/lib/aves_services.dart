import 'package:aves_map/aves_map.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

abstract class MobileServices {
  Future<void> init();

  bool get isServiceAvailable;

  EntryMapStyle get defaultMapStyle;

  List<EntryMapStyle> get mapStyles;

  Widget buildMap<T>({
    required AvesMapController? controller,
    required Listenable clusterListenable,
    required ValueNotifier<ZoomedBounds> boundsNotifier,
    required EntryMapStyle style,
    required TransitionBuilder decoratorBuilder,
    required ButtonPanelBuilder buttonPanelBuilder,
    required MarkerClusterBuilder<T> markerClusterBuilder,
    required MarkerWidgetBuilder<T> markerWidgetBuilder,
    required MarkerImageReadyChecker<T> markerImageReadyChecker,
    required ValueNotifier<LatLng?>? dotLocationNotifier,
    required ValueNotifier<double>? overlayOpacityNotifier,
    required MapOverlay? overlayEntry,
    required UserZoomChangeCallback? onUserZoomChange,
    required MapTapCallback? onMapTap,
    required MarkerTapCallback<T>? onMarkerTap,
    required MarkerLongPressCallback<T>? onMarkerLongPress,
  });
}
