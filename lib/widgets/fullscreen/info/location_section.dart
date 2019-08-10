import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationSection extends AnimatedWidget {
  final ImageEntry entry;

  const LocationSection({Key key, this.entry}) : super(key: key, listenable: entry);

  @override
  Widget build(BuildContext context) {
    return !entry.hasGps
        ? SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionRow('Location'),
              ImageMap(markerId: entry.path, latLng: LatLng(entry.latLng.item1, entry.latLng.item2)),
              if (entry.isLocated)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: InfoRow('Address', entry.addressLine),
                ),
            ],
          );
  }
}

class ImageMap extends StatefulWidget {
  final String markerId;
  final LatLng latLng;

  const ImageMap({Key key, this.markerId, this.latLng}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageMapState();
}

class ImageMapState extends State<ImageMap> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.latLng,
            zoom: 12,
          ),
          markers: [
            Marker(
              markerId: MarkerId(widget.markerId),
              icon: BitmapDescriptor.defaultMarker,
              position: widget.latLng,
            )
          ].toSet(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
