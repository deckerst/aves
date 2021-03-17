import 'dart:async';
import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:aves/services/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum MetadataThumbnailSource { embedded, exif }

class MetadataThumbnails extends StatefulWidget {
  final MetadataThumbnailSource source;
  final AvesEntry entry;

  const MetadataThumbnails({
    Key key,
    @required this.source,
    @required this.entry,
  }) : super(key: key);

  @override
  _MetadataThumbnailsState createState() => _MetadataThumbnailsState();
}

class _MetadataThumbnailsState extends State<MetadataThumbnails> {
  Future<List<Uint8List>> _loader;

  AvesEntry get entry => widget.entry;

  String get uri => entry.uri;

  @override
  void initState() {
    super.initState();
    switch (widget.source) {
      case MetadataThumbnailSource.embedded:
        _loader = metadataService.getEmbeddedPictures(uri);
        break;
      case MetadataThumbnailSource.exif:
        _loader = metadataService.getExifThumbnails(entry);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Uint8List>>(
        future: _loader,
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done && snapshot.data.isNotEmpty) {
            return Container(
              alignment: AlignmentDirectional.topStart,
              padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
              child: Wrap(
                children: snapshot.data.map((bytes) {
                  return Image.memory(
                    bytes,
                    scale: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio),
                  );
                }).toList(),
              ),
            );
          }
          return SizedBox.shrink();
        });
  }
}
