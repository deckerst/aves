import 'dart:async';
import 'dart:typed_data';

import 'package:aves/model/entry_images.dart';
import 'package:aves/model/geotiff.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/widgets/common/map/buttons.dart';
import 'package:aves/widgets/common/map/controller.dart';
import 'package:aves/widgets/common/map/decorator.dart';
import 'package:aves/widgets/common/map/geo_entry.dart';
import 'package:aves/widgets/common/map/geo_map.dart';
import 'package:aves/widgets/common/map/google/geotiff_tile_provider.dart';
import 'package:aves/widgets/common/map/google/marker_generator.dart';
import 'package:aves/widgets/common/map/marker.dart';
import 'package:aves/widgets/common/map/theme.dart';
import 'package:aves/widgets/common/map/zoomed_bounds.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:provider/provider.dart';

class EntryGoogleMap extends StatefulWidget {
  final AvesMapController? controller;
  final Listenable clusterListenable;
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final double? minZoom, maxZoom;
  final EntryMapStyle style;
  final MarkerClusterBuilder markerClusterBuilder;
  final MarkerWidgetBuilder markerWidgetBuilder;
  final ValueNotifier<ll.LatLng?>? dotLocationNotifier;
  final ValueNotifier<double>? overlayOpacityNotifier;
  final MappedGeoTiff? overlayEntry;
  final UserZoomChangeCallback? onUserZoomChange;
  final void Function(ll.LatLng location)? onMapTap;
  final void Function(GeoEntry geoEntry)? onMarkerTap;
  final MapOpener? openMapPage;

  const EntryGoogleMap({
    Key? key,
    this.controller,
    required this.clusterListenable,
    required this.boundsNotifier,
    this.minZoom,
    this.maxZoom,
    required this.style,
    required this.markerClusterBuilder,
    required this.markerWidgetBuilder,
    required this.dotLocationNotifier,
    this.overlayOpacityNotifier,
    this.overlayEntry,
    this.onUserZoomChange,
    this.onMapTap,
    this.onMarkerTap,
    this.openMapPage,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EntryGoogleMapState();
}

class _EntryGoogleMapState extends State<EntryGoogleMap> with WidgetsBindingObserver {
  GoogleMapController? _googleMapController;
  final List<StreamSubscription> _subscriptions = [];
  Map<MarkerKey, GeoEntry> _geoEntryByMarkerKey = {};
  final Map<MarkerKey, Uint8List> _markerBitmaps = {};
  final AChangeNotifier _markerBitmapChangeNotifier = AChangeNotifier();
  Uint8List? _dotMarkerBitmap;

  ValueNotifier<ZoomedBounds> get boundsNotifier => widget.boundsNotifier;

  ZoomedBounds get bounds => boundsNotifier.value;

  static const uninitializedLatLng = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant EntryGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _googleMapController?.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void _registerWidget(EntryGoogleMap widget) {
    final avesMapController = widget.controller;
    if (avesMapController != null) {
      _subscriptions.add(avesMapController.moveCommands.listen((event) => _moveTo(_toGoogleLatLng(event.latLng))));
    }
    widget.clusterListenable.addListener(_updateMarkers);
  }

  void _unregisterWidget(EntryGoogleMap widget) {
    widget.clusterListenable.removeListener(_updateMarkers);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.resumed:
        // workaround for blank Google map when resuming app
        // cf https://github.com/flutter/flutter/issues/40284
        _googleMapController?.setMapStyle(null);
        break;
    }
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
        MarkerGeneratorWidget<MarkerKey>(
          markers: _geoEntryByMarkerKey.keys.map(widget.markerWidgetBuilder).toList(),
          isReadyToRender: (key) => key.entry.isThumbnailReady(extent: GeoMap.markerImageExtent),
          onRendered: (key, bitmap) {
            _markerBitmaps[key] = bitmap;
            _markerBitmapChangeNotifier.notify();
          },
        ),
        MapDecorator(
          child: _buildMap(),
        ),
        MapButtonPanel(
          boundsNotifier: boundsNotifier,
          zoomBy: _zoomBy,
          openMapPage: widget.openMapPage,
          resetRotation: _resetRotation,
        ),
      ],
    );
  }

  Widget _buildMap() {
    return AnimatedBuilder(
      animation: _markerBitmapChangeNotifier,
      builder: (context, child) {
        final markers = <Marker>{};
        _geoEntryByMarkerKey.forEach((markerKey, geoEntry) {
          final bytes = _markerBitmaps[markerKey];
          if (bytes != null) {
            final point = LatLng(geoEntry.latitude!, geoEntry.longitude!);
            markers.add(Marker(
              markerId: MarkerId(geoEntry.markerId!),
              consumeTapEvents: true,
              icon: BitmapDescriptor.fromBytes(bytes),
              position: point,
              onTap: () => widget.onMarkerTap?.call(geoEntry),
            ));
          }
        });

        final interactive = context.select<MapThemeData, bool>((v) => v.interactive);
        final overlayEntry = widget.overlayEntry;
        return ValueListenableBuilder<ll.LatLng?>(
          valueListenable: widget.dotLocationNotifier ?? ValueNotifier(null),
          builder: (context, dotLocation, child) {
            return ValueListenableBuilder<double>(
              valueListenable: widget.overlayOpacityNotifier ?? ValueNotifier(1),
              builder: (context, overlayOpacity, child) {
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    bearing: -bounds.rotation,
                    target: _toGoogleLatLng(bounds.projectedCenter),
                    zoom: bounds.zoom,
                  ),
                  onMapCreated: (controller) async {
                    _googleMapController = controller;
                    final zoom = await controller.getZoomLevel();
                    await _updateVisibleRegion(zoom: zoom, rotation: bounds.rotation);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  // compass disabled to use provider agnostic controls
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  mapType: _toMapType(widget.style),
                  minMaxZoomPreference: MinMaxZoomPreference(widget.minZoom, widget.maxZoom),
                  rotateGesturesEnabled: true,
                  scrollGesturesEnabled: interactive,
                  // zoom controls disabled to use provider agnostic controls
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: interactive,
                  // lite mode disabled because it lacks camera animation
                  liteModeEnabled: false,
                  // tilt disabled to match leaflet
                  tiltGesturesEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  markers: {
                    ...markers,
                    if (dotLocation != null && _dotMarkerBitmap != null)
                      Marker(
                        markerId: const MarkerId('dot'),
                        anchor: const Offset(.5, .5),
                        consumeTapEvents: true,
                        icon: BitmapDescriptor.fromBytes(_dotMarkerBitmap!),
                        position: _toGoogleLatLng(dotLocation),
                        zIndex: 1,
                      )
                  },
                  // TODO TLAD [geotiff] may use ground overlay instead when this is fixed: https://github.com/flutter/flutter/issues/26479
                  tileOverlays: {
                    if (overlayEntry != null && overlayEntry.canOverlay)
                      TileOverlay(
                        tileOverlayId: TileOverlayId(overlayEntry.entry.uri),
                        tileProvider: GeoTiffTileProvider(overlayEntry),
                        transparency: 1 - overlayOpacity,
                      ),
                  },
                  onCameraMove: (position) => _updateVisibleRegion(zoom: position.zoom, rotation: -position.bearing),
                  onCameraIdle: _onIdle,
                  onTap: (position) => widget.onMapTap?.call(_fromGoogleLatLng(position)),
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

    final bounds = await _googleMapController?.getVisibleRegion();
    if (bounds != null && (bounds.northeast != uninitializedLatLng || bounds.southwest != uninitializedLatLng)) {
      final sw = bounds.southwest;
      final ne = bounds.northeast;
      boundsNotifier.value = ZoomedBounds(
        sw: _fromGoogleLatLng(sw),
        ne: _fromGoogleLatLng(ne),
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
    final controller = _googleMapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: _toGoogleLatLng(bounds.projectedCenter),
      zoom: bounds.zoom,
    )));
  }

  Future<void> _zoomBy(double amount) async {
    final controller = _googleMapController;
    if (controller == null) return;

    widget.onUserZoomChange?.call(await controller.getZoomLevel() + amount);
    await controller.animateCamera(CameraUpdate.zoomBy(amount));
  }

  Future<void> _moveTo(LatLng point) async {
    final controller = _googleMapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.newLatLng(point));
  }

  // `LatLng` used by `google_maps_flutter` is not the one from `latlong2` package
  LatLng _toGoogleLatLng(ll.LatLng location) => LatLng(location.latitude, location.longitude);

  ll.LatLng _fromGoogleLatLng(LatLng location) => ll.LatLng(location.latitude, location.longitude);

  MapType _toMapType(EntryMapStyle style) {
    switch (style) {
      case EntryMapStyle.googleNormal:
        return MapType.normal;
      case EntryMapStyle.googleHybrid:
        return MapType.hybrid;
      case EntryMapStyle.googleTerrain:
        return MapType.terrain;
      default:
        return MapType.none;
    }
  }
}
