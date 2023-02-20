import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/debouncer.dart';
import 'package:aves/widgets/common/map/leaflet/latlng_tween.dart';
import 'package:aves/widgets/common/map/leaflet/scale_layer.dart';
import 'package:aves/widgets/common/map/leaflet/tile_layers.dart';
import 'package:aves_map/aves_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class EntryLeafletMap<T> extends StatefulWidget {
  final AvesMapController? controller;
  final Listenable clusterListenable;
  final ValueNotifier<ZoomedBounds> boundsNotifier;
  final double minZoom, maxZoom;
  final EntryMapStyle style;
  final TransitionBuilder decoratorBuilder;
  final ButtonPanelBuilder buttonPanelBuilder;
  final MarkerClusterBuilder<T> markerClusterBuilder;
  final MarkerWidgetBuilder<T> markerWidgetBuilder;
  final ValueNotifier<LatLng?>? dotLocationNotifier;
  final Size markerSize, dotMarkerSize;
  final ValueNotifier<double>? overlayOpacityNotifier;
  final MapOverlay? overlayEntry;
  final UserZoomChangeCallback? onUserZoomChange;
  final MapTapCallback? onMapTap;
  final MarkerTapCallback<T>? onMarkerTap;
  final MarkerLongPressCallback<T>? onMarkerLongPress;

  const EntryLeafletMap({
    super.key,
    this.controller,
    required this.clusterListenable,
    required this.boundsNotifier,
    this.minZoom = 0,
    this.maxZoom = 22,
    required this.style,
    required this.decoratorBuilder,
    required this.buttonPanelBuilder,
    required this.markerClusterBuilder,
    required this.markerWidgetBuilder,
    required this.dotLocationNotifier,
    required this.markerSize,
    required this.dotMarkerSize,
    this.overlayOpacityNotifier,
    this.overlayEntry,
    this.onUserZoomChange,
    this.onMapTap,
    this.onMarkerTap,
    this.onMarkerLongPress,
  });

  @override
  State<EntryLeafletMap<T>> createState() => _EntryLeafletMapState<T>();
}

class _EntryLeafletMapState<T> extends State<EntryLeafletMap<T>> with TickerProviderStateMixin {
  final MapController _leafletMapController = MapController();
  final List<StreamSubscription> _subscriptions = [];
  Map<MarkerKey<T>, GeoEntry<T>> _geoEntryByMarkerKey = {};
  final Debouncer _debouncer = Debouncer(delay: Durations.mapIdleDebounceDelay);

  ValueNotifier<ZoomedBounds> get boundsNotifier => widget.boundsNotifier;

  ZoomedBounds get bounds => boundsNotifier.value;

  // duration should match the uncustomizable Google map duration
  static const _cameraAnimationDuration = Duration(milliseconds: 600);

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateVisibleRegion());
  }

  @override
  void didUpdateWidget(covariant EntryLeafletMap<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(EntryLeafletMap<T> widget) {
    final avesMapController = widget.controller;
    if (avesMapController != null) {
      _subscriptions.add(avesMapController.moveCommands.listen((event) => _moveTo(event.latLng)));
      _subscriptions.add(avesMapController.zoomCommands.listen((event) => _zoomBy(event.delta)));
    }
    _subscriptions.add(_leafletMapController.mapEventStream.listen((event) => _updateVisibleRegion()));
    widget.clusterListenable.addListener(_updateMarkers);
    widget.boundsNotifier.addListener(_onBoundsChanged);
  }

  void _unregisterWidget(EntryLeafletMap<T> widget) {
    widget.clusterListenable.removeListener(_updateMarkers);
    widget.boundsNotifier.removeListener(_onBoundsChanged);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.decoratorBuilder(context, _buildMap()),
        widget.buttonPanelBuilder(_resetRotation),
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
          onLongPress: () => widget.onMarkerLongPress?.call(geoEntry, LatLng(geoEntry.latitude!, geoEntry.longitude!)),
          child: widget.markerWidgetBuilder(markerKey),
        ),
        width: markerSize.width,
        height: markerSize.height,
        anchorPos: AnchorPos.align(AnchorAlign.top),
      );
    }).toList();

    return FlutterMap(
      options: MapOptions(
        center: bounds.projectedCenter,
        zoom: bounds.zoom,
        rotation: bounds.rotation,
        minZoom: widget.minZoom,
        maxZoom: widget.maxZoom,
        // TODO TLAD [map] as of flutter_map v0.14.0, `doubleTapZoom` does not move when zoom is already maximal
        // this could be worked around with https://github.com/fleaflet/flutter_map/pull/960
        interactiveFlags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
        // prevent triggering multiple gestures at once (e.g. rotating a bit when mostly zooming)
        enableMultiFingerGestureRace: true,
        onTap: (tapPosition, point) => widget.onMapTap?.call(point),
      ),
      mapController: _leafletMapController,
      nonRotatedChildren: [
        ScaleLayerWidget(
          options: ScaleLayerOptions(
            unitSystem: settings.unitSystem,
          ),
        ),
      ],
      children: [
        _buildMapLayer(),
        if (widget.overlayEntry != null) _buildOverlayImageLayer(),
        MarkerLayer(
          markers: markers,
          rotate: true,
          rotateAlignment: Alignment.bottomCenter,
        ),
        ValueListenableBuilder<LatLng?>(
          valueListenable: widget.dotLocationNotifier ?? ValueNotifier(null),
          builder: (context, dotLocation, child) => MarkerLayer(
            markers: [
              if (dotLocation != null)
                Marker(
                  point: dotLocation,
                  builder: (context) => const DotMarker(),
                  width: dotMarkerSize.width,
                  height: dotMarkerSize.height,
                )
            ],
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
        return const SizedBox();
    }
  }

  Widget _buildOverlayImageLayer() {
    final overlayEntry = widget.overlayEntry;
    if (overlayEntry == null) return const SizedBox();

    final corner1 = overlayEntry.topLeft;
    final corner2 = overlayEntry.bottomRight;
    if (corner1 == null || corner2 == null) return const SizedBox();

    return ValueListenableBuilder<double>(
      valueListenable: widget.overlayOpacityNotifier ?? ValueNotifier(1),
      builder: (context, overlayOpacity, child) {
        return OverlayImageLayer(
          overlayImages: [
            OverlayImage(
              bounds: LatLngBounds(corner1, corner2),
              imageProvider: overlayEntry.imageProvider,
              opacity: overlayOpacity,
            ),
          ],
        );
      },
    );
  }

  void _onBoundsChanged() => _debouncer(_onIdle);

  void _onIdle() {
    if (!mounted) return;
    widget.controller?.notifyIdle(bounds);
    _updateMarkers();
  }

  void _updateMarkers() {
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
