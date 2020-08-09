import 'package:aves/model/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/widgets/common/icons.dart';
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
  Widget build(BuildContext context) {
    super.build(context);
    final accentHue = HSVColor.fromColor(Theme.of(context).accentColor).hue;
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onScaleStart: (details) {
              // absorb scale gesture here to prevent scrolling
              // and triggering by mistake a move to the image page above
            },
            child: ClipRRect(
              borderRadius: BorderRadius.all(
                Radius.circular(16),
              ),
              child: Container(
                color: Colors.white70,
                height: 200,
                child: GoogleMap(
                  // GoogleMap init perf issue: https://github.com/flutter/flutter/issues/28493
                  initialCameraPosition: CameraPosition(
                    target: widget.latLng,
                    zoom: widget.initialZoom,
                  ),
                  onMapCreated: (controller) => setState(() => _controller = controller),
                  rotateGesturesEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: false,
                  liteModeEnabled: false,
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
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        TooltipTheme(
          data: TooltipTheme.of(context).copyWith(
            preferBelow: false,
          ),
          child: Column(children: [
            IconButton(
              icon: Icon(AIcons.zoomIn),
              onPressed: _controller == null ? null : () => _zoomBy(1),
              tooltip: 'Zoom in',
            ),
            IconButton(
              icon: Icon(AIcons.zoomOut),
              onPressed: _controller == null ? null : () => _zoomBy(-1),
              tooltip: 'Zoom out',
            ),
            IconButton(
              icon: Icon(AIcons.openInNew),
              onPressed: () => AndroidAppService.openMap(widget.geoUri),
              tooltip: 'Show on map...',
            ),
          ]),
        )
      ],
    );
  }

  void _zoomBy(double amount) {
    settings.infoMapZoom += amount;
    _controller.animateCamera(CameraUpdate.zoomBy(amount));
  }

  @override
  bool get wantKeepAlive => true;
}
