import 'package:aves/model/image_entry.dart';
import 'package:aves/model/settings.dart';
import 'package:aves/utils/android_app_service.dart';
import 'package:aves/utils/geo_utils.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

class LocationSection extends StatefulWidget {
  final ImageEntry entry;
  final bool showTitle;
  final ValueNotifier<bool> visibleNotifier;

  const LocationSection({
    Key key,
    @required this.entry,
    @required this.showTitle,
    @required this.visibleNotifier,
  }) : super(key: key);

  @override
  _LocationSectionState createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  String _loadedUri;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(LocationSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(LocationSection widget) {
    entry.metadataChangeNotifier.addListener(_handleChange);
    entry.addressChangeNotifier.addListener(_handleChange);
    widget.visibleNotifier.addListener(_handleChange);
  }

  void _unregisterWidget(LocationSection widget) {
    entry.metadataChangeNotifier.removeListener(_handleChange);
    entry.addressChangeNotifier.removeListener(_handleChange);
    widget.visibleNotifier.removeListener(_handleChange);
  }

  @override
  Widget build(BuildContext context) {
    final showMap = (_loadedUri == entry.uri) || (entry.hasGps && widget.visibleNotifier.value);
    if (showMap) {
      _loadedUri = entry.uri;
      String location;
      if (entry.isLocated) {
        location = entry.addressDetails.addressLine;
      } else if (entry.hasGps) {
        location = toDMS(entry.latLng).join(', ');
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showTitle)
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
          if (location.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: InfoRow('Address', location),
            ),
        ],
      );
    } else {
      _loadedUri = null;
      return const SizedBox.shrink();
    }
  }

  void _handleChange() => setState(() {});
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
