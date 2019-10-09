import 'dart:math';
import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class Thumbnail extends StatelessWidget {
  final ImageEntry entry;
  final double extent;
  final double devicePixelRatio;

  const Thumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    @required this.devicePixelRatio,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade700,
          width: 0.5,
        ),
      ),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          ThumbnailImage(
            entry: entry,
            extent: extent,
            devicePixelRatio: devicePixelRatio,
          ),
          _buildOverlayIcons(),
        ],
      ),
    );
  }

  Widget _buildOverlayIcons() {
    final fontSize = min(14.0, (extent / 8).roundToDouble());
    final iconSize = fontSize * 2;
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.grey[200],
        fontSize: fontSize,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.hasGps) GpsIcon(iconSize: iconSize),
          if (entry.isGif)
            GifIcon(iconSize: iconSize)
          else if (entry.isVideo)
            VideoIcon(
              entry: entry,
              iconSize: iconSize,
            ),
        ],
      ),
    );
  }
}

class ThumbnailImage extends StatefulWidget {
  final ImageEntry entry;
  final double extent;
  final double devicePixelRatio;

  const ThumbnailImage({
    Key key,
    @required this.entry,
    @required this.extent,
    @required this.devicePixelRatio,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ThumbnailImageState();
}

class ThumbnailImageState extends State<ThumbnailImage> {
  Future<Uint8List> _byteLoader;
  Listenable _entryChangeNotifier;

  ImageEntry get entry => widget.entry;

  String get uri => widget.entry.uri;

  @override
  void initState() {
    super.initState();
    _entryChangeNotifier = Listenable.merge([entry.imageChangeNotifier, entry.metadataChangeNotifier]);
    _entryChangeNotifier.addListener(onEntryChange);
    initByteLoader();
  }

  @override
  void didUpdateWidget(ThumbnailImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.extent == oldWidget.extent && uri == oldWidget.entry.uri && widget.entry.width == oldWidget.entry.width && widget.entry.height == oldWidget.entry.height && widget.entry.orientationDegrees == oldWidget.entry.orientationDegrees) return;
    initByteLoader();
  }

  initByteLoader() {
    final dim = (widget.extent * widget.devicePixelRatio).round();
    _byteLoader = ImageFileService.getImageBytes(widget.entry, dim, dim);
  }

  onEntryChange() => setState(() => initByteLoader());

  @override
  void dispose() {
    _entryChangeNotifier.removeListener(onEntryChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _byteLoader,
        builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
          final bytes = (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) ? snapshot.data : kTransparentImage;
          return bytes.length > 0
              ? Hero(
                  tag: entry.uri,
                  child: LayoutBuilder(builder: (context, constraints) {
                    final dim = min(constraints.maxWidth, constraints.maxHeight);
                    return Image.memory(
                      bytes,
                      width: dim,
                      height: dim,
                      fit: BoxFit.cover,
                    );
                  }),
                )
              : Icon(Icons.error);
        });
  }
}
