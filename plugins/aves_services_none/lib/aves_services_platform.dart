import 'package:aves_map/aves_map.dart';
import 'package:aves_services/aves_services.dart';
import 'package:flutter/widgets.dart';
import 'package:latlong2/latlong.dart';

class PlatformMobileServices extends MobileServices {
  @override
  Future<void> init() async {}

  @override
  bool get isServiceAvailable => false;

  @override
  EntryMapStyle get defaultMapStyle => EntryMapStyle.values.first;

  @override
  List<EntryMapStyle> get mapStyles => [];

  @override
  Widget buildMap<T>({
    required AvesMapController controller,
    required Listenable clusterListenable,
    required ValueNotifier<ZoomedBounds> boundsNotifier,
    required EntryMapStyle style,
    required TransitionBuilder decoratorBuilder,
    required WidgetBuilder buttonPanelBuilder,
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
  }) {
    return const SizedBox();
  }
}
