import 'dart:typed_data';
import 'package:aves/main.dart';
import 'package:transparent_image/transparent_image.dart';

import 'package:flutter/material.dart';

class Thumbnail extends StatefulWidget {
  Thumbnail({Key key, @required this.id, @required this.extent}) : super(key: key);

  final int id;
  final double extent;

  @override
  ThumbnailState createState() => ThumbnailState();
}

class ThumbnailState extends State<Thumbnail> {
  Future<Uint8List> loader;

  @override
  void initState() {
    super.initState();
    loader = ImageFetcher.getThumbnail(widget.id);
  }

  @override
  void dispose() {
    ImageFetcher.cancelGetThumbnail(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loader,
        builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
          var ready = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
          Uint8List bytes = ready ? snapshot.data : kTransparentImage;
          return Hero(
            tag: widget.id,
            child: Image.memory(
              bytes,
              width: widget.extent,
              height: widget.extent,
              fit: BoxFit.cover,
            ),
          );
        });
  }
}
