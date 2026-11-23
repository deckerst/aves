import 'package:aves_map/aves_map.dart';
import 'package:aves_services/aves_services.dart';
import 'package:aves_services_platform/src/map.dart';
import 'package:flutter/widgets.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:latlong2/latlong.dart' as ll;

class PlatformMobileServices extends MobileServices {
  bool _isAvailable = false;

  @override
  Future<void> init() async {
    final result = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
    _isAvailable = result == GooglePlayServicesAvailability.success;
    debugPrint('Device has Google Play Services=$_isAvailable');
  }

  @override
  bool get isServiceAvailable => _isAvailable;

  @override
  EntryMapStyle? get defaultMapStyle => EntryMapStyles.googleNormal;

  @override
  List<EntryMapStyle> get mapStyles => isServiceAvailable
      ? [
          EntryMapStyles.googleNormal,
          EntryMapStyles.googleHybrid,
          EntryMapStyles.googleTerrain,
        ]
      : [];

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
    required ValueNotifier<ll.LatLng?>? dotLocationNotifier,
    required ValueNotifier<List<GeoTrack>> tracksNotifier,
    required ValueNotifier<double>? overlayOpacityNotifier,
    required MapOverlay? overlayEntry,
    required UserZoomChangeCallback? onUserZoomChange,
    required MapTapCallback? onMapTap,
    required MarkerTapCallback<T>? onMarkerTap,
    required MarkerLongPressCallback<T>? onMarkerLongPress,
  }) {
    return EntryGoogleMap<T>(
      controller: controller,
      clusterListenable: clusterListenable,
      boundsNotifier: boundsNotifier,
      // in practice on a Sony Xperia 5 V,
      // `minZoom` is capped at 3 even when specified lower
      minZoom: 2,
      style: style,
      decoratorBuilder: decoratorBuilder,
      buttonPanelBuilder: buttonPanelBuilder,
      markerClusterBuilder: markerClusterBuilder,
      markerWidgetBuilder: markerWidgetBuilder,
      markerImageReadyChecker: markerImageReadyChecker,
      dotLocationNotifier: dotLocationNotifier,
      tracksNotifier: tracksNotifier,
      overlayOpacityNotifier: overlayOpacityNotifier,
      overlayEntry: overlayEntry,
      onUserZoomChange: onUserZoomChange,
      onMapTap: onMapTap,
      onMarkerTap: onMarkerTap,
      onMarkerLongPress: onMarkerLongPress,
    );
  }
}
