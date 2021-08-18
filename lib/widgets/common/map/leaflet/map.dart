import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/widgets/common/map/buttons.dart';
import 'package:aves/widgets/common/map/decorator.dart';
import 'package:aves/widgets/common/map/geo_entry.dart';
import 'package:aves/widgets/common/map/geo_map.dart';
import 'package:aves/widgets/common/map/latlng_tween.dart';
import 'package:aves/widgets/common/map/leaflet/scale_layer.dart';
import 'package:aves/widgets/common/map/leaflet/tile_layers.dart';
import 'package:aves/widgets/common/map/zoomed_bounds.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EntryLeafletMap extends StatefulWidget {
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final bool interactive;
  final EntryMapStyle style;
  final EntryMarkerBuilder markerBuilder;
  final Fluster<GeoEntry> markerCluster;
  final List<AvesEntry> markerEntries;
  final Size markerSize;
  final UserZoomChangeCallback? onUserZoomChange;
  final GeoEntryTapCallback? onEntryTap;

  const EntryLeafletMap({
    Key? key,
    required this.boundsNotifier,
    required this.interactive,
    required this.style,
    required this.markerBuilder,
    required this.markerCluster,
    required this.markerEntries,
    required this.markerSize,
    this.onUserZoomChange,
    this.onEntryTap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EntryLeafletMapState();
}

class _EntryLeafletMapState extends State<EntryLeafletMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final List<StreamSubscription> _subscriptions = [];

  ValueNotifier<ZoomedBounds> get boundsNotifier => widget.boundsNotifier;

  ZoomedBounds get bounds => boundsNotifier.value;

  // duration should match the uncustomizable Google Maps duration
  static const _cameraAnimationDuration = Duration(milliseconds: 400);
  static const _zoomMin = 1.0;

  // TODO TLAD [map] also limit zoom on pinch-to-zoom gesture
  static const _zoomMax = 16.0;

  // TODO TLAD [map] allow rotation when leaflet scale layer is fixed
  static const interactiveFlags = InteractiveFlag.all & ~InteractiveFlag.rotate;

  @override
  void initState() {
    super.initState();
    _subscriptions.add(_mapController.mapEventStream.listen((event) => _updateVisibleRegion()));
    WidgetsBinding.instance!.addPostFrameCallback((_) => _updateVisibleRegion());
  }

  @override
  void dispose() {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZoomedBounds?>(
      valueListenable: boundsNotifier,
      builder: (context, visibleRegion, child) {
        final allEntries = widget.markerEntries;
        final geoEntries = visibleRegion != null ? widget.markerCluster.clusters(visibleRegion.boundingBox, visibleRegion.zoom.round()) : <GeoEntry>[];
        final geoEntryByMarkerKey = Map.fromEntries(geoEntries.map((v) {
          if (v.isCluster!) {
            final uri = v.childMarkerId;
            final entry = allEntries.firstWhere((v) => v.uri == uri);
            return MapEntry(MarkerKey(entry, v.pointsSize), v);
          }
          return MapEntry(MarkerKey(v.entry!, null), v);
        }));

        return Stack(
          children: [
            MapDecorator(
              interactive: widget.interactive,
              child: _buildMap(geoEntryByMarkerKey),
            ),
            MapButtonPanel(
              latLng: bounds.center,
              zoomBy: _zoomBy,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMap(Map<MarkerKey, GeoEntry> geoEntryByMarkerKey) {
    final markerSize = widget.markerSize;
    final markers = geoEntryByMarkerKey.entries.map((kv) {
      final markerKey = kv.key;
      final geoEntry = kv.value;
      final latLng = LatLng(geoEntry.latitude!, geoEntry.longitude!);
      return Marker(
        point: latLng,
        builder: (context) => GestureDetector(
          onTap: () {
            final clusterId = geoEntry.clusterId;
            widget.onEntryTap?.call(clusterId != null ? widget.markerCluster.points(clusterId) : [geoEntry]);
            _moveTo(latLng);
          },
          child: widget.markerBuilder(markerKey),
        ),
        width: markerSize.width,
        height: markerSize.height,
        anchorPos: AnchorPos.align(AnchorAlign.top),
      );
    }).toList();

    return FlutterMap(
      options: MapOptions(
        center: bounds.center,
        zoom: bounds.zoom,
        interactiveFlags: widget.interactive ? interactiveFlags : InteractiveFlag.none,
      ),
      mapController: _mapController,
      children: [
        _buildMapLayer(),
        ScaleLayerWidget(
          options: ScaleLayerOptions(),
        ),
        MarkerLayerWidget(
          options: MarkerLayerOptions(
            markers: markers,
            rotate: true,
            rotateAlignment: Alignment.bottomCenter,
          ),
        ),
      ],
    );
  }

  Widget _buildMapLayer() {
    switch (widget.style) {
      case EntryMapStyle.osmHot:
        return const OSMHotLayer();
      case EntryMapStyle.stamenToner:
        return const StamenTonerLayer();
      case EntryMapStyle.stamenWatercolor:
        return const StamenWatercolorLayer();
      default:
        return const SizedBox.shrink();
    }
  }

  void _updateVisibleRegion() {
    final bounds = _mapController.bounds;
    if (bounds != null) {
      boundsNotifier.value = ZoomedBounds(
        west: bounds.west,
        south: bounds.south,
        east: bounds.east,
        north: bounds.north,
        zoom: _mapController.zoom,
      );
    }
  }

  Future<void> _zoomBy(double amount) async {
    final endZoom = (_mapController.zoom + amount).clamp(_zoomMin, _zoomMax);
    widget.onUserZoomChange?.call(endZoom);

    final zoomTween = Tween<double>(begin: _mapController.zoom, end: endZoom);
    await _animateCamera((animation) => _mapController.move(_mapController.center, zoomTween.evaluate(animation)));
  }

  Future<void> _moveTo(LatLng point) async {
    final centerTween = LatLngTween(begin: _mapController.center, end: point);
    await _animateCamera((animation) => _mapController.move(centerTween.evaluate(animation)!, _mapController.zoom));
  }

  Future<void> _animateCamera(void Function(Animation<double> animation) animate) async {
    final controller = AnimationController(duration: _cameraAnimationDuration, vsync: this);
    final animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);
    controller.addListener(() => animate(animation));
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });
    await controller.forward();
  }
}
