import 'dart:typed_data';

import 'package:aves/main.dart';
import 'package:aves/mime_types.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class Thumbnail extends StatefulWidget {
  Thumbnail({Key key, @required this.entry, @required this.extent}) : super(key: key);

  final Map entry;
  final double extent;

  @override
  ThumbnailState createState() => ThumbnailState();
}

class ThumbnailState extends State<Thumbnail> {
  Future<Uint8List> loader;

  @override
  void initState() {
    super.initState();
    loader = ImageFetcher.getThumbnail(widget.entry, widget.extent, widget.extent);
  }

  @override
  void dispose() {
    ImageFetcher.cancelGetThumbnail(widget.entry['uri']);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String mimeType = widget.entry['mimeType'];
    var isVideo = mimeType.startsWith(MimeTypes.MIME_VIDEO);
    var isGif = mimeType == MimeTypes.MIME_GIF;
    var iconSize = widget.extent / 4;
    return FutureBuilder(
        future: loader,
        builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
          var ready = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
          Uint8List bytes = ready ? snapshot.data : kTransparentImage;
          return Hero(
            tag: widget.entry['uri'],
            child: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                Image.memory(
                  bytes,
                  width: widget.extent,
                  height: widget.extent,
                  fit: BoxFit.cover,
                ),
                if (isVideo)
                  Icon(
                    Icons.play_circle_outline,
                    size: iconSize,
                  ),
                if (isGif)
                  Icon(
                    Icons.gif,
                    size: iconSize,
                  ),
              ],
            ),
          );
        });
  }
}
