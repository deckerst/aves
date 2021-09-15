import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/enums.dart';
import 'package:aves/model/settings/map_style.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/map/attribution.dart';
import 'package:aves/widgets/common/map/buttons.dart';
import 'package:aves/widgets/common/map/controller.dart';
import 'package:aves/widgets/common/map/decorator.dart';
import 'package:aves/widgets/common/map/geo_entry.dart';
import 'package:aves/widgets/common/map/google/map.dart';
import 'package:aves/widgets/common/map/leaflet/map.dart';
import 'package:aves/widgets/common/map/marker.dart';
import 'package:aves/widgets/common/map/zoomed_bounds.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GeoMap extends StatefulWidget {
  final AvesMapController? controller;
  final List<AvesEntry> entries;
  final bool interactive, showBackButton;
  final double? mapHeight;
  final ValueNotifier<bool> isAnimatingNotifier;
  final UserZoomChangeCallback? onUserZoomChange;
  final MarkerTapCallback? onMarkerTap;

  static const markerImageExtent = 48.0;
  static const pointerSize = Size(8, 6);

  const GeoMap({
    Key? key,
    this.controller,
    required this.entries,
    required this.interactive,
    required this.showBackButton,
    this.mapHeight,
    required this.isAnimatingNotifier,
    this.onUserZoomChange,
    this.onMarkerTap,
  }) : super(key: key);

  @override
  _GeoMapState createState() => _GeoMapState();
}

class _GeoMapState extends State<GeoMap> {
  // as of google_maps_flutter v2.0.6, Google Maps initialization is blocking
  // cf https://github.com/flutter/flutter/issues/28493
  // it is especially severe the first time, but still significant afterwards
  // so we prevent loading it while scrolling or animating
  bool _googleMapsLoaded = false;
  late final ValueNotifier<ZoomedBounds> _boundsNotifier;
  late final Fluster<GeoEntry> _defaultMarkerCluster;
  Fluster<GeoEntry>? _slowMarkerCluster;

  List<AvesEntry> get entries => widget.entries;

  bool get interactive => widget.interactive;

  bool get showBackButton => widget.showBackButton;

  double? get mapHeight => widget.mapHeight;

  @override
  void initState() {
    super.initState();
    final points = entries.map((v) => v.latLng!).toSet();
    _boundsNotifier = ValueNotifier(ZoomedBounds.fromPoints(
      points: points.isNotEmpty ? points : {Constants.wonders[Random().nextInt(Constants.wonders.length)]},
      collocationZoom: settings.infoMapZoom,
    ));
    _defaultMarkerCluster = _buildFluster();
  }

  @override
  Widget build(BuildContext context) {
    void _onMarkerTap(GeoEntry geoEntry) {
      final onTap = widget.onMarkerTap;
      if (onTap == null) return;

      final clusterId = geoEntry.clusterId;
      Set<AvesEntry> getClusterEntries() {
        if (clusterId == null) {
          return {geoEntry.entry!};
        }

        var points = _defaultMarkerCluster.points(clusterId);
        if (points.length != geoEntry.pointsSize) {
          // `Fluster.points()` method does not always return all the points contained in a cluster
          // the higher `nodeSize` is, the higher the chance to get all the points (i.e. as many as the cluster `pointsSize`)
          _slowMarkerCluster ??= _buildFluster(nodeSize: smallestPowerOf2(widget.entries.length));
          points = _slowMarkerCluster!.points(clusterId);
          assert(points.length == geoEntry.pointsSize, 'got ${points.length}/${geoEntry.pointsSize} for geoEntry=$geoEntry');
        }
        return points.map((geoEntry) => geoEntry.entry!).toSet();
      }

      AvesEntry? markerEntry;
      if (clusterId != null) {
        final uri = geoEntry.childMarkerId;
        markerEntry = entries.firstWhereOrNull((v) => v.uri == uri);
      } else {
        markerEntry = geoEntry.entry;
      }

      if (markerEntry != null) {
        onTap(markerEntry, getClusterEntries);
      }
    }

    return FutureBuilder<bool>(
      future: availability.isConnected,
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox();
        return Selector<Settings, EntryMapStyle>(
          selector: (context, s) => s.infoMapStyle,
          builder: (context, mapStyle, child) {
            final isGoogleMaps = mapStyle.isGoogleMaps;
            final progressive = !isGoogleMaps;
            Widget _buildMarkerWidget(MarkerKey key) => ImageMarker(
                  key: key,
                  entry: key.entry,
                  count: key.count,
                  extent: GeoMap.markerImageExtent,
                  pointerSize: GeoMap.pointerSize,
                  progressive: progressive,
                );

            Widget child = isGoogleMaps
                ? EntryGoogleMap(
                    controller: widget.controller,
                    boundsNotifier: _boundsNotifier,
                    interactive: interactive,
                    showBackButton: showBackButton,
                    minZoom: 0,
                    maxZoom: 20,
                    style: mapStyle,
                    markerClusterBuilder: _buildMarkerClusters,
                    markerWidgetBuilder: _buildMarkerWidget,
                    onUserZoomChange: widget.onUserZoomChange,
                    onMarkerTap: _onMarkerTap,
                  )
                : EntryLeafletMap(
                    controller: widget.controller,
                    boundsNotifier: _boundsNotifier,
                    interactive: interactive,
                    showBackButton: showBackButton,
                    minZoom: 2,
                    maxZoom: 16,
                    style: mapStyle,
                    markerClusterBuilder: _buildMarkerClusters,
                    markerWidgetBuilder: _buildMarkerWidget,
                    markerSize: Size(
                      GeoMap.markerImageExtent + ImageMarker.outerBorderWidth * 2,
                      GeoMap.markerImageExtent + ImageMarker.outerBorderWidth * 2 + GeoMap.pointerSize.height,
                    ),
                    onUserZoomChange: widget.onUserZoomChange,
                    onMarkerTap: _onMarkerTap,
                  );

            child = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                mapHeight != null
                    ? SizedBox(
                        height: mapHeight,
                        child: child,
                      )
                    : Expanded(child: child),
                Attribution(style: mapStyle),
              ],
            );

            return AnimatedSize(
              alignment: Alignment.topCenter,
              curve: Curves.easeInOutCubic,
              duration: Durations.mapStyleSwitchAnimation,
              child: ValueListenableBuilder<bool>(
                valueListenable: widget.isAnimatingNotifier,
                builder: (context, animating, child) {
                  if (!animating && isGoogleMaps) {
                    _googleMapsLoaded = true;
                  }
                  Widget replacement = Stack(
                    children: [
                      MapDecorator(
                        interactive: interactive,
                      ),
                      MapButtonPanel(
                        showBackButton: showBackButton,
                        boundsNotifier: _boundsNotifier,
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
                    visible: !isGoogleMaps || _googleMapsLoaded,
                    replacement: replacement,
                    child: child!,
                  );
                },
                child: child,
              ),
            );
          },
        );
      },
    );
  }

  Fluster<GeoEntry> _buildFluster({int nodeSize = 64}) {
    final markers = entries.map((entry) {
      final latLng = entry.latLng!;
      return GeoEntry(
        entry: entry,
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        markerId: entry.uri,
      );
    }).toList();

    return Fluster<GeoEntry>(
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
      createCluster: (base, lng, lat) => GeoEntry.createCluster(base, lng, lat),
    );
  }

  Map<MarkerKey, GeoEntry> _buildMarkerClusters() {
    final bounds = _boundsNotifier.value;
    final geoEntries = _defaultMarkerCluster.clusters(bounds.boundingBox, bounds.zoom.round());
    return Map.fromEntries(geoEntries.map((v) {
      if (v.isCluster!) {
        final uri = v.childMarkerId;
        final entry = entries.firstWhere((v) => v.uri == uri);
        return MapEntry(MarkerKey(entry, v.pointsSize), v);
      }
      return MapEntry(MarkerKey(v.entry!, null), v);
    }));
  }
}

@immutable
class MarkerKey extends LocalKey with EquatableMixin {
  final AvesEntry entry;
  final int? count;

  @override
  List<Object?> get props => [entry, count];

  const MarkerKey(this.entry, this.count);
}

typedef MarkerClusterBuilder = Map<MarkerKey, GeoEntry> Function();
typedef MarkerWidgetBuilder = Widget Function(MarkerKey key);
typedef UserZoomChangeCallback = void Function(double zoom);
typedef MarkerTapCallback = void Function(AvesEntry markerEntry, Set<AvesEntry> Function() getClusterEntries);
