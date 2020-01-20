import 'dart:async';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_service.dart';
import 'package:aves/utils/color_utils.dart';
import 'package:aves/widgets/common/fx/highlight_decoration.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tuple/tuple.dart';

class MetadataSectionSliver extends StatefulWidget {
  final ImageEntry entry;
  final int columnCount;
  final ValueNotifier<bool> visibleNotifier;

  const MetadataSectionSliver({
    @required this.entry,
    @required this.columnCount,
    @required this.visibleNotifier,
  });

  @override
  State<StatefulWidget> createState() => _MetadataSectionSliverState();
}

class _MetadataSectionSliverState extends State<MetadataSectionSliver> with AutomaticKeepAliveClientMixin {
  List<_MetadataDirectory> _metadata = [];
  String _loadedMetadataUri;

  int get columnCount => widget.columnCount;

  bool get isVisible => widget.visibleNotifier.value;

  static const int maxValueLength = 140;

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

    final itemCount = _metadata.isEmpty ? 0 : _metadata.length + 1;
    final itemBuilder = (context, index) => index == 0 ? const SectionRow('Metadata') : _DirectoryWidget(_metadata[index - 1]);

    // SliverStaggeredGrid is not as efficient as SliverList when there is only one column
    return columnCount == 1
        ? SliverList(
            delegate: SliverChildBuilderDelegate(
              itemBuilder,
              childCount: itemCount,
            ),
          )
        : SliverStaggeredGrid.countBuilder(
            crossAxisCount: columnCount,
            staggeredTileBuilder: (index) => StaggeredTile.fit(index == 0 ? columnCount : 1),
            itemBuilder: itemBuilder,
            itemCount: itemCount,
            mainAxisSpacing: 0,
            crossAxisSpacing: 8,
          );
  }

  Future<void> _getMetadata() async {
    if (_loadedMetadataUri == widget.entry.uri) return;
    if (isVisible) {
      final rawMetadata = await MetadataService.getAllMetadata(widget.entry) ?? {};
      _metadata = rawMetadata.entries.map((kv) {
        final String directoryName = kv.key as String ?? '';
        final Map rawTags = kv.value as Map ?? {};
        final List<Tuple2<String, String>> tags = rawTags.entries
            .map((kv) {
              final value = kv.value as String ?? '';
              if (value.isEmpty) return null;
              final tagName = kv.key as String ?? '';
              return Tuple2(tagName, value.length > maxValueLength ? '${value.substring(0, maxValueLength)}…' : value);
            })
            .where((tag) => tag != null)
            .toList()
              ..sort((a, b) => a.item1.compareTo(b.item1));
        return _MetadataDirectory(directoryName, tags);
      }).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _loadedMetadataUri = widget.entry.uri;
    } else {
      _metadata = [];
      _loadedMetadataUri = null;
    }
    if (mounted) setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}

class _DirectoryWidget extends StatelessWidget {
  final _MetadataDirectory directory;

  const _DirectoryWidget(this.directory);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (directory.name.isNotEmpty) _DirectoryTitle(directory.name),
        ...directory.tags.map((tag) => InfoRow(tag.item1, tag.item2)),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _DirectoryTitle extends StatelessWidget {
  final String name;

  const _DirectoryTitle(this.name);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: HighlightDecoration(
          color: stringToColor(name),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          name,
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
    );
  }
}

class _MetadataDirectory {
  final String name;
  final List<Tuple2<String, String>> tags;

  const _MetadataDirectory(this.name, this.tags);
}
