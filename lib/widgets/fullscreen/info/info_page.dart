import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/metadata_section.dart';
import 'package:aves/widgets/fullscreen/info/xmp_section.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoPage extends StatefulWidget {
  final ImageEntry entry;

  const InfoPage({this.entry});

  @override
  State<StatefulWidget> createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  bool _scrollStartFromTop = false;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    entry.locate();
  }

  @override
  Widget build(BuildContext context) {
    final date = entry.bestDate;
    final dateText = '${DateFormat.yMMMd().format(date)} – ${DateFormat.Hm().format(date)}';
    final resolutionText = '${entry.width} × ${entry.height}${entry.isVideo ? '' : ' (${entry.megaPixels} MP)'}';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_upward),
          onPressed: () => BackUpNotification().dispatch(context),
          tooltip: 'Back to image',
        ),
        title: Text('Info'),
      ),
      body: NotificationListener(
        onNotification: handleTopScroll,
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            InfoRow('Title', entry.title),
            InfoRow('Date', dateText),
            if (entry.isVideo) InfoRow('Duration', entry.durationText),
            InfoRow('Resolution', resolutionText),
            InfoRow('Size', formatFilesize(entry.sizeBytes)),
            InfoRow('Path', entry.path),
            LocationSection(entry: entry),
            XmpTagSection(entry: entry),
            MetadataSection(entry: entry),
          ],
        ),
      ),
    );
  }

  bool handleTopScroll(Notification notification) {
    if (notification is ScrollNotification) {
      if (notification is ScrollStartNotification) {
        final metrics = notification.metrics;
        _scrollStartFromTop = metrics.pixels == metrics.minScrollExtent;
      }
      if (_scrollStartFromTop) {
        if (notification is ScrollEndNotification) {
          _scrollStartFromTop = false;
        } else if (notification is OverscrollNotification) {
          if (notification.overscroll < 0) {
            BackUpNotification().dispatch(context);
            _scrollStartFromTop = false;
          }
        }
      }
    }
    return false;
  }
}

class SectionRow extends StatelessWidget {
  final String title;

  const SectionRow(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white70)),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(title, style: TextStyle(fontSize: 20)),
        ),
        Expanded(child: Divider(color: Colors.white70)),
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label, value;

  const InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(text: '$label    ', style: TextStyle(color: Colors.white70)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class BackUpNotification extends Notification {}
