import 'dart:async';
import 'dart:typed_data';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/maps/common.dart';
import 'package:aves/widgets/fullscreen/info/maps/marker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuple/tuple.dart';

class EntryGoogleMap extends StatefulWidget {
  final LatLng latLng;
  final String geoUri;
  final double initialZoom;
  final String markerId;
  final WidgetBuilder markerBuilder;

  EntryGoogleMap({
    Key key,
    Tuple2<double, double> latLng,
    this.geoUri,
    this.initialZoom,
    this.markerId,
    this.markerBuilder,
  })  : latLng = LatLng(latLng.item1, latLng.item2),
        super(key: key);

  @override
  State<StatefulWidget> createState() => EntryGoogleMapState();
}

class EntryGoogleMapState extends State<EntryGoogleMap> with AutomaticKeepAliveClientMixin {
  GoogleMapController _controller;
  Completer<Uint8List> _markerLoaderCompleter;

  @override
  void initState() {
    super.initState();
    _markerLoaderCompleter = Completer<Uint8List>();
  }

  @override
  void didUpdateWidget(EntryGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latLng != oldWidget.latLng && _controller != null) {
      _controller.moveCamera(CameraUpdate.newLatLng(widget.latLng));
    }
    if (widget.markerId != oldWidget.markerId) {
      _markerLoaderCompleter = Completer<Uint8List>();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      children: [
        MarkerGeneratorWidget(
          key: Key(widget.markerId),
          markers: [widget.markerBuilder(context)],
          onComplete: (bitmaps) => _markerLoaderCompleter.complete(bitmaps.first),
        ),
        MapDecorator(
          child: _buildMap(),
        ),
        MapButtonPanel(
          geoUri: widget.geoUri,
          zoomBy: _zoomBy,
        ),
      ],
    );
  }

  Widget _buildMap() {
    return FutureBuilder<Uint8List>(
        future: _markerLoaderCompleter.future,
        builder: (context, snapshot) {
          final markers = <Marker>{};
          if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
            final markerBytes = snapshot.data;
            markers.add(Marker(
              markerId: MarkerId(widget.markerId),
              icon: BitmapDescriptor.fromBytes(markerBytes),
              position: widget.latLng,
            ));
          }
          return GoogleMap(
            // GoogleMap init perf issue: https://github.com/flutter/flutter/issues/28493
            initialCameraPosition: CameraPosition(
              target: widget.latLng,
              zoom: widget.initialZoom,
            ),
            onMapCreated: (controller) => setState(() => _controller = controller),
            compassEnabled: false,
            mapToolbarEnabled: false,
            mapType: _toMapStyle(settings.infoMapStyle),
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            liteModeEnabled: false,
            // no camera animation in lite mode
            tiltGesturesEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            markers: markers,
          );
        });
  }

  void _zoomBy(double amount) {
    settings.infoMapZoom += amount;
    _controller.animateCamera(CameraUpdate.zoomBy(amount));
  }

  MapType _toMapStyle(EntryMapStyle style) {
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

  @override
  bool get wantKeepAlive => true;
}
