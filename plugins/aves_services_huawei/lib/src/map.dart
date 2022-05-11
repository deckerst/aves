import 'dart:async';
import 'dart:typed_data';

import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:huawei_map/map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:provider/provider.dart';

class EntryHmsMap<T> extends StatefulWidget {
  final AvesMapController? controller;
  final Listenable clusterListenable;
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final double? minZoom, maxZoom;
  final EntryMapStyle style;
  final TransitionBuilder decoratorBuilder;
  final ButtonPanelBuilder buttonPanelBuilder;
  final MarkerClusterBuilder<T> markerClusterBuilder;
  final MarkerWidgetBuilder<T> markerWidgetBuilder;
  final MarkerImageReadyChecker<T> markerImageReadyChecker;
  final ValueNotifier<ll.LatLng?>? dotLocationNotifier;
  final ValueNotifier<double>? overlayOpacityNotifier;
  final MapOverlay? overlayEntry;
  final UserZoomChangeCallback? onUserZoomChange;
  final MapTapCallback? onMapTap;
  final MarkerTapCallback<T>? onMarkerTap;

  const EntryHmsMap({
    Key? key,
    this.controller,
    required this.clusterListenable,
    required this.boundsNotifier,
    this.minZoom,
    this.maxZoom,
    required this.style,
    required this.decoratorBuilder,
    required this.buttonPanelBuilder,
    required this.markerClusterBuilder,
    required this.markerWidgetBuilder,
    required this.markerImageReadyChecker,
    required this.dotLocationNotifier,
    this.overlayOpacityNotifier,
    this.overlayEntry,
    this.onUserZoomChange,
    this.onMapTap,
    this.onMarkerTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EntryHmsMapState<T>();
}

class _EntryHmsMapState<T> extends State<EntryHmsMap<T>> {
  HuaweiMapController? _serviceMapController;
  final List<StreamSubscription> _subscriptions = [];
  Map<MarkerKey<T>, GeoEntry<T>> _geoEntryByMarkerKey = {};
  final Map<MarkerKey<T>, Uint8List> _markerBitmaps = {};
  final StreamController<MarkerKey<T>> _markerBitmapReadyStreamController = StreamController.broadcast();
  Uint8List? _dotMarkerBitmap;

  ValueNotifier<ZoomedBounds> get boundsNotifier => widget.boundsNotifier;

  ZoomedBounds get bounds => boundsNotifier.value;

  static const uninitializedLatLng = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant EntryHmsMap<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(EntryHmsMap<T> widget) {
    final avesMapController = widget.controller;
    if (avesMapController != null) {
      _subscriptions.add(avesMapController.moveCommands.listen((event) => _moveTo(_toServiceLatLng(event.latLng))));
    }
    widget.clusterListenable.addListener(_updateMarkers);
  }

  void _unregisterWidget(EntryHmsMap<T> widget) {
    widget.clusterListenable.removeListener(_updateMarkers);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MarkerGeneratorWidget<Key>(
          markers: const [DotMarker(key: Key('dot'))],
          isReadyToRender: (key) => true,
          onRendered: (key, bitmap) => _dotMarkerBitmap = bitmap,
        ),
        MarkerGeneratorWidget<MarkerKey<T>>(
          markers: _geoEntryByMarkerKey.keys.map(widget.markerWidgetBuilder).toList(),
          isReadyToRender: widget.markerImageReadyChecker,
          onRendered: (key, bitmap) {
            _markerBitmaps[key] = bitmap;
            _markerBitmapReadyStreamController.add(key);
          },
        ),
        widget.decoratorBuilder(context, _buildMap()),
        widget.buttonPanelBuilder(_zoomBy, _resetRotation),
      ],
    );
  }

  Widget _buildMap() {
    return StreamBuilder(
      stream: _markerBitmapReadyStreamController.stream,
      builder: (context, _) {
        final markers = <Marker>{};
        _geoEntryByMarkerKey.forEach((markerKey, geoEntry) {
          final bytes = _markerBitmaps[markerKey];
          if (bytes != null) {
            final point = LatLng(geoEntry.latitude!, geoEntry.longitude!);
            markers.add(Marker(
              markerId: MarkerId(geoEntry.markerId!),
              clickable: true,
              icon: BitmapDescriptor.fromBytes(bytes),
              position: point,
              onClick: () => widget.onMarkerTap?.call(geoEntry),
            ));
          }
        });

        final interactive = context.select<MapThemeData, bool>((v) => v.interactive);
        // final overlayEntry = widget.overlayEntry;
        return ValueListenableBuilder<ll.LatLng?>(
          valueListenable: widget.dotLocationNotifier ?? ValueNotifier(null),
          builder: (context, dotLocation, child) {
            return ValueListenableBuilder<double>(
              valueListenable: widget.overlayOpacityNotifier ?? ValueNotifier(1),
              builder: (context, overlayOpacity, child) {
                return HuaweiMap(
                  initialCameraPosition: CameraPosition(
                    bearing: bounds.rotation,
                    target: _toServiceLatLng(bounds.projectedCenter),
                    zoom: bounds.zoom,
                  ),
                  mapType: _toMapType(widget.style),
                  // compass disabled to use provider agnostic controls
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  minMaxZoomPreference: MinMaxZoomPreference(
                    widget.minZoom ?? MinMaxZoomPreference.unbounded.minZoom,
                    widget.maxZoom ?? MinMaxZoomPreference.unbounded.maxZoom,
                  ),
                  // `allGesturesEnabled`, if defined overrides specific gesture settings
                  rotateGesturesEnabled: interactive,
                  scrollGesturesEnabled: interactive,
                  // zoom controls disabled to use provider agnostic controls
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: interactive,
                  // tilt disabled to match leaflet
                  tiltGesturesEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  trafficEnabled: false,
                  isScrollGesturesEnabledDuringRotateOrZoom: true,
                  markers: {
                    ...markers,
                    if (dotLocation != null && _dotMarkerBitmap != null)
                      Marker(
                        markerId: MarkerId('dot'),
                        anchor: const Offset(.5, .5),
                        clickable: true,
                        icon: BitmapDescriptor.fromBytes(_dotMarkerBitmap!),
                        position: _toServiceLatLng(dotLocation),
                        zIndex: 1,
                      )
                  },
                  // TODO TLAD [hms] GeoTIFF ground overlay
                  // groundOverlays: {
                  //   if (overlayEntry != null && overlayEntry.canOverlay)
                  //     GroundOverlay(
                  //       groundOverlayId: GroundOverlayId('overlay'),
                  //       // Google Maps API allows defining overlay either via
                  //       // 1) position, anchor and width/height (in meters)
                  //       // 2) bounds
                  //       // Huawei requires width/height (in meters?), but also allows bounds...
                  //       width: 42,
                  //       height: 42,
                  //       imageDescriptor: BitmapDescriptor.defaultMarker,
                  //       position: _toServiceLatLng(overlayEntry.center!),
                  //     ),
                  // },
                  // TODO TLAD [hms] dynamic tile provider from current bounds,
                  // tileOverlays: {
                  //   if (overlayEntry != null && overlayEntry.canOverlay)
                  //     TileOverlay(
                  //       tileOverlayId: TileOverlayId(overlayEntry.entry.uri),
                  //       // `tileProvider` is `RepetitiveTile`, `UrlTile` or List<Tile>
                  //       // tileProvider: <Tile>[
                  //       //   Tile(
                  //       //     x: x,
                  //       //     y: y,
                  //       //     zoom: zoom,
                  //       //     imageData: imageData,
                  //       //   ),
                  //       // ],
                  //       transparency: 1 - overlayOpacity,
                  //     ),
                  // },
                  onMapCreated: (controller) async {
                    _serviceMapController = controller;
                    final zoom = await controller.getZoomLevel();
                    await _updateVisibleRegion(zoom: zoom ?? bounds.zoom, rotation: bounds.rotation);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  onCameraMove: (position) => _updateVisibleRegion(zoom: position.zoom, rotation: position.bearing),
                  onCameraIdle: _onIdle,
                  onClick: (position) => widget.onMapTap?.call(_fromServiceLatLng(position)),
                  onPoiClick: (poi) {
                    final poiPosition = poi.latLng;
                    if (poiPosition != null) {
                      widget.onMapTap?.call(_fromServiceLatLng(poiPosition));
                    }
                  },
                  logoPadding: const EdgeInsets.all(8),
                  // lite mode disabled because it is not interactive
                  liteMode: false,
                );
              },
            );
          },
        );
      },
    );
  }

  void _onIdle() {
    if (!mounted) return;
    widget.controller?.notifyIdle(bounds);
    _updateMarkers();
  }

  void _updateMarkers() {
    setState(() => _geoEntryByMarkerKey = widget.markerClusterBuilder());
  }

  Future<void> _updateVisibleRegion({required double zoom, required double rotation}) async {
    if (!mounted) return;

    final bounds = await _serviceMapController?.getVisibleRegion();
    if (bounds != null && (bounds.northeast != uninitializedLatLng || bounds.southwest != uninitializedLatLng)) {
      final sw = bounds.southwest;
      final ne = bounds.northeast;
      boundsNotifier.value = ZoomedBounds(
        sw: _fromServiceLatLng(sw),
        ne: _fromServiceLatLng(ne),
        zoom: zoom,
        rotation: rotation,
      );
    } else {
      // the visible region is sometimes uninitialized when queried right after creation,
      // so we query it again next frame
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        _updateVisibleRegion(zoom: zoom, rotation: rotation);
      });
    }
  }

  Future<void> _resetRotation() async {
    final controller = _serviceMapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: _toServiceLatLng(bounds.projectedCenter),
      zoom: bounds.zoom,
    )));
  }

  Future<void> _zoomBy(double amount) async {
    final controller = _serviceMapController;
    if (controller == null) return;

    final zoom = await controller.getZoomLevel();
    if (zoom == null) return;

    widget.onUserZoomChange?.call(zoom + amount);
    await controller.animateCamera(CameraUpdate.zoomBy(amount));
  }

  Future<void> _moveTo(LatLng point) async {
    final controller = _serviceMapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.newLatLng(point));
  }

  // `LatLng` used by `google_maps_flutter` is not the one from `latlong2` package
  LatLng _toServiceLatLng(ll.LatLng location) => LatLng(location.latitude, location.longitude);

  ll.LatLng _fromServiceLatLng(LatLng location) => ll.LatLng(location.lat, location.lng);

  MapType _toMapType(EntryMapStyle style) {
    switch (style) {
      case EntryMapStyle.hmsNormal:
        return MapType.normal;
      case EntryMapStyle.hmsTerrain:
        return MapType.terrain;
      default:
        return MapType.none;
    }
  }
}
