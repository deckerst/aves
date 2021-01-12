import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/gesture_area_protector.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/viewer/info/basic_section.dart';
import 'package:aves/widgets/viewer/info/info_app_bar.dart';
import 'package:aves/widgets/viewer/info/location_section.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
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
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final ScrollController _scrollController = ScrollController();
  bool _scrollStartFromTop = false;

  CollectionLens get collection => widget.collection;

  ImageEntry get entry => widget.entryNotifier.value;

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: GestureAreaProtectorStack(
          child: SafeArea(
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
                              split: mqWidth > 400,
                              mqViewInsetsBottom: mqViewInsetsBottom,
                              goToViewer: _goToViewer,
                            )
                          : SizedBox.shrink();
                    },
                  );
                },
              ),
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
            _goToViewer();
            _scrollStartFromTop = false;
          }
        }
      }
    }
    return false;
  }

  void _goToViewer() {
    BackUpNotification().dispatch(context);
    _scrollController.animateTo(
      0,
      duration: Durations.viewerPageAnimation,
      curve: Curves.easeInOut,
    );
  }
}

class _InfoPageContent extends StatefulWidget {
  final CollectionLens collection;
  final ImageEntry entry;
  final ValueNotifier<bool> visibleNotifier;
  final ScrollController scrollController;
  final bool split;
  final double mqViewInsetsBottom;
  final VoidCallback goToViewer;

  const _InfoPageContent({
    Key key,
    @required this.collection,
    @required this.entry,
    @required this.visibleNotifier,
    @required this.scrollController,
    @required this.split,
    @required this.mqViewInsetsBottom,
    @required this.goToViewer,
  }) : super(key: key);

  @override
  _InfoPageContentState createState() => _InfoPageContentState();
}

class _InfoPageContentState extends State<_InfoPageContent> {
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

  final ValueNotifier<Map<String, MetadataDirectory>> _metadataNotifier = ValueNotifier({});

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
      metadataNotifier: _metadataNotifier,
      visibleNotifier: widget.visibleNotifier,
    );

    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        InfoAppBar(
          entry: entry,
          metadataNotifier: _metadataNotifier,
          onBackPressed: widget.goToViewer,
        ),
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
