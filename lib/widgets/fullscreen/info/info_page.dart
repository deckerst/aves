import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/aves_filter_chip.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/basic_section.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/metadata_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class InfoPage extends StatefulWidget {
  final CollectionLens collection;
  final ValueNotifier<ImageEntry> entryNotifier;
  final ValueNotifier<bool> visibleNotifier;

  const InfoPage({
    Key key,
    @required this.collection,
    @required this.entryNotifier,
    @required this.visibleNotifier,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => InfoPageState();
}

class InfoPageState extends State<InfoPage> {
  final ScrollController _scrollController = ScrollController();
  bool _scrollStartFromTop = false;

  CollectionLens get collection => widget.collection;

  @override
  Widget build(BuildContext context) {
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

    final appBar = SliverAppBar(
      leading: IconButton(
        icon: const Icon(AIcons.goUp),
        onPressed: _goToImage,
        tooltip: 'Back to image',
      ),
      title: const Text('Info'),
      floating: true,
    );

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

                return ValueListenableBuilder(
                  valueListenable: widget.entryNotifier,
                  builder: (context, entry, child) {
                    final locationAtTop = split && entry.hasGps;
                    final locationSection = LocationSection(
                      collection: collection,
                      entry: entry,
                      showTitle: !locationAtTop,
                      visibleNotifier: widget.visibleNotifier,
                      onFilter: _goToCollection,
                    );
                    final basicAndLocationSliver = locationAtTop
                        ? SliverToBoxAdapter(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: BasicSection(entry: entry, collection: collection, onFilter: _goToCollection)),
                                const SizedBox(width: 8),
                                Expanded(child: locationSection),
                              ],
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildListDelegate.fixed(
                              [
                                BasicSection(entry: entry, collection: collection, onFilter: _goToCollection),
                                locationSection,
                              ],
                            ),
                          );
                    final metadataSliver = MetadataSectionSliver(
                      entry: entry,
                      visibleNotifier: widget.visibleNotifier,
                    );

                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        appBar,
                        SliverPadding(
                          padding: horizontalPadding + const EdgeInsets.only(top: 8),
                          sliver: basicAndLocationSliver,
                        ),
                        SliverPadding(
                          padding: horizontalPadding + EdgeInsets.only(bottom: 8 + mqViewInsetsBottom),
                          sliver: metadataSliver,
                        ),
                      ],
                    );
                  },
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
        if (notification is ScrollUpdateNotification) {
          _scrollStartFromTop = notification.scrollDelta < 0;
        } else if (notification is ScrollEndNotification) {
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
      duration: Durations.fullscreenPageAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _goToCollection(CollectionFilter filter) {
    if (collection == null) return;
    FilterNotification(filter).dispatch(context);
  }
}

class SectionRow extends StatelessWidget {
  final IconData icon;

  const SectionRow(this.icon);

  @override
  Widget build(BuildContext context) {
    const dim = 32.0;
    final buildDivider = () => const SizedBox(
          width: dim,
          child: Divider(
            thickness: AvesFilterChip.outlineWidth,
            color: Colors.white70,
          ),
        );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildDivider(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Icon(
            icon,
            size: dim,
          ),
        ),
        buildDivider(),
      ],
    );
  }
}

class InfoRowGroup extends StatelessWidget {
  final Map<String, String> keyValues;

  const InfoRowGroup(this.keyValues);

  @override
  Widget build(BuildContext context) {
    if (keyValues.isEmpty) return const SizedBox.shrink();
    final lastKey = keyValues.keys.last;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText.rich(
          TextSpan(
            children: keyValues.entries
                .expand(
                  (kv) => [
                    TextSpan(text: '${kv.key}     ', style: const TextStyle(color: Colors.white70, height: 1.7)),
                    TextSpan(text: '${kv.value}${kv.key == lastKey ? '' : '\n'}'),
                  ],
                )
                .toList(),
          ),
          style: const TextStyle(fontFamily: 'Concourse'),
        ),
      ],
    );
  }
}

class BackUpNotification extends Notification {}

class FilterNotification extends Notification {
  final CollectionFilter filter;

  const FilterNotification(this.filter);
}
