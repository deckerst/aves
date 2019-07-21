import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageFullscreenPage extends StatefulWidget {
  final Map entry;
  final Uint8List thumbnail;

  ImageFullscreenPage({this.entry, this.thumbnail});

  @override
  ImageFullscreenPageState createState() => ImageFullscreenPageState();
}

class ImageFullscreenPageState extends State<ImageFullscreenPage> {
  int get imageWidth => widget.entry['width'];

  int get imageHeight => widget.entry['height'];

  String get uri => widget.entry['uri'];

  String get path => widget.entry['path'];

  double requestWidth, requestHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (requestWidth == null || requestHeight == null) {
      var mediaQuery = MediaQuery.of(context);
      var screenSize = mediaQuery.size;
      var dpr = mediaQuery.devicePixelRatio;
      requestWidth = imageWidth * dpr;
      requestHeight = imageHeight * dpr;
      if (imageWidth > screenSize.width || imageHeight > screenSize.height) {
        var ratio = max(imageWidth / screenSize.width, imageHeight / screenSize.height);
        requestWidth /= ratio;
        requestHeight /= ratio;
      }
    }
    return MediaQuery.removeViewInsets(
      context: context,
      // remove bottom view insets to paint underneath the translucent navigation bar
      removeBottom: true,
      child: Scaffold(
        body: Hero(
          tag: uri,
          child: Stack(
            children: [
              Center(
                child: widget.thumbnail == null
                    ? CircularProgressIndicator()
                    : Image.memory(
                        widget.thumbnail,
                        width: requestWidth,
                        height: requestHeight,
                        fit: BoxFit.contain,
                      ),
              ),
              Center(
                child: FadeInImage(
                  placeholder: MemoryImage(kTransparentImage),
                  image: FileImage(File(path)),
                  fadeOutDuration: Duration(milliseconds: 1),
                  fadeInDuration: Duration(milliseconds: 200),
                  width: requestWidth,
                  height: requestHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
