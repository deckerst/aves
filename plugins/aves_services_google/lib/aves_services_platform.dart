library aves_services_platform;

import 'package:aves_map/aves_map.dart';
import 'package:aves_services/aves_services.dart';
import 'package:aves_services_platform/src/map.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:latlong2/latlong.dart' as ll;

class PlatformMobileServices extends MobileServices {
  bool _isAvailable = false;
  bool _canRenderMaps = false;

  @override
  Future<void> init() async {
    final result = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
    _isAvailable = result == GooglePlayServicesAvailability.success;
    debugPrint('Device has Google Play Services=$_isAvailable');

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    _canRenderMaps = androidInfo.version.sdkInt >= 21;
  }

  @override
  bool get isServiceAvailable => _isAvailable;

  @override
  EntryMapStyle get defaultMapStyle => EntryMapStyle.googleNormal;

  @override
  List<EntryMapStyle> get mapStyles => (isServiceAvailable && _canRenderMaps)
      ? [
          EntryMapStyle.googleNormal,
          EntryMapStyle.googleHybrid,
          EntryMapStyle.googleTerrain,
        ]
      : [];

  @override
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
    required ValueNotifier<ll.LatLng?>? dotLocationNotifier,
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
      minZoom: 0,
      maxZoom: 20,
      style: style,
      decoratorBuilder: decoratorBuilder,
      buttonPanelBuilder: buttonPanelBuilder,
      markerClusterBuilder: markerClusterBuilder,
      markerWidgetBuilder: markerWidgetBuilder,
      markerImageReadyChecker: markerImageReadyChecker,
      dotLocationNotifier: dotLocationNotifier,
      overlayOpacityNotifier: overlayOpacityNotifier,
      overlayEntry: overlayEntry,
      onUserZoomChange: onUserZoomChange,
      onMapTap: onMapTap,
      onMarkerTap: onMarkerTap,
      onMarkerLongPress: onMarkerLongPress,
    );
  }
}
