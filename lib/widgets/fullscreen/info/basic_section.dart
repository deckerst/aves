import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/fullscreen/info/info_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BasicSection extends StatelessWidget {
  final ImageEntry entry;

  const BasicSection({
    Key key,
    @required this.entry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = entry.bestDate;
    final dateText = date != null ? '${DateFormat.yMMMd().format(date)} • ${DateFormat.Hm().format(date)}' : '?';
    final showMegaPixels = !entry.isVideo && !entry.isGif && entry.megaPixels != null && entry.megaPixels > 0;
    final resolutionText = '${entry.width ?? '?'} × ${entry.height ?? '?'}${showMegaPixels ? ' (${entry.megaPixels} MP)' : ''}';

    return InfoRowGroup({
      'Title': entry.title ?? '?',
      'Date': dateText,
      if (entry.isVideo) ..._buildVideoRows(),
      'Resolution': resolutionText,
      'Size': entry.sizeBytes != null ? formatFilesize(entry.sizeBytes) : '?',
      'URI': entry.uri ?? '?',
      if (entry.path != null) 'Path': entry.path,
    });
  }

  Map<String, String> _buildVideoRows() {
    final rotation = entry.catalogMetadata?.videoRotation;
    return {
      'Duration': entry.durationText,
      if (rotation != null) 'Rotation': '$rotation°',
    };
  }
}
