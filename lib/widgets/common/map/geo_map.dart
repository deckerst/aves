import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/images.dart';
import 'package:aves/model/entry/extensions/location.dart';
import 'package:aves/model/entry/sort.dart';
import 'package:aves/model/settings/enums/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/poi.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/common/map/attribution.dart';
import 'package:aves/widgets/common/map/buttons/panel.dart';
import 'package:aves/widgets/common/map/decorator.dart';
import 'package:aves/widgets/common/map/leaflet/map.dart';
import 'package:aves/widgets/common/thumbnail/image.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/common.dart';
import 'package:aves/widgets/dialogs/selection_dialogs/single_selection.dart';
import 'package:aves_map/aves_map.dart';
import 'package:aves_utils/aves_utils.dart';
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
  final void Function(
    LatLng markerLocation,
    AvesEntry markerEntry,
  )? onMarkerTap;
  final void Function(
    LatLng markerLocation,
    AvesEntry markerEntry,
    Set<AvesEntry> clusterEntries,
    Offset tapLocalPosition,
    WidgetBuilder markerBuilder,
  )? onMarkerLongPress;
  final void Function(BuildContext context)? openMapPage;

  const GeoMap({
    super.key,
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
    this.onMarkerLongPress,
    this.openMapPage,
  });

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
    return Selector<Settings, EntryMapStyle?>(
      selector: (context, s) => s.mapStyle,
      builder: (context, mapStyle, child) {
        final isHeavy = ExtraEntryMapStyle.isHeavy(mapStyle);
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

        final controller = widget.controller;
        Widget child = const SizedBox();
        if (mapStyle != null) {
          switch (mapStyle) {
            case EntryMapStyle.googleNormal:
            case EntryMapStyle.googleHybrid:
            case EntryMapStyle.googleTerrain:
            case EntryMapStyle.hmsNormal:
            case EntryMapStyle.hmsTerrain:
              child = mobileServices.buildMap<AvesEntry>(
                controller: controller,
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
                onMarkerLongPress: _onMarkerLongPress,
              );
              break;
            case EntryMapStyle.osmHot:
            case EntryMapStyle.stamenToner:
            case EntryMapStyle.stamenWatercolor:
              child = EntryLeafletMap<AvesEntry>(
                controller: controller,
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
                  MapThemeData.markerDotDiameter + MapThemeData.markerOuterBorderWidth * 2,
                  MapThemeData.markerDotDiameter + MapThemeData.markerOuterBorderWidth * 2,
                ),
                overlayOpacityNotifier: widget.overlayOpacityNotifier,
                overlayEntry: widget.overlayEntry,
                onUserZoomChange: widget.onUserZoomChange,
                onMapTap: widget.onMapTap,
                onMarkerTap: _onMarkerTap,
                onMarkerLongPress: _onMarkerLongPress,
              );
              break;
          }
        } else {
          final overlay = Center(
            child: OverlayTextButton(
              onPressed: () => showSelectionDialog<EntryMapStyle>(
                context: context,
                builder: (context) => AvesSingleSelectionDialog<EntryMapStyle?>(
                  initialValue: settings.mapStyle,
                  options: Map.fromEntries(availability.mapStyles.map((v) => MapEntry(v, v.getName(context)))),
                  title: context.l10n.mapStyleDialogTitle,
                ),
                onSelection: (v) => settings.mapStyle = v,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(AIcons.layers),
                  const SizedBox(width: 8),
                  Text(context.l10n.mapStyleTooltip),
                ],
              ),
            ),
          );
          child = _decorateMap(context, overlay);
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
                    controller: controller,
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
      // fit map to overlaid item
      final corner1 = overlayEntry.topLeft;
      final corner2 = overlayEntry.bottomRight;
      if (corner1 != null && corner2 != null) {
        bounds = ZoomedBounds.fromPoints(
          points: {corner1, corner2},
        );
      }
    }
    if (bounds == null) {
      LatLng? centerToSave;
      final initialCenter = widget.initialCenter;
      if (initialCenter != null) {
        // fit map for specified center and user zoom
        bounds = ZoomedBounds.fromPoints(
          points: {initialCenter},
          collocationZoom: settings.infoMapZoom,
        );
        centerToSave = initialCenter;
      } else {
        // fit map for all located items if possible, falling back to most recent items
        bounds = _initBoundsForEntries(entries: entries);
        centerToSave = bounds?.projectedCenter;
      }

      if (centerToSave != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          settings.mapDefaultCenter = centerToSave;
        });
      }
    }
    if (bounds == null) {
      // fallback to default center
      var center = settings.mapDefaultCenter;
      if (center == null) {
        center = PointsOfInterest.wonders[Random().nextInt(PointsOfInterest.wonders.length)];
        WidgetsBinding.instance.addPostFrameCallback((_) => settings.mapDefaultCenter = center);
      }
      bounds = ZoomedBounds.fromPoints(
        points: {center},
        collocationZoom: settings.infoMapZoom,
      );
    }

    return bounds.copyWith(
      zoom: max(bounds.zoom, minInitialZoom),
    );
  }

  ZoomedBounds? _initBoundsForEntries({required List<AvesEntry> entries, int? recentCount}) {
    if (recentCount != null) {
      entries = List.of(entries)..sort(AvesEntrySort.compareByDate);
      entries = entries.take(recentCount).toList();
    }

    if (entries.isEmpty) return null;

    final points = entries.map((v) => v.latLng!).toSet();
    var bounds = ZoomedBounds.fromPoints(
      points: points,
      collocationZoom: settings.infoMapZoom,
    );
    bounds = bounds.copyWith(zoom: max(minInitialZoom, bounds.zoom.floorToDouble()));

    final availableSize = window.physicalSize / window.devicePixelRatio;
    final neededSize = bounds.toDisplaySize();
    if (neededSize.width > availableSize.width || neededSize.height > availableSize.height) {
      return _initBoundsForEntries(entries: entries, recentCount: (recentCount ?? 10000) ~/ 10);
    }
    return bounds;
  }

  void _onCollectionChanged() {
    _defaultMarkerCluster = _buildFluster();
    _slowMarkerCluster = null;
    _clusterChangeNotifier.notify();
  }

  Fluster<GeoEntry<AvesEntry>> _buildFluster({int nodeSize = 64}) {
    final markers = entries
        .map((entry) {
          final latLng = entry.latLng;
          return latLng != null
              ? GeoEntry<AvesEntry>(
                  entry: entry,
                  latitude: latLng.latitude,
                  longitude: latLng.longitude,
                  markerId: entry.uri,
                )
              : null;
        })
        .whereNotNull()
        .toList();

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

  Set<AvesEntry> _getClusterEntries(GeoEntry<AvesEntry> geoEntry) {
    final clusterId = geoEntry.clusterId;
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

    final markerLocation = LatLng(geoEntry.latitude!, geoEntry.longitude!);
    onTap(markerLocation, markerEntry);
  }

  Future<void> _onMarkerLongPress(GeoEntry<AvesEntry> geoEntry, LatLng tapLocation) async {
    final onMarkerLongPress = widget.onMarkerLongPress;
    if (onMarkerLongPress == null) return;

    final clusterEntries = _getClusterEntries(geoEntry);
    final tapLocalPosition = _boundsNotifier.value.offset(tapLocation);

    AvesEntry markerEntry;
    if (geoEntry.isCluster!) {
      final uri = geoEntry.childMarkerId;
      markerEntry = entries.firstWhere((v) => v.uri == uri);
    } else {
      markerEntry = geoEntry.entry!;
    }
    final markerLocation = LatLng(geoEntry.latitude!, geoEntry.longitude!);
    Widget markerBuilder(BuildContext context) => ImageMarker(
          count: geoEntry.pointsSize,
          drawArrow: false,
          buildThumbnailImage: (extent) => ThumbnailImage(
            entry: markerEntry,
            extent: extent,
          ),
        );
    onMarkerLongPress(
      markerLocation,
      markerEntry,
      clusterEntries,
      tapLocalPosition,
      markerBuilder,
    );
  }

  Widget _decorateMap(BuildContext context, Widget? child) => MapDecorator(child: child);

  Widget _buildButtonPanel(VoidCallback resetRotation) {
    if (settings.useTvLayout) return const SizedBox();
    return MapButtonPanel(
      controller: widget.controller,
      boundsNotifier: _boundsNotifier,
      openMapPage: widget.openMapPage,
      resetRotation: resetRotation,
    );
  }
}
