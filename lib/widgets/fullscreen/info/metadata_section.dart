import 'dart:async';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_service.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';

class MetadataSection extends StatefulWidget {
  final ImageEntry entry;

  const MetadataSection({this.entry});

  @override
  State<StatefulWidget> createState() => MetadataSectionState();
}

class MetadataSectionState extends State<MetadataSection> {
  Future<Map> _metadataLoader;

  static const int maxValueLength = 140;

  @override
  void initState() {
    super.initState();
    initMetadataLoader();
  }

  @override
  void didUpdateWidget(MetadataSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    initMetadataLoader();
  }

  initMetadataLoader() async {
    _metadataLoader = MetadataService.getAllMetadata(widget.entry);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _metadataLoader,
      builder: (futureContext, AsyncSnapshot<Map> snapshot) {
        if (snapshot.hasError) return Text(snapshot.error);
        if (snapshot.connectionState != ConnectionState.done) return SizedBox.shrink();
        final metadataMap = snapshot.data.cast<String, Map>();
        final directoryNames = metadataMap.keys.toList()..sort();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionRow('Metadata'),
            ...directoryNames.expand(
              (directoryName) {
                final directory = metadataMap[directoryName];
                final tagKeys = directory.keys.toList()..sort();
                return [
                  if (directoryName.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(directoryName,
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Concourse Caps',
                          )),
                    ),
                  ...tagKeys.map((tagKey) {
                    final value = directory[tagKey] as String;
                    if (value == null || value.isEmpty) return SizedBox.shrink();
                    return InfoRow(tagKey, value.length > maxValueLength ? '${value.substring(0, maxValueLength)}…' : value);
                  }),
                  SizedBox(height: 16),
                ];
              },
            )
          ],
        );
      },
    );
  }
}
