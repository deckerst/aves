import 'dart:math';
import 'dart:typed_data';

import 'package:aves/model/image_fetcher.dart';
import 'package:aves/model/mime_types.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class Thumbnail extends StatefulWidget {
  final Map entry;
  final double extent;
  final double devicePixelRatio;

  const Thumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    @required this.devicePixelRatio,
  }) : super(key: key);

  @override
  ThumbnailState createState() => ThumbnailState();
}

class ThumbnailState extends State<Thumbnail> {
  Future<Uint8List> _byteLoader;

  String get mimeType => widget.entry['mimeType'];

  String get uri => widget.entry['uri'];

  @override
  void initState() {
    super.initState();
    initByteLoader();
  }

  @override
  void didUpdateWidget(Thumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (uri == oldWidget.entry['uri'] && widget.extent == oldWidget.extent) return;
    initByteLoader();
  }

  initByteLoader() {
    var dim = (widget.extent * widget.devicePixelRatio).round();
    _byteLoader = ImageFetcher.getImageBytes(widget.entry, dim, dim);
  }

  @override
  void dispose() {
    ImageFetcher.cancelGetImageBytes(uri);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isVideo = mimeType.startsWith(MimeTypes.MIME_VIDEO);
    var isGif = mimeType == MimeTypes.MIME_GIF;
    var iconSize = widget.extent / 4;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade700,
          width: 0.5,
        ),
      ),
      child: FutureBuilder(
          future: _byteLoader,
          builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
            var bytes = (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) ? snapshot.data : kTransparentImage;
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
                        bytes,
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
    );
  }
}
