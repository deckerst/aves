import 'dart:async';
import 'dart:typed_data';

import 'package:aves_map/aves_map.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:provider/provider.dart';

class EntryGoogleMap<T> extends StatefulWidget {
  final AvesMapController controller;
  final Listenable clusterListenable;
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final double? minZoom, maxZoom;
  final EntryMapStyle style;
  final TransitionBuilder decoratorBuilder;
  final WidgetBuilder buttonPanelBuilder;
  final MarkerClusterBuilder<T> markerClusterBuilder;
  final MarkerWidgetBuilder<T> markerWidgetBuilder;
  final MarkerImageReadyChecker<T> markerImageReadyChecker;
  final ValueNotifier<ll.LatLng?>? dotLocationNotifier;
  final ValueNotifier<List<GeoTrack>> tracksNotifier;
  final ValueNotifier<double>? overlayOpacityNotifier;
  final MapOverlay? overlayEntry;
  final UserZoomChangeCallback? onUserZoomChange;
  final MapTapCallback? onMapTap;
  final MarkerTapCallback<T>? onMarkerTap;
  final MarkerLongPressCallback<T>? onMarkerLongPress;

  const EntryGoogleMap({
    super.key,
    required this.controller,
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
    required this.tracksNotifier,
    this.overlayOpacityNotifier,
    this.overlayEntry,
    this.onUserZoomChange,
    this.onMapTap,
    this.onMarkerTap,
    this.onMarkerLongPress,
  });

  @override
  State<StatefulWidget> createState() => _EntryGoogleMapState<T>();
}

class _EntryGoogleMapState<T> extends State<EntryGoogleMap<T>> {
  GoogleMapController? _serviceMapController;
  final List<StreamSubscription> _subscriptions = [];
  Map<MarkerKey<T>, GeoEntry<T>> _geoEntryByMarkerKey = {};
  final Map<MarkerKey<T>, Uint8List> _markerBitmaps = {};
  final StreamController<MarkerKey<T>> _markerBitmapReadyStreamController = StreamController.broadcast();
  Uint8List? _dotMarkerBitmap;
  final ValueNotifier<Size> _sizeNotifier = ValueNotifier(Size.zero);

  ValueNotifier<ZoomedBounds> get boundsNotifier => widget.boundsNotifier;

  ZoomedBounds get bounds => boundsNotifier.value;

  static const uninitializedLatLng = LatLng(0, 0);
  static const boundInitDelay = Duration(milliseconds: 100);

  @override
  void initState() {
    super.initState();
    _sizeNotifier.addListener(_onSizeChanged);
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant EntryGoogleMap<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _serviceMapController?.dispose();
    _sizeNotifier.dispose();
    super.dispose();
  }

  void _registerWidget(EntryGoogleMap<T> widget) {
    final avesMapController = widget.controller;
    _subscriptions.add(avesMapController.moveCommands.listen((event) => _moveTo(_toServiceLatLng(event.latLng))));
    _subscriptions.add(avesMapController.zoomCommands.listen((event) => _zoomBy(event.delta)));
    _subscriptions.add(avesMapController.rotationResetCommands.listen((_) => _resetRotation()));
    widget.clusterListenable.addListener(_updateMarkers);
  }

  void _unregisterWidget(EntryGoogleMap<T> widget) {
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
        widget.buttonPanelBuilder(context),
      ],
    );
  }

  Widget _buildMap() {
    return StreamBuilder(
      stream: _markerBitmapReadyStreamController.stream,
      builder: (context, _) {
        final mediaMarkers = <Marker>{};
        _geoEntryByMarkerKey.forEach((markerKey, geoEntry) {
          final bytes = _markerBitmaps[markerKey];
          if (bytes != null) {
            final point = LatLng(geoEntry.latitude!, geoEntry.longitude!);
            mediaMarkers.add(
              Marker(
                markerId: MarkerId(geoEntry.markerId!),
                consumeTapEvents: true,
                icon: BytesMapBitmap(
                  bytes,
                  bitmapScaling: MapBitmapScaling.none,
                ),
                position: point,
                onTap: () => widget.onMarkerTap?.call(geoEntry),
                // TODO TLAD [map] GoogleMap.onLongPress is not appropriate for mediaMarkers, so the call should be here when this is fixed: https://github.com/flutter/flutter/issues/107148
                // onLongPress: widget.onMarkerLongPress != null
                //     ? (v) {
                //         final pressLocation = _fromServiceLatLng(v);
                //         final mediaMarkers = _geoEntryByMarkerKey.values.toSet();
                //         final geoEntry = ImageMarker.markerMatch(pressLocation, bounds.zoom, mediaMarkers);
                //         if (geoEntry != null) {
                //           widget.onMarkerLongPress?.call(geoEntry, pressLocation);
                //         }
                //       }
                //     : null,
              ),
            );
          }
        });

        final interactive = context.select<MapThemeData, bool>((v) => v.interactive);
        final overlayEntry = widget.overlayEntry;
        return LayoutBuilder(
          builder: (context, constraints) {
            _sizeNotifier.value = constraints.biggest;
            return NullableValueListenableBuilder<ll.LatLng?>(
              valueListenable: widget.dotLocationNotifier,
              builder: (context, dotLocation, child) {
                return NullableValueListenableBuilder<List<GeoTrack>>(
                  valueListenable: widget.tracksNotifier,
                  builder: (context, tracks, child) {
                    return NullableValueListenableBuilder<double>(
                      valueListenable: widget.overlayOpacityNotifier,
                      builder: (context, value, child) {
                        final double overlayOpacity = value ?? 1.0;
                        final initialCameraPosition = CameraPosition(
                          bearing: -bounds.rotation,
                          target: _toServiceLatLng(bounds.projectedCenter),
                          zoom: bounds.zoom,
                        );
                        final markers = {
                          ...mediaMarkers,
                          if (dotLocation != null && _dotMarkerBitmap != null)
                            Marker(
                              markerId: const MarkerId('dot'),
                              anchor: const Offset(.5, .5),
                              consumeTapEvents: true,
                              icon: BytesMapBitmap(
                                _dotMarkerBitmap!,
                                bitmapScaling: MapBitmapScaling.none,
                              ),
                              position: _toServiceLatLng(dotLocation),
                              zIndexInt: 1,
                            ),
                        };
                        final polylines = {
                          ...?tracks?.map(
                            (track) => Polyline(
                              polylineId: PolylineId(track.hashCode.toString()),
                              color: track.color,
                              endCap: .roundCap,
                              geodesic: true,
                              jointType: .round,
                              points: track.points.map(_toServiceLatLng).toList(),
                              startCap: .roundCap,
                              width: MapThemeData.trackWidth,
                            ),
                          ),
                        };
                        final tileOverlays = {
                          // TODO TLAD [geotiff] may use ground overlay instead
                          if (overlayEntry != null && overlayEntry.canOverlay)
                            TileOverlay(
                              tileOverlayId: TileOverlayId(overlayEntry.id),
                              tileProvider: GmsGeoTiffTileProvider(overlayEntry),
                              transparency: 1 - overlayOpacity,
                            ),
                        };
                        return GoogleMap(
                          initialCameraPosition: initialCameraPosition,
                          onMapCreated: (controller) async {
                            _serviceMapController = controller;
                            final zoom = await controller.getZoomLevel();
                            // the visible region is sometimes incorrect when queried right after creation,
                            await Future.delayed(boundInitDelay);
                            await _updateVisibleRegion(zoom: zoom, rotation: bounds.rotation);
                            // `onCameraIdle` is not always automatically triggered following map creation
                            _onIdle();
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
                          markers: markers,
                          polylines: polylines,
                          tileOverlays: tileOverlays,
                          onCameraMove: (position) => _updateVisibleRegion(zoom: position.zoom, rotation: -position.bearing),
                          onCameraIdle: _onIdle,
                          onTap: (v) => widget.onMapTap?.call(_fromServiceLatLng(v)),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // sometimes the map does not properly update after changing the widget size,
  // so we monitor the size and force refreshing after an arbitrary small delay
  Future<void> _onSizeChanged() async {
    await Future.delayed(boundInitDelay);
    _onIdle();
  }

  void _onIdle() {
    if (!mounted) return;
    widget.controller.notifyIdle(bounds);
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
    }
  }

  Future<void> _resetRotation() async {
    final controller = _serviceMapController;
    if (controller == null) return;

    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _toServiceLatLng(bounds.projectedCenter),
          zoom: bounds.zoom,
        ),
      ),
    );
  }

  Future<void> _zoomBy(double amount) async {
    final controller = _serviceMapController;
    if (controller == null) return;

    widget.onUserZoomChange?.call(await controller.getZoomLevel() + amount);
    await controller.animateCamera(CameraUpdate.zoomBy(amount));
  }

  Future<void> _moveTo(LatLng point) async {
    final controller = _serviceMapController;
    if (controller == null) return;

    await controller.animateCamera(CameraUpdate.newLatLng(point));
  }

  // `LatLng` used by `google_maps_flutter` is not the one from `latlong2` package
  LatLng _toServiceLatLng(ll.LatLng location) => LatLng(location.latitude, location.longitude);

  ll.LatLng _fromServiceLatLng(LatLng location) => ll.LatLng(location.latitude, location.longitude);

  MapType _toMapType(EntryMapStyle style) {
    if (style == EntryMapStyles.googleNormal) return MapType.normal;
    if (style == EntryMapStyles.googleHybrid) return MapType.hybrid;
    if (style == EntryMapStyles.googleTerrain) return MapType.terrain;
    return MapType.none;
  }
}

class GmsGeoTiffTileProvider extends TileProvider {
  MapOverlay overlayEntry;

  GmsGeoTiffTileProvider(this.overlayEntry);

  @override
  Future<Tile> getTile(int x, int y, int? zoom) async {
    final tile = await overlayEntry.getTile(x, y, zoom);
    if (tile != null) {
      return Tile(tile.width, tile.height, tile.data);
    }
    return TileProvider.noTile;
  }
}
