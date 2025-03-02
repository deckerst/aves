import 'dart:async';
import 'dart:ui' as ui;

import 'package:aves/image_providers/descriptor_provider.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/services/common/services.dart';
import 'package:flutter/material.dart';

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
  late Future<List<ui.ImageDescriptor?>> _loader;

  AvesEntry get entry => widget.entry;

  String get uri => entry.uri;

  @override
  void initState() {
    super.initState();
    _loader = embeddedDataService.getExifThumbnails(entry);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ui.ImageDescriptor?>>(
        future: _loader,
        builder: (context, snapshot) {
          if (!snapshot.hasError && snapshot.connectionState == ConnectionState.done && snapshot.data!.isNotEmpty) {
            return Container(
              alignment: AlignmentDirectional.topStart,
              padding: const EdgeInsets.only(left: 8, top: 8, right: 8, bottom: 4),
              child: Wrap(
                children: snapshot.data!.map((descriptor) {
                  if (descriptor == null) return const SizedBox();
                  return Image(
                    image: DescriptorImageProvider(
                      descriptor,
                      scale: MediaQuery.devicePixelRatioOf(context),
                    ),
                  );
                }).toList(),
              ),
            );
          }
          return const SizedBox();
        });
  }
}
