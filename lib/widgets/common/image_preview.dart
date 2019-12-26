import 'dart:typed_data';

import 'package:after_init/after_init.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_file_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:transparent_image/transparent_image.dart';

class ImagePreview extends StatefulWidget {
  final ImageEntry entry;
  final double width, height;
  final Widget Function(Uint8List bytes) builder;

  const ImagePreview({
    Key key,
    @required this.entry,
    @required this.width,
    @required this.height,
    @required this.builder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImagePreviewState();
}

class ImagePreviewState extends State<ImagePreview> with AfterInitMixin {
  Future<Uint8List> _byteLoader;
  Listenable _entryChangeNotifier;
  double _devicePixelRatio;

  ImageEntry get entry => widget.entry;

  String get uri => widget.entry.uri;

  @override
  void initState() {
    debugPrint('$runtimeType initState path=${entry.path}');
    super.initState();
    _entryChangeNotifier = Listenable.merge([
      entry.imageChangeNotifier,
      entry.metadataChangeNotifier,
    ]);
    _entryChangeNotifier.addListener(_onEntryChange);
  }

  @override
  void didInitState() {
    _devicePixelRatio = Provider.of<MediaQueryData>(context, listen: false).devicePixelRatio;
    _initByteLoader();
  }

  @override
  void didUpdateWidget(ImagePreview old) {
    super.didUpdateWidget(old);
    if (widget.width == old.width && widget.height == old.height && uri == old.entry.uri && widget.entry.width == old.entry.width && widget.entry.height == old.entry.height && widget.entry.orientationDegrees == old.entry.orientationDegrees) return;
    _initByteLoader();
  }

  void _initByteLoader() {
    final width = (widget.width * _devicePixelRatio).round();
    final height = (widget.height * _devicePixelRatio).round();
    _byteLoader = ImageFileService.getImageBytes(widget.entry, width, height);
  }

  void _onEntryChange() => setState(() => _initByteLoader());

  @override
  void dispose() {
    _entryChangeNotifier.removeListener(_onEntryChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _byteLoader,
        builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
          final bytes = (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) ? snapshot.data : kTransparentImage;
          return bytes.isNotEmpty
              ? widget.builder(bytes)
              : Center(
                  child: Icon(
                    Icons.error,
                    color: Colors.blueGrey,
                  ),
                );
        });
  }
}
