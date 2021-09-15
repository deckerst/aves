import 'dart:async';

import 'package:aves/model/settings/enums.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/map/buttons.dart';
import 'package:aves/widgets/common/map/controller.dart';
import 'package:aves/widgets/common/map/decorator.dart';
import 'package:aves/widgets/common/map/geo_entry.dart';
import 'package:aves/widgets/common/map/geo_map.dart';
import 'package:aves/widgets/common/map/latlng_tween.dart';
import 'package:aves/widgets/common/map/leaflet/scale_layer.dart';
import 'package:aves/widgets/common/map/leaflet/tile_layers.dart';
import 'package:aves/widgets/common/map/theme.dart';
import 'package:aves/widgets/common/map/zoomed_bounds.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class EntryLeafletMap extends StatefulWidget {
  final AvesMapController? controller;
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final double minZoom, maxZoom;
  final EntryMapStyle style;
  final MarkerClusterBuilder markerClusterBuilder;
  final MarkerWidgetBuilder markerWidgetBuilder;
  final Size markerSize;
  final UserZoomChangeCallback? onUserZoomChange;
  final void Function(GeoEntry geoEntry)? onMarkerTap;
  final MapOpener? openMapPage;

  const EntryLeafletMap({
    Key? key,
    this.controller,
    required this.boundsNotifier,
    this.minZoom = 0,
    this.maxZoom = 22,
    required this.style,
    required this.markerClusterBuilder,
    required this.markerWidgetBuilder,
    required this.markerSize,
    this.onUserZoomChange,
    this.onMarkerTap,
    this.openMapPage,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EntryLeafletMapState();
}

class _EntryLeafletMapState extends State<EntryLeafletMap> with TickerProviderStateMixin {
  final MapController _leafletMapController = MapController();
  final List<StreamSubscription> _subscriptions = [];
  Map<MarkerKey, GeoEntry> _geoEntryByMarkerKey = {};
  final Debouncer _debouncer = Debouncer(delay: Durations.mapIdleDebounceDelay);

  ValueNotifier<ZoomedBounds> get boundsNotifier => widget.boundsNotifier;

  ZoomedBounds get bounds => boundsNotifier.value;

  // duration should match the uncustomizable Google Maps duration
  static const _cameraAnimationDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    WidgetsBinding.instance!.addPostFrameCallback((_) => _updateVisibleRegion());
  }

  @override
  void didUpdateWidget(covariant EntryLeafletMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(EntryLeafletMap widget) {
    final avesMapController = widget.controller;
    if (avesMapController != null) {
      _subscriptions.add(avesMapController.moveEvents.listen((event) => _moveTo(event.latLng)));
    }
    _subscriptions.add(_leafletMapController.mapEventStream.listen((event) => _updateVisibleRegion()));
    boundsNotifier.addListener(_onBoundsChange);
  }

  void _unregisterWidget(EntryLeafletMap widget) {
    boundsNotifier.removeListener(_onBoundsChange);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
    final markerSize = widget.markerSize;
    final markers = _geoEntryByMarkerKey.entries.map((kv) {
      final markerKey = kv.key;
      final geoEntry = kv.value;
      final latLng = LatLng(geoEntry.latitude!, geoEntry.longitude!);
      return Marker(
        point: latLng,
        builder: (context) => GestureDetector(
          onTap: () => widget.onMarkerTap?.call(geoEntry),
          child: widget.markerWidgetBuilder(markerKey),
        ),
        width: markerSize.width,
        height: markerSize.height,
        anchorPos: AnchorPos.align(AnchorAlign.top),
      );
    }).toList();

    final interactive = context.select<MapThemeData, bool>((v) => v.interactive);
    return FlutterMap(
      options: MapOptions(
        center: bounds.center,
        zoom: bounds.zoom,
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
        interactiveFlags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        controller: _leafletMapController,
      ),
      mapController: _leafletMapController,
      nonRotatedChildren: [
        ScaleLayerWidget(
          options: ScaleLayerOptions(),
        ),
      ],
      children: [
        _buildMapLayer(),
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

  void _onBoundsChange() => _debouncer(_updateClusters);

  void _updateClusters() {
    if (!mounted) return;
    setState(() => _geoEntryByMarkerKey = widget.markerClusterBuilder());
  }

  void _updateVisibleRegion() {
    final bounds = _leafletMapController.bounds;
    if (bounds != null) {
      boundsNotifier.value = ZoomedBounds(
        west: bounds.west,
        south: bounds.south,
        east: bounds.east,
        north: bounds.north,
        zoom: _leafletMapController.zoom,
        rotation: _leafletMapController.rotation,
      );
    }
  }

  Future<void> _resetRotation() async {
    final rotationTween = Tween<double>(begin: _leafletMapController.rotation, end: 0);
    await _animateCamera((animation) => _leafletMapController.rotate(rotationTween.evaluate(animation)));
  }

  Future<void> _zoomBy(double amount) async {
    final endZoom = (_leafletMapController.zoom + amount).clamp(widget.minZoom, widget.maxZoom);
    widget.onUserZoomChange?.call(endZoom);

    final zoomTween = Tween<double>(begin: _leafletMapController.zoom, end: endZoom);
    await _animateCamera((animation) => _leafletMapController.move(_leafletMapController.center, zoomTween.evaluate(animation)));
  }

  Future<void> _moveTo(LatLng point) async {
    final centerTween = LatLngTween(begin: _leafletMapController.center, end: point);
    await _animateCamera((animation) => _leafletMapController.move(centerTween.evaluate(animation)!, _leafletMapController.zoom));
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
