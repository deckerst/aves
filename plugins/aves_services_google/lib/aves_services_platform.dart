import 'package:aves_map/aves_map.dart';
import 'package:aves_services/aves_services.dart';
import 'package:aves_services_platform/src/map.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:latlong2/latlong.dart' as ll;

class PlatformMobileServices extends MobileServices {
  bool _isAvailable = false;

  @override
  Future<void> init() async {
    final result = await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();
    _isAvailable = result == GooglePlayServicesAvailability.success;
    debugPrint('Device has Google Play Services=$_isAvailable');

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final mapsImplementation = GoogleMapsFlutterPlatform.instance;
    if (mapsImplementation is GoogleMapsFlutterAndroid) {
      // As of Flutter v3.22.2 / google_maps_flutter_android 2.12.0,
      // using Texture Layer Hybrid Composition (`useAndroidViewSurface = false`)
      // is the default and the best. But it fails to render on API < 23, yielding:
      // "UnsupportedOperationException: Platform views cannot be displayed below API level 23"
      // so we fall back to Hybrid Composition (`useAndroidViewSurface = true`)
      mapsImplementation.useAndroidViewSurface = androidInfo.version.sdkInt < 23;
    }
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
    required ValueNotifier<double>? overlayOpacityNotifier,
    required MapOverlay? overlayEntry,
    required Set<List<ll.LatLng>>? tracks,
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
      tracks: tracks,
      onUserZoomChange: onUserZoomChange,
      onMapTap: onMapTap,
      onMarkerTap: onMarkerTap,
      onMarkerLongPress: onMarkerLongPress,
    );
  }
}
