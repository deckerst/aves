library aves_services_platform;

import 'package:aves_map/aves_map.dart';
import 'package:aves_services/aves_services.dart';
import 'package:aves_services_platform/src/map.dart';
import 'package:flutter/widgets.dart';
import 'package:huawei_hmsavailability/huawei_hmsavailability.dart';
import 'package:latlong2/latlong.dart';

class PlatformMobileServices extends MobileServices {
  // cf https://developer.huawei.com/consumer/en/doc/development/hmscore-common-References/huaweiapiavailability-0000001050121134#section9492524178
  static const int _hmsCoreAvailable = 0;

  bool _isAvailable = false;

  @override
  Future<void> init() async {
    final result = await HmsApiAvailability().isHMSAvailable();
    _isAvailable = result == _hmsCoreAvailable;
    debugPrint('Device has Huawei Mobile Services=$_isAvailable');
  }

  @override
  bool get isServiceAvailable => _isAvailable;

  @override
  EntryMapStyle get defaultMapStyle => EntryMapStyle.hmsNormal;

  @override
  List<EntryMapStyle> get mapStyles => isServiceAvailable
      ? [
          EntryMapStyle.hmsNormal,
          EntryMapStyle.hmsTerrain,
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
    required ValueNotifier<LatLng?>? dotLocationNotifier,
    required ValueNotifier<double>? overlayOpacityNotifier,
    required MapOverlay? overlayEntry,
    required UserZoomChangeCallback? onUserZoomChange,
    required MapTapCallback? onMapTap,
    required MarkerTapCallback<T>? onMarkerTap,
  }) {
    return EntryHmsMap<T>(
      controller: controller,
      clusterListenable: clusterListenable,
      boundsNotifier: boundsNotifier,
      minZoom: 3,
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
    );
  }
}
