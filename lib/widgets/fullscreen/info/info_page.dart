import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/basic_section.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/metadata/metadata_section.dart';
import 'package:aves/widgets/fullscreen/info/notifications.dart';
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

  ImageEntry get entry => widget.entryNotifier.value;

  @override
  Widget build(BuildContext context) {
    final appBar = SliverAppBar(
      leading: IconButton(
        key: Key('back-button'),
        icon: Icon(AIcons.goUp),
        onPressed: _goToImage,
        tooltip: 'Back to image',
      ),
      title: Text('Info'),
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
                return ValueListenableBuilder<ImageEntry>(
                  valueListenable: widget.entryNotifier,
                  builder: (context, entry, child) {
                    return entry != null
                        ? _InfoPageContent(
                            collection: collection,
                            entry: entry,
                            visibleNotifier: widget.visibleNotifier,
                            scrollController: _scrollController,
                            appBar: appBar,
                            split: mqWidth > 400,
                            mqViewInsetsBottom: mqViewInsetsBottom,
                          )
                        : SizedBox.shrink();
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
}

class _InfoPageContent extends StatefulWidget {
  final CollectionLens collection;
  final ImageEntry entry;
  final ValueNotifier<bool> visibleNotifier;
  final ScrollController scrollController;
  final SliverAppBar appBar;
  final bool split;
  final double mqViewInsetsBottom;

  const _InfoPageContent({
    Key key,
    @required this.collection,
    @required this.entry,
    @required this.visibleNotifier,
    @required this.scrollController,
    @required this.appBar,
    @required this.split,
    @required this.mqViewInsetsBottom,
  }) : super(key: key);

  @override
  _InfoPageContentState createState() => _InfoPageContentState();
}

class _InfoPageContentState extends State<_InfoPageContent> {
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

  CollectionLens get collection => widget.collection;

  ImageEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final locationAtTop = widget.split && entry.hasGps;
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
                SizedBox(width: 8),
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
      controller: widget.scrollController,
      slivers: [
        widget.appBar,
        SliverPadding(
          padding: horizontalPadding + EdgeInsets.only(top: 8),
          sliver: basicAndLocationSliver,
        ),
        SliverPadding(
          padding: horizontalPadding + EdgeInsets.only(bottom: 8 + widget.mqViewInsetsBottom),
          sliver: metadataSliver,
        ),
      ],
    );
  }

  void _goToCollection(CollectionFilter filter) {
    if (collection == null) return;
    FilterNotification(filter).dispatch(context);
  }
}
