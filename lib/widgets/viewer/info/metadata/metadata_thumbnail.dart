import 'dart:async';
import 'dart:typed_data';

import 'package:aves/model/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MetadataThumbnails extends StatefulWidget {
  final AvesEntry entry;

  const MetadataThumbnails({
    super.key,
    required this.entry,
  });

  @override
  State<MetadataThumbnails> createState() => _MetadataThumbnailsState();
}

class _MetadataThumbnailsState extends State<MetadataThumbnails> {
  late Future<List<Uint8List>> _loader;

  AvesEntry get entry => widget.entry;

  String get uri => entry.uri;

  @override
  void initState() {
    super.initState();
    _loader = embeddedDataService.getExifThumbnails(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Uint8List>>(
        future: _loader,
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done && snapshot.data!.isNotEmpty) {
            return Container(
              alignment: AlignmentDirectional.topStart,
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
              child: Wrap(
                children: snapshot.data!.map((bytes) {
                  return Image.memory(
                    bytes,
                    scale: context.select<MediaQueryData, double>((mq) => mq.devicePixelRatio),
                  );
                }).toList(),
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }
}
