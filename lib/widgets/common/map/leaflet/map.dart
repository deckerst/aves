import 'dart:async';

import 'package:aves/model/entry.dart';
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
import 'package:aves/widgets/common/map/marker.dart';
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
  final ValueNotifier<AvesEntry?>? dotEntryNotifier;
  final Size markerSize, dotMarkerSize;
  final UserZoomChangeCallback? onUserZoomChange;
  final VoidCallback? onMapTap;
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
    required this.dotEntryNotifier,
    required this.markerSize,
    required this.dotMarkerSize,
    this.onUserZoomChange,
    this.onMapTap,
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
      _subscriptions.add(avesMapController.moveCommands.listen((event) => _moveTo(event.latLng)));
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
    final dotMarkerSize = widget.dotMarkerSize;

    final interactive = context.select<MapThemeData, bool>((v) => v.interactive);

    final markers = _geoEntryByMarkerKey.entries.map((kv) {
      final markerKey = kv.key;
      final geoEntry = kv.value;
      final latLng = LatLng(geoEntry.latitude!, geoEntry.longitude!);
      return Marker(
        point: latLng,
        builder: (context) => GestureDetector(
          onTap: () => widget.onMarkerTap?.call(geoEntry),
          // marker tap handling prevents the default handling of focal zoom on double tap,
          // so we reimplement the double tap gesture here
          onDoubleTap: interactive ? () => _zoomBy(1, focalPoint: latLng) : null,
          child: widget.markerWidgetBuilder(markerKey),
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
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
        // TODO TLAD [map] as of flutter_map v0.14.0, `doubleTapZoom` does not move when zoom is already maximal
        // this could be worked around with https://github.com/fleaflet/flutter_map/pull/960
        interactiveFlags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        onTap: (tapPosition, point) => widget.onMapTap?.call(),
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
        ValueListenableBuilder<AvesEntry?>(
          valueListenable: widget.dotEntryNotifier ?? ValueNotifier(null),
          builder: (context, dotEntry, child) => MarkerLayerWidget(
            options: MarkerLayerOptions(
              markers: [
                if (dotEntry != null)
                  Marker(
                    point: dotEntry.latLng!,
                    builder: (context) => const DotMarker(),
                    width: dotMarkerSize.width,
                    height: dotMarkerSize.height,
                  )
              ],
            ),
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

  void _onBoundsChange() => _debouncer(_onIdle);

  void _onIdle() {
    if (!mounted) return;
    widget.controller?.notifyIdle(bounds);
    setState(() => _geoEntryByMarkerKey = widget.markerClusterBuilder());
  }

  void _updateVisibleRegion() {
    final bounds = _leafletMapController.bounds;
    if (bounds != null) {
      boundsNotifier.value = ZoomedBounds(
        sw: bounds.southWest!,
        ne: bounds.northEast!,
        zoom: _leafletMapController.zoom,
        rotation: _leafletMapController.rotation,
      );
    }
  }

  Future<void> _resetRotation() async {
    final rotationTween = Tween<double>(begin: _leafletMapController.rotation, end: 0);
    await _animateCamera((animation) => _leafletMapController.rotate(rotationTween.evaluate(animation)));
  }

  Future<void> _zoomBy(double amount, {LatLng? focalPoint}) async {
    final endZoom = (_leafletMapController.zoom + amount).clamp(widget.minZoom, widget.maxZoom);
    widget.onUserZoomChange?.call(endZoom);

    final center = _leafletMapController.center;
    final centerTween = LatLngTween(begin: center, end: focalPoint ?? center);

    final zoomTween = Tween<double>(begin: _leafletMapController.zoom, end: endZoom);
    await _animateCamera((animation) => _leafletMapController.move(centerTween.evaluate(animation)!, zoomTween.evaluate(animation)));
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
