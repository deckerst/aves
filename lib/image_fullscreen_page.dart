import 'dart:math';
import 'dart:typed_data';

import 'package:aves/image_fetcher.dart';
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

  int get imageHeight => widget.entry['height'];

  String get uri => widget.entry['uri'];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ImageFetcher.cancelGetImageBytes(uri);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loader == null) {
      var mediaQuery = MediaQuery.of(context);
      var screenSize = mediaQuery.size;
      var dpr = mediaQuery.devicePixelRatio;
      var requestWidth = imageWidth * dpr;
      var requestHeight = imageHeight * dpr;
      if (imageWidth > screenSize.width || imageHeight > screenSize.height) {
        var ratio = max(imageWidth / screenSize.width, imageHeight / screenSize.height);
        requestWidth /= ratio;
        requestHeight /= ratio;
      }
      loader = ImageFetcher.getImageBytes(widget.entry, requestWidth.round(), requestHeight.round());
    }
    return FutureBuilder(
        future: loader,
        builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
          var ready = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
          return Hero(
            tag: uri,
            child: Stack(
              children: [
                Image.memory(
                  widget.thumbnail,
                  width: imageWidth.toDouble(),
                  height: imageHeight.toDouble(),
                  fit: BoxFit.contain,
                ),
                if (ready)
                  Image.memory(
                    snapshot.data,
                    width: imageWidth.toDouble(),
                    height: imageHeight.toDouble(),
                    fit: BoxFit.contain,
                  ),
              ],
            ),
          );
        });
  }
}
