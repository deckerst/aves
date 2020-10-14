import 'dart:async';
import 'dart:typed_data';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:flutter/material.dart';

enum MetadataThumbnailSource { embedded, exif, xmp }

class MetadataThumbnails extends StatefulWidget {
  final MetadataThumbnailSource source;
  final ImageEntry entry;

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

  ImageEntry get entry => widget.entry;

  String get uri => entry.uri;

  @override
  void initState() {
    super.initState();
    switch (widget.source) {
      case MetadataThumbnailSource.embedded:
        _loader = MetadataService.getEmbeddedPictures(uri);
        break;
      case MetadataThumbnailSource.exif:
        _loader = MetadataService.getExifThumbnails(uri);
        break;
      case MetadataThumbnailSource.xmp:
        _loader = MetadataService.getXmpThumbnails(entry);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Uint8List>>(
        future: _loader,
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done && snapshot.data.isNotEmpty) {
            // TODO TLAD apply the rotation to Exif thumbnail only, on Android side
            final turns = (entry.rotationDegrees / 90).round();
            final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
            return Container(
              alignment: AlignmentDirectional.topStart,
              padding: EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
              child: Wrap(
                children: snapshot.data.map((bytes) {
                  return RotatedBox(
                    quarterTurns: turns,
                    child: Image.memory(
                      bytes,
                      scale: devicePixelRatio,
                    ),
                  );
                }).toList(),
              ),
            );
          }
          return SizedBox.shrink();
        });
  }
}
