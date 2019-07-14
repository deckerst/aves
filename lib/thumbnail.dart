import 'dart:math';
import 'dart:typed_data';

import 'package:aves/image_fetcher.dart';
import 'package:aves/image_fullscreen_page.dart';
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
  Uint8List bytes;

  int get imageWidth => widget.entry['width'];

  int get imageHeight => widget.entry['height'];

  String get mimeType => widget.entry['mimeType'];

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
      var dim = (widget.extent * MediaQuery.of(context).devicePixelRatio).round();
      loader = ImageFetcher.getImageBytes(widget.entry, dim, dim);
    }

    var isVideo = mimeType.startsWith(MimeTypes.MIME_VIDEO);
    var isGif = mimeType == MimeTypes.MIME_GIF;
    var iconSize = widget.extent / 4;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageFullscreenPage(entry: widget.entry, thumbnail: bytes),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade700,
            width: 0.5,
          ),
        ),
        child: FutureBuilder(
            future: loader,
            builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
              if (bytes == null && snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                bytes = snapshot.data;
              }
              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  Hero(
                    tag: uri,
                    child: LayoutBuilder(builder: (context, constraints) {
                      // during hero animation back from a fullscreen image,
                      // the image covers the whole screen (because of the 'fit' prop and the full screen hero constraints)
                      // so we wrap the image to apply better constraints
                      var dim = min(constraints.maxWidth, constraints.maxHeight);
                      return Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints.tight(Size(dim, dim)),
                        child: Image.memory(
                          bytes ?? kTransparentImage,
                          width: dim,
                          height: dim,
                          fit: BoxFit.cover,
                        ),
                      );
                    }),
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
              );
            }),
      ),
    );
  }
}
