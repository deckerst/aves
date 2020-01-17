import 'dart:async';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_service.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/fx/highlight_decoration.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MetadataSectionSliver extends StatefulWidget {
  final ImageEntry entry;
  final int columnCount;
  final ValueNotifier<bool> visibleNotifier;

  const MetadataSectionSliver({
    @required this.entry,
    @required this.columnCount,
    this.visibleNotifier,
  });

  @override
  State<StatefulWidget> createState() => _MetadataSectionSliverState();
}

class _MetadataSectionSliverState extends State<MetadataSectionSliver> with AutomaticKeepAliveClientMixin {
  Map _metadata;
  String _loadedMetadataUri;

  bool get isVisible => widget.visibleNotifier.value;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    _getMetadata();
  }

  @override
  void didUpdateWidget(MetadataSectionSliver oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
    _getMetadata();
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(MetadataSectionSliver widget) {
    widget.visibleNotifier.addListener(_getMetadata);
  }

  void _unregisterWidget(MetadataSectionSliver widget) {
    widget.visibleNotifier.removeListener(_getMetadata);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final directoryNames = (_metadata?.keys?.toList() ?? [])..sort();
    return SliverStaggeredGrid.countBuilder(
      crossAxisCount: widget.columnCount,
      staggeredTileBuilder: (index) => StaggeredTile.fit(index == 0 ? widget.columnCount : 1),
      itemBuilder: (context, index) {
        return index == 0
            ? const SectionRow('Metadata')
            : _Directory(
                metadataMap: _metadata,
                directoryName: directoryNames[index - 1],
              );
      },
      itemCount: directoryNames.isEmpty ? 0 : directoryNames.length + 1,
      mainAxisSpacing: 0,
      crossAxisSpacing: 8,
    );
  }

  Future<void> _getMetadata() async {
    if (_loadedMetadataUri == widget.entry.uri) return;
    if (isVisible) {
      _metadata = await MetadataService.getAllMetadata(widget.entry);
      _loadedMetadataUri = widget.entry.uri;
    } else {
      _metadata = null;
      _loadedMetadataUri = null;
    }
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}

class _Directory extends StatelessWidget {
  final Map metadataMap;
  final String directoryName;

  static const int maxValueLength = 140;

  const _Directory({@required this.metadataMap, @required this.directoryName});

  @override
  Widget build(BuildContext context) {
    final directory = metadataMap[directoryName];
    final tagKeys = directory.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (directoryName.isNotEmpty)
          Container(
            decoration: HighlightDecoration(
              color: stringToColor(directoryName),
            ),
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              directoryName,
              style: const TextStyle(
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  )
                ],
                fontSize: 18,
                fontFamily: 'Concourse Caps',
              ),
            ),
          ),
        ...tagKeys.map((tagKey) {
          final value = directory[tagKey] as String;
          if (value == null || value.isEmpty) return const SizedBox.shrink();
          return InfoRow(tagKey, value.length > maxValueLength ? '${value.substring(0, maxValueLength)}…' : value);
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}
