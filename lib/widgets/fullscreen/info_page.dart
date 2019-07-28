import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoPage extends StatelessWidget {
  final ImageEntry entry;

  const InfoPage({this.entry});

  @override
  Widget build(BuildContext context) {
    final date = entry.getBestDate();
    return Scaffold(
      appBar: AppBar(
        title: Text('Info'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoRow('Title', entry.title),
            InfoRow('Date', '${DateFormat.yMMMd().format(date)} – ${DateFormat.Hm().format(date)}'),
            InfoRow('Size', formatFilesize(entry.sizeBytes)),
            InfoRow('Resolution', '${entry.width} × ${entry.height} (${entry.getMegaPixels()} MP)'),
            InfoRow('Path', entry.path),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;

  const InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
        SizedBox(width: 8),
        Text(value),
      ],
    );
  }
}
