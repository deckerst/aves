import 'dart:async';
import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/settings/enums/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/change_notifier.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/map/attribution.dart';
import 'package:aves/widgets/common/map/buttons/panel.dart';
import 'package:aves/widgets/common/map/decorator.dart';
import 'package:aves/widgets/common/map/leaflet/map.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_services_platform/aves_services_platform.dart';
import 'package:collection/collection.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class GeoMap extends StatefulWidget {
  final AvesMapController? controller;
  final Listenable? collectionListenable;
  final List<AvesEntry> entries;
  final LatLng? initialCenter;
  final ValueNotifier<bool> isAnimatingNotifier;
  final ValueNotifier<LatLng?>? dotLocationNotifier;
  final ValueNotifier<double>? overlayOpacityNotifier;
  final MapOverlay? overlayEntry;
  final UserZoomChangeCallback? onUserZoomChange;
  final MapTapCallback? onMapTap;
  final void Function(LatLng averageLocation, AvesEntry markerEntry, Set<AvesEntry> Function() getClusterEntries)? onMarkerTap;
  final void Function(BuildContext context)? openMapPage;

  const GeoMap({
    Key? key,
    this.controller,
    this.collectionListenable,
    required this.entries,
    this.initialCenter,
    required this.isAnimatingNotifier,
    this.dotLocationNotifier,
    this.overlayOpacityNotifier,
    this.overlayEntry,
    this.onUserZoomChange,
    this.onMapTap,
    this.onMarkerTap,
    this.openMapPage,
  }) : super(key: key);

  @override
  State<GeoMap> createState() => _GeoMapState();
}

class _GeoMapState extends State<GeoMap> {
  final List<StreamSubscription> _subscriptions = [];

  // as of google_maps_flutter v2.0.6, Google map initialization is blocking
  // cf https://github.com/flutter/flutter/issues/28493
  // it is especially severe the first time, but still significant afterwards
  // so we prevent loading it while scrolling or animating
  bool _heavyMapLoaded = false;
  late final ValueNotifier<ZoomedBounds> _boundsNotifier;
  Fluster<GeoEntry<AvesEntry>>? _defaultMarkerCluster;
  Fluster<GeoEntry<AvesEntry>>? _slowMarkerCluster;
  final AChangeNotifier _clusterChangeNotifier = AChangeNotifier();

  List<AvesEntry> get entries => widget.entries;

  static final _platformMobileServices = PlatformMobileServices();

  // cap initial zoom to avoid a zoom change
  // when toggling overlay on Google map initial state
  static const double minInitialZoom = 3;

  @override
  void initState() {
    super.initState();
    _boundsNotifier = ValueNotifier(_initBounds());
    _registerWidget(widget);
    _onCollectionChanged();
  }

  @override
  void didUpdateWidget(covariant GeoMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(GeoMap widget) {
    widget.collectionListenable?.addListener(_onCollectionChanged);
    final controller = widget.controller;
    if (controller != null) {
      _subscriptions.add(controller.markerLocationChanges.listen((event) => _onCollectionChanged()));
    }
  }

  void _unregisterWidget(GeoMap widget) {
    widget.collectionListenable?.removeListener(_onCollectionChanged);
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    void _onMarkerTap(GeoEntry<AvesEntry> geoEntry) {
      final onTap = widget.onMarkerTap;
      if (onTap == null) return;

      final clusterId = geoEntry.clusterId;
      AvesEntry? markerEntry;
      if (clusterId != null) {
        final uri = geoEntry.childMarkerId;
        markerEntry = entries.firstWhereOrNull((v) => v.uri == uri);
      } else {
        markerEntry = geoEntry.entry;
      }

      if (markerEntry == null) return;

      Set<AvesEntry> getClusterEntries() {
        if (clusterId == null) {
          return {geoEntry.entry!};
        }

        var points = _defaultMarkerCluster?.points(clusterId) ?? [];
        if (points.length != geoEntry.pointsSize) {
          // `Fluster.points()` method does not always return all the points contained in a cluster
          // the higher `nodeSize` is, the higher the chance to get all the points (i.e. as many as the cluster `pointsSize`)
          _slowMarkerCluster ??= _buildFluster(nodeSize: smallestPowerOf2(entries.length));
          points = _slowMarkerCluster!.points(clusterId);
          assert(points.length == geoEntry.pointsSize, 'got ${points.length}/${geoEntry.pointsSize} for geoEntry=$geoEntry');
        }
        return points.map((geoEntry) => geoEntry.entry!).toSet();
      }

      final clusterAverageLocation = LatLng(geoEntry.latitude!, geoEntry.longitude!);
      onTap(clusterAverageLocation, markerEntry, getClusterEntries);
    }

    return Selector<Settings, EntryMapStyle>(
      selector: (context, s) => s.infoMapStyle,
      builder: (context, mapStyle, child) {
        final isHeavy = mapStyle.isHeavy;
        Widget _buildMarkerWidget(MarkerKey<AvesEntry> key) => ImageMarker(
              key: key,
              count: key.count,
              buildThumbnailImage: (extent) => ThumbnailImage(
                entry: key.entry,
                extent: extent,
                progressive: !isHeavy,
              ),
            );
        bool _isMarkerImageReady(MarkerKey<AvesEntry> key) => key.entry.isThumbnailReady(extent: MapThemeData.markerImageExtent);

        Widget child = const SizedBox();
        switch (mapStyle) {
          case EntryMapStyle.googleNormal:
          case EntryMapStyle.googleHybrid:
          case EntryMapStyle.googleTerrain:
          case EntryMapStyle.hmsNormal:
          case EntryMapStyle.hmsTerrain:
            child = _platformMobileServices.buildMap<AvesEntry>(
              controller: widget.controller,
              clusterListenable: _clusterChangeNotifier,
              boundsNotifier: _boundsNotifier,
              style: mapStyle,
              decoratorBuilder: _decorateMap,
              buttonPanelBuilder: _buildButtonPanel,
              markerClusterBuilder: _buildMarkerClusters,
              markerWidgetBuilder: _buildMarkerWidget,
              markerImageReadyChecker: _isMarkerImageReady,
              dotLocationNotifier: widget.dotLocationNotifier,
              overlayOpacityNotifier: widget.overlayOpacityNotifier,
              overlayEntry: widget.overlayEntry,
              onUserZoomChange: widget.onUserZoomChange,
              onMapTap: widget.onMapTap,
              onMarkerTap: _onMarkerTap,
            );
            break;
          case EntryMapStyle.osmHot:
          case EntryMapStyle.stamenToner:
          case EntryMapStyle.stamenWatercolor:
            child = EntryLeafletMap<AvesEntry>(
              controller: widget.controller,
              clusterListenable: _clusterChangeNotifier,
              boundsNotifier: _boundsNotifier,
              minZoom: 2,
              maxZoom: 16,
              style: mapStyle,
              decoratorBuilder: _decorateMap,
              buttonPanelBuilder: _buildButtonPanel,
              markerClusterBuilder: _buildMarkerClusters,
              markerWidgetBuilder: _buildMarkerWidget,
              dotLocationNotifier: widget.dotLocationNotifier,
              markerSize: Size(
                MapThemeData.markerImageExtent + MapThemeData.markerOuterBorderWidth * 2,
                MapThemeData.markerImageExtent + MapThemeData.markerOuterBorderWidth * 2 + MapThemeData.markerArrowSize.height,
              ),
              dotMarkerSize: const Size(
                DotMarker.diameter + MapThemeData.markerOuterBorderWidth * 2,
                DotMarker.diameter + MapThemeData.markerOuterBorderWidth * 2,
              ),
              overlayOpacityNotifier: widget.overlayOpacityNotifier,
              overlayEntry: widget.overlayEntry,
              onUserZoomChange: widget.onUserZoomChange,
              onMapTap: widget.onMapTap,
              onMarkerTap: _onMarkerTap,
            );
            break;
        }

        final mapHeight = context.select<MapThemeData, double?>((v) => v.mapHeight);
        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mapHeight != null
                ? SizedBox(
                    height: mapHeight,
                    child: child,
                  )
                : Expanded(child: child),
            SafeArea(
              top: false,
              bottom: false,
              child: Attribution(style: mapStyle),
            ),
          ],
        );

        return AnimatedSize(
          alignment: Alignment.topCenter,
          curve: Curves.easeInOutCubic,
          duration: Durations.mapStyleSwitchAnimation,
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.isAnimatingNotifier,
            builder: (context, animating, child) {
              if (!animating && isHeavy) {
                _heavyMapLoaded = true;
              }
              Widget replacement = Stack(
                children: [
                  const MapDecorator(),
                  MapButtonPanel(
                    boundsNotifier: _boundsNotifier,
                    openMapPage: widget.openMapPage,
                  ),
                ],
              );
              if (mapHeight != null) {
                replacement = SizedBox(
                  height: mapHeight,
                  child: replacement,
                );
              }
              return Visibility(
                visible: !isHeavy || _heavyMapLoaded,
                replacement: replacement,
                child: child!,
              );
            },
            child: child,
          ),
        );
      },
    );
  }

  ZoomedBounds _initBounds() {
    ZoomedBounds? bounds;

    final overlayEntry = widget.overlayEntry;
    if (overlayEntry != null) {
      final corner1 = overlayEntry.topLeft;
      final corner2 = overlayEntry.bottomRight;
      if (corner1 != null && corner2 != null) {
        bounds = ZoomedBounds.fromPoints(
          points: {corner1, corner2},
        );
      }
    }
    if (bounds == null) {
      final initialCenter = widget.initialCenter;
      final points = initialCenter != null ? {initialCenter} : entries.map((v) => v.latLng!).toSet();
      bounds = ZoomedBounds.fromPoints(
        points: points.isNotEmpty ? points : {Constants.wonders[Random().nextInt(Constants.wonders.length)]},
        collocationZoom: settings.infoMapZoom,
      );
    }

    return bounds.copyWith(
      zoom: max(bounds.zoom, minInitialZoom),
    );
  }

  void _onCollectionChanged() {
    _defaultMarkerCluster = _buildFluster();
    _slowMarkerCluster = null;
    _clusterChangeNotifier.notify();
  }

  Fluster<GeoEntry<AvesEntry>> _buildFluster({int nodeSize = 64}) {
    final markers = entries.map((entry) {
      final latLng = entry.latLng!;
      return GeoEntry<AvesEntry>(
        entry: entry,
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        markerId: entry.uri,
      );
    }).toList();

    return Fluster<GeoEntry<AvesEntry>>(
      // we keep clustering on the whole range of zooms (including the maximum)
      // to avoid collocated entries overlapping
      minZoom: 0,
      maxZoom: 22,
      // TODO TLAD [map] derive `radius` / `extent`, from device pixel ratio and marker extent?
      // (radius=120, extent=2 << 8) is equivalent to (radius=240, extent=2 << 9)
      radius: 240,
      extent: 2 << 9,
      // node size: 64 by default, higher means faster indexing but slower search
      nodeSize: nodeSize,
      points: markers,
      // use lambda instead of tear-off because of runtime exception when using
      // `T Function(BaseCluster, double, double)` for `T Function(BaseCluster?, double?, double?)`
      // ignore: unnecessary_lambdas
      createCluster: (base, lng, lat) => GeoEntry<AvesEntry>.createCluster(base, lng, lat),
    );
  }

  Map<MarkerKey<AvesEntry>, GeoEntry<AvesEntry>> _buildMarkerClusters() {
    final bounds = _boundsNotifier.value;
    final geoEntries = _defaultMarkerCluster?.clusters(bounds.boundingBox, bounds.zoom.round()) ?? [];
    return Map.fromEntries(geoEntries.map((v) {
      if (v.isCluster!) {
        final uri = v.childMarkerId;
        final entry = entries.firstWhere((v) => v.uri == uri);
        return MapEntry(MarkerKey(entry, v.pointsSize), v);
      }
      return MapEntry(MarkerKey(v.entry!, null), v);
    }));
  }

  Widget _decorateMap(BuildContext context, Widget? child) => MapDecorator(child: child);

  Widget _buildButtonPanel(
    Future<void> Function(double amount) zoomBy,
    VoidCallback resetRotation,
  ) =>
      MapButtonPanel(
        boundsNotifier: _boundsNotifier,
        zoomBy: zoomBy,
        openMapPage: widget.openMapPage,
        resetRotation: resetRotation,
      );
}
