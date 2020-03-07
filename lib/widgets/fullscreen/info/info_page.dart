import 'package:aves/model/collection_lens.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/coma_divider.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/fullscreen/info/basic_section.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/metadata_section.dart';
import 'package:aves/widgets/fullscreen/info/xmp_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class InfoPage extends StatefulWidget {
  final CollectionLens collection;
  final ImageEntry entry;
  final ValueNotifier<bool> visibleNotifier;

  const InfoPage({
    Key key,
    @required this.collection,
    @required this.entry,
    this.visibleNotifier,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  ScrollController _scrollController = ScrollController();
  bool _scrollStartFromTop = false;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    entry.locate();
  }

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

    return MediaQueryDataProvider(
      child: Scaffold(
        body: SafeArea(
          child: NotificationListener(
            onNotification: _handleTopScroll,
            child: Selector<MediaQueryData, Tuple2<double, double>>(
              selector: (c, mq) => Tuple2(mq.size.width, mq.viewInsets.bottom),
              builder: (c, mq, child) {
                final mqWidth = mq.item1;
                final mqViewInsetsBottom = mq.item2;
                final split = mqWidth > 400;

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      leading: IconButton(
                        icon: const Icon(OMIcons.arrowUpward),
                        onPressed: _goToImage,
                        tooltip: 'Back to image',
                      ),
                      title: const Text('Info'),
                      floating: true,
                    ),
                    const SliverPadding(
                      padding: EdgeInsets.only(top: 8),
                    ),
                    if (split && entry.hasGps)
                      SliverPadding(
                        padding: horizontalPadding,
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: BasicSection(entry: entry)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LocationSection(
                                  entry: entry,
                                  showTitle: false,
                                  visibleNotifier: widget.visibleNotifier,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: horizontalPadding,
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              BasicSection(entry: entry),
                              LocationSection(
                                entry: entry,
                                showTitle: true,
                                visibleNotifier: widget.visibleNotifier,
                              ),
                            ],
                          ),
                        ),
                      ),
                    SliverPadding(
                      padding: horizontalPadding,
                      sliver: XmpTagSectionSliver(collection: widget.collection, entry: entry),
                    ),
                    SliverPadding(
                      padding: horizontalPadding,
                      sliver: MetadataSectionSliver(
                        entry: entry,
                        columnCount: split ? 2 : 1,
                        visibleNotifier: widget.visibleNotifier,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(bottom: 8 + mqViewInsetsBottom),
                    ),
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
            _goToImage();
            _scrollStartFromTop = false;
          }
        }
      }
    }
    return false;
  }

  void _goToImage() {
    BackUpNotification().dispatch(context);
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: (300 * timeDilation).toInt()),
      curve: Curves.easeInOut,
    );
  }
}

class SectionRow extends StatelessWidget {
  final String title;

  const SectionRow(this.title);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: ComaDivider(alignment: Alignment.centerRight)),
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
        const Expanded(child: ComaDivider(alignment: Alignment.centerLeft)),
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
