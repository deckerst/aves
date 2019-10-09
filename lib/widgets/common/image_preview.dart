import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class ImagePreview extends StatefulWidget {
  final ImageEntry entry;
  final double width, height, devicePixelRatio;
  final Widget Function(Uint8List bytes) builder;

  const ImagePreview({
    Key key,
    @required this.entry,
    @required this.width,
    @required this.height,
    @required this.devicePixelRatio,
    @required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImagePreviewState();
}

class ImagePreviewState extends State<ImagePreview> {
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
  void didUpdateWidget(ImagePreview old) {
    super.didUpdateWidget(old);
    if (widget.width == old.width && widget.height == old.height && uri == old.entry.uri && widget.entry.width == old.entry.width && widget.entry.height == old.entry.height && widget.entry.orientationDegrees == old.entry.orientationDegrees) return;
    initByteLoader();
  }

  initByteLoader() {
    final width = (widget.width * widget.devicePixelRatio).round();
    final height = (widget.height * widget.devicePixelRatio).round();
    _byteLoader = ImageFileService.getImageBytes(widget.entry, width, height);
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
          return bytes.length > 0 ? widget.builder(bytes) : Icon(Icons.error);
        });
  }
}
