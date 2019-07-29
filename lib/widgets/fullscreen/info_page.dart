import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_service.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoPage extends StatefulWidget {
  final ImageEntry entry;

  const InfoPage({this.entry});

  @override
  State<StatefulWidget> createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  Future<Map> _metadataLoader;
  bool _scrollStartFromTop = false;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    initMetadataLoader();
  }

  @override
  void didUpdateWidget(InfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    initMetadataLoader();
  }

  initMetadataLoader() {
    _metadataLoader = MetadataService.getAllMetadata(entry.path);
  }

  @override
  Widget build(BuildContext context) {
    final date = entry.getBestDate();
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
        onNotification: (notification) {
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
        },
        child: ListView(
          padding: EdgeInsets.all(8.0),
          children: [
            SectionRow('File'),
            InfoRow('Title', entry.title),
            InfoRow('Date', '${DateFormat.yMMMd().format(date)} – ${DateFormat.Hm().format(date)}'),
            InfoRow('Resolution', '${entry.width} × ${entry.height} (${entry.getMegaPixels()} MP)'),
            InfoRow('Size', formatFilesize(entry.sizeBytes)),
            InfoRow('Path', entry.path),
            SectionRow('Metadata'),
            FutureBuilder(
              future: _metadataLoader,
              builder: (futureContext, AsyncSnapshot<Map> snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error);
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return CircularProgressIndicator();
                }
                final metadataMap = snapshot.data.cast<String, Map>();
                final directoryNames = metadataMap.keys.toList()..sort();
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: directoryNames.expand(
                      (directoryName) {
                        final directory = metadataMap[directoryName];
                        final tagKeys = directory.keys.toList()..sort();
                        return [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(directoryName, style: TextStyle(fontSize: 18)),
                          ),
                          ...tagKeys.map((tagKey) => InfoRow(tagKey, directory[tagKey])),
                          SizedBox(height: 16),
                        ];
                      },
                    ).toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SectionRow extends StatelessWidget {
  final String title;

  const SectionRow(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white70)),
          SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 18)),
          SizedBox(width: 8),
          Expanded(child: Divider(color: Colors.white70)),
        ],
      ),
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
