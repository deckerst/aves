import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/maps/common.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tuple/tuple.dart';

class EntryGoogleMap extends StatefulWidget {
  final String markerId;
  final LatLng latLng;
  final String geoUri;
  final double initialZoom;

  EntryGoogleMap({
    Key key,
    this.markerId,
    Tuple2<double, double> latLng,
    this.geoUri,
    this.initialZoom,
  })  : latLng = LatLng(latLng.item1, latLng.item2),
        super(key: key);

  @override
  State<StatefulWidget> createState() => EntryGoogleMapState();
}

class EntryGoogleMapState extends State<EntryGoogleMap> with AutomaticKeepAliveClientMixin {
  GoogleMapController _controller;

  @override
  void didUpdateWidget(EntryGoogleMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latLng != oldWidget.latLng && _controller != null) {
      _controller.moveCamera(CameraUpdate.newLatLng(widget.latLng));
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
    final accentHue = HSVColor.fromColor(Theme.of(context).accentColor).hue;
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
      markers: {
        Marker(
          markerId: MarkerId(widget.markerId),
          icon: BitmapDescriptor.defaultMarkerWithHue(accentHue),
          position: widget.latLng,
        )
      },
    );
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
