import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meta/meta.dart';

// workaround to Google Maps initialization blocking the dart thread
// cf https://github.com/flutter/flutter/issues/28493
// it loads first Google Maps in an isolate, and then build the desired map

class GoogleMapInitializer extends StatefulWidget {
  final WidgetBuilder builder, errorBuilder, placeholderBuilder;

  const GoogleMapInitializer({
    @required this.builder,
    this.errorBuilder,
    this.placeholderBuilder,
  });

  @override
  _GoogleMapInitializerState createState() => _GoogleMapInitializerState();
}

class _GoogleMapInitializerState extends State<GoogleMapInitializer> {
  Future<void> initializer;

  @override
  void initState() {
    super.initState();
    initializer = compute(_preload, null);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: initializer,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return widget.errorBuilder?.call(context) ?? const Icon(Icons.error_outline);
          } else if (snapshot.connectionState == ConnectionState.done) {
            return widget.builder(context);
          } else {
            return widget.placeholderBuilder?.call(context) ?? const SizedBox.shrink();
          }
        });
  }
}

Future<void> _preload(_) async {
  final mapCreatedCompleter = Completer();
  GoogleMap(
    compassEnabled: false,
    mapToolbarEnabled: false,
    rotateGesturesEnabled: false,
    scrollGesturesEnabled: false,
    zoomGesturesEnabled: false,
    tiltGesturesEnabled: false,
    buildingsEnabled: false,
    initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 20),
    onMapCreated: (controller) => mapCreatedCompleter.complete(),
  );
  return mapCreatedCompleter.future;
}
