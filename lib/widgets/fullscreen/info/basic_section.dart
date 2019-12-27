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
    final dateText = '${DateFormat.yMMMd().format(date)} at ${DateFormat.Hm().format(date)}';
    final resolutionText = '${entry.width} × ${entry.height}${(entry.isVideo || entry.isGif) ? '' : ' (${entry.megaPixels} MP)'}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InfoRow('Title', entry.title),
        InfoRow('Date', dateText),
        if (entry.isVideo) ..._buildVideoRows(),
        InfoRow('Resolution', resolutionText),
        InfoRow('Size', formatFilesize(entry.sizeBytes)),
        InfoRow('URI', entry.uri),
        InfoRow('Path', entry.path),
      ],
    );
  }

  List<Widget> _buildVideoRows() {
    final rotation = entry.catalogMetadata?.videoRotation;
    return [
      InfoRow('Duration', entry.durationText),
      if (rotation != null) InfoRow('Rotation', '$rotation°'),
    ];
  }
}
