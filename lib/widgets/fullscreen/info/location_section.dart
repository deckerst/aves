import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/android_app_service.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class LocationSection extends AnimatedWidget {
  final ImageEntry entry;
  final bool showTitle;

  LocationSection({
    Key key,
    @required this.entry,
    @required this.showTitle,
  }) : super(
            key: key,
            listenable: Listenable.merge([
              entry.metadataChangeNotifier,
              entry.addressChangeNotifier,
            ]));

  @override
  Widget build(BuildContext context) {
    return !entry.hasGps
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: SectionRow('Location'),
                ),
              ImageMap(
                markerId: entry.path,
                latLng: LatLng(
                  entry.latLng.item1,
                  entry.latLng.item2,
                ),
                geoUri: entry.geoUri,
                initialZoom: settings.infoMapZoom,
              ),
              if (entry.isLocated)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: InfoRow('Address', entry.addressDetails.addressLine),
                ),
            ],
          );
  }
}

class ImageMap extends StatefulWidget {
  final String markerId;
  final LatLng latLng;
  final String geoUri;
  final double initialZoom;

  const ImageMap({
    Key key,
    this.markerId,
    this.latLng,
    this.geoUri,
    this.initialZoom,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageMapState();
}

class ImageMapState extends State<ImageMap> with AutomaticKeepAliveClientMixin {
  GoogleMapController _controller;

  @override
  void didUpdateWidget(ImageMap oldWidget) {
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
          child: SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(16),
              ),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.latLng,
                  zoom: widget.initialZoom,
                ),
                onMapCreated: (controller) => setState(() => this._controller = controller),
                rotateGesturesEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
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
        const SizedBox(width: 8),
        Column(children: [
          IconButton(
            icon: Icon(OMIcons.add),
            onPressed: _controller == null ? null : () => _zoomBy(1),
            tooltip: 'Zoom in',
          ),
          IconButton(
            icon: Icon(OMIcons.remove),
            onPressed: _controller == null ? null : () => _zoomBy(-1),
            tooltip: 'Zoom out',
          ),
          IconButton(
            icon: Icon(OMIcons.openInNew),
            onPressed: () => AndroidAppService.openMap(widget.geoUri),
            tooltip: 'Show on map...',
          ),
        ])
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
