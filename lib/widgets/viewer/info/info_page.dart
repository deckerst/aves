import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/behaviour/routes.dart';
import 'package:aves/widgets/common/providers/media_query_data_provider.dart';
import 'package:aves/widgets/viewer/entry_viewer_page.dart';
import 'package:aves/widgets/viewer/info/basic_section.dart';
import 'package:aves/widgets/viewer/info/info_app_bar.dart';
import 'package:aves/widgets/viewer/info/location_section.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  final CollectionLens? collection;
  final ValueNotifier<AvesEntry?> entryNotifier;
  final ValueNotifier<bool> isScrollingNotifier;

  const InfoPage({
    Key? key,
    required this.collection,
    required this.entryNotifier,
    required this.isScrollingNotifier,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final ScrollController _scrollController = ScrollController();
  bool _scrollStartFromTop = false;

  CollectionLens? get collection => widget.collection;

  AvesEntry? get entry => widget.entryNotifier.value;

  @override
  Widget build(BuildContext context) {
    return MediaQueryDataProvider(
      child: Scaffold(
        body: GestureAreaProtectorStack(
          child: SafeArea(
            bottom: false,
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleTopScroll,
              child: NotificationListener<OpenTempEntryNotification>(
                onNotification: (notification) {
                  _openTempEntry(notification.entry);
                  return true;
                },
                child: Selector<MediaQueryData, double>(
                  selector: (c, mq) => mq.size.width,
                  builder: (c, mqWidth, child) {
                    return ValueListenableBuilder<AvesEntry?>(
                      valueListenable: widget.entryNotifier,
                      builder: (context, entry, child) {
                        return entry != null
                            ? _InfoPageContent(
                                collection: collection,
                                entry: entry,
                                isScrollingNotifier: widget.isScrollingNotifier,
                                scrollController: _scrollController,
                                split: mqWidth > 600,
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
        ),
        resizeToAvoidBottomInset: false,
      ),
    );
  }

  bool _handleTopScroll(ScrollNotification notification) {
    if (notification is ScrollStartNotification) {
      final metrics = notification.metrics;
      _scrollStartFromTop = metrics.pixels == metrics.minScrollExtent;
    }
    if (_scrollStartFromTop) {
      if (notification is ScrollUpdateNotification) {
        _scrollStartFromTop = notification.scrollDelta! < 0;
      } else if (notification is ScrollEndNotification) {
        _scrollStartFromTop = false;
      } else if (notification is OverscrollNotification) {
        if (notification.overscroll < 0) {
          _goToViewer();
          _scrollStartFromTop = false;
        }
      }
    }
    return false;
  }

  void _goToViewer() {
    BackUpNotification().dispatch(context);
    _scrollController.animateTo(
      0,
      duration: Durations.viewerVerticalPageScrollAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _openTempEntry(AvesEntry tempEntry) {
    Navigator.push(
      context,
      TransparentMaterialPageRoute(
        settings: RouteSettings(name: EntryViewerPage.routeName),
        pageBuilder: (c, a, sa) => EntryViewerPage(
          initialEntry: tempEntry,
        ),
      ),
    );
  }
}

class _InfoPageContent extends StatefulWidget {
  final CollectionLens? collection;
  final AvesEntry entry;
  final ValueNotifier<bool> isScrollingNotifier;
  final ScrollController scrollController;
  final bool split;
  final VoidCallback goToViewer;

  const _InfoPageContent({
    Key? key,
    required this.collection,
    required this.entry,
    required this.isScrollingNotifier,
    required this.scrollController,
    required this.split,
    required this.goToViewer,
  }) : super(key: key);

  @override
  _InfoPageContentState createState() => _InfoPageContentState();
}

class _InfoPageContentState extends State<_InfoPageContent> {
  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

  final ValueNotifier<Map<String, MetadataDirectory>> _metadataNotifier = ValueNotifier({});

  CollectionLens? get collection => widget.collection;

  AvesEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final basicSection = BasicSection(
      entry: entry,
      collection: collection,
      onFilter: _goToCollection,
    );
    final locationAtTop = widget.split && entry.hasGps;
    final locationSection = LocationSection(
      collection: collection,
      entry: entry,
      showTitle: !locationAtTop,
      isScrollingNotifier: widget.isScrollingNotifier,
      onFilter: _goToCollection,
    );
    final basicAndLocationSliver = locationAtTop
        ? SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: basicSection),
                SizedBox(width: 8),
                Expanded(child: locationSection),
              ],
            ),
          )
        : SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                basicSection,
                locationSection,
              ],
            ),
          );
    final metadataSliver = MetadataSectionSliver(
      entry: entry,
      metadataNotifier: _metadataNotifier,
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
          padding: horizontalPadding + EdgeInsets.only(bottom: 8),
          sliver: metadataSliver,
        ),
        BottomPaddingSliver(),
      ],
    );
  }

  void _goToCollection(CollectionFilter filter) {
    if (collection == null) return;
    FilterSelectedNotification(filter).dispatch(context);
  }
}
