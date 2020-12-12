import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/material.dart';
import 'package:panorama/panorama.dart';

class PanoramaPage extends StatelessWidget {
  static const routeName = '/fullscreen/panorama';

  final ImageEntry entry;

  const PanoramaPage({@required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Panorama(
        child: Image(
          image: UriImage(
            uri: entry.uri,
            mimeType: entry.mimeType,
            rotationDegrees: entry.rotationDegrees,
            isFlipped: entry.isFlipped,
            expectedContentLength: entry.sizeBytes,
          ),
        ),
        // TODO TLAD toggle sensor control
        sensorControl: SensorControl.None,
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
