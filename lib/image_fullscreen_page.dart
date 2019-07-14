import 'dart:typed_data';

import 'package:aves/main.dart';
import 'package:flutter/material.dart';

class ImageFullscreenPage extends StatefulWidget {
  final Map entry;
  final Uint8List thumbnail;

  ImageFullscreenPage({this.entry, this.thumbnail});

  @override
  ImageFullscreenPageState createState() => ImageFullscreenPageState();
}

class ImageFullscreenPageState extends State<ImageFullscreenPage> {
  Future<Uint8List> loader;

  int get imageWidth => widget.entry['width'];

  int get imageHeight => widget.entry['width'];

  String get uri => widget.entry['uri'];

  @override
  void initState() {
    super.initState();
    loader = ImageFetcher.getImageBytes(widget.entry, imageWidth, imageHeight);
  }

  @override
  void dispose() {
    ImageFetcher.cancelGetImageBytes(uri);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loader,
        builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
          var ready = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
          Uint8List bytes = ready ? snapshot.data : widget.thumbnail;
          return Hero(
            tag: uri,
            child: Center(
              child: Image.memory(
                bytes,
                width: imageWidth.toDouble(),
                height: imageHeight.toDouble(),
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          );
        });
  }
}
