import 'package:aves/model/image_collection.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/fullscreen/info/basic_section.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/metadata_section.dart';
import 'package:aves/widgets/fullscreen/info/xmp_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class InfoPage extends StatefulWidget {
  final ImageCollection collection;
  final ImageEntry entry;

  const InfoPage({
    Key key,
    @required this.collection,
    @required this.entry,
  }) : super(key: key);

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
    return MediaQueryDataProvider(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_upward),
            onPressed: () => BackUpNotification().dispatch(context),
            tooltip: 'Back to image',
          ),
          title: const Text('Info'),
        ),
        body: SafeArea(
          child: NotificationListener(
            onNotification: _handleTopScroll,
            child: Selector<MediaQueryData, Tuple2<Orientation, double>>(
              selector: (c, mq) => Tuple2(mq.orientation, mq.viewInsets.bottom),
              builder: (c, mq, child) {
                final mqOrientation = mq.item1;
                final mqViewInsetsBottom = mq.item2;

                return ListView(
                  padding: const EdgeInsets.all(8.0) + EdgeInsets.only(bottom: mqViewInsetsBottom),
                  children: [
                    if (mqOrientation == Orientation.landscape && entry.hasGps)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: BasicSection(entry: entry)),
                          const SizedBox(width: 8),
                          Expanded(child: LocationSection(entry: entry, showTitle: false)),
                        ],
                      )
                    else ...[
                      BasicSection(entry: entry),
                      LocationSection(entry: entry, showTitle: true),
                    ],
                    XmpTagSection(collection: widget.collection, entry: entry),
                    MetadataSection(entry: entry),
                  ],
                );
              },
            ),
          ),
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  bool _handleTopScroll(Notification notification) {
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
        const Expanded(child: Divider(color: Colors.white70)),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Concourse Caps',
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.white70)),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontFamily: 'Concourse'),
          children: [
            TextSpan(text: '$label    ', style: const TextStyle(color: Colors.white70)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class BackUpNotification extends Notification {}
