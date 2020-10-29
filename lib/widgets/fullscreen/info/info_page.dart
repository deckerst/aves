import 'dart:collection';

import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/widgets/common/data_providers/media_query_data_provider.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/info/basic_section.dart';
import 'package:aves/widgets/fullscreen/info/location_section.dart';
import 'package:aves/widgets/fullscreen/info/metadata_section.dart';
import 'package:aves/widgets/fullscreen/info/notifications.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
  List<MetadataDirectory> _metadata = [];
  String _loadedMetadataUri;

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

  CollectionLens get collection => widget.collection;

  ImageEntry get entry => widget.entry;

  bool get isVisible => widget.visibleNotifier.value;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    _getMetadata();
  }

  @override
  void didUpdateWidget(_InfoPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
    _getMetadata();
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(_InfoPageContent widget) {
    widget.visibleNotifier.addListener(_getMetadata);
    widget.entry.metadataChangeNotifier.addListener(_onMetadataChanged);
  }

  void _unregisterWidget(_InfoPageContent widget) {
    widget.visibleNotifier.removeListener(_getMetadata);
    widget.entry.metadataChangeNotifier.removeListener(_onMetadataChanged);
  }

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
      metadata: _metadata,
    );

    return AnimationLimiter(
      // we update the limiter key after fetching the metadata of a new entry,
      // in order to restart the staggered animation of the metadata section
      key: Key(_loadedMetadataUri),
      child: CustomScrollView(
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
      ),
    );
  }

  void _goToCollection(CollectionFilter filter) {
    if (collection == null) return;
    FilterNotification(filter).dispatch(context);
  }

  void _onMetadataChanged() {
    _metadata = [];
    _loadedMetadataUri = null;
    _getMetadata();
  }

  // fetch and hold metadata in the page widget and not in the section sliver,
  // so that we can refresh and limit the staggered animation of the metadata section
  Future<void> _getMetadata() async {
    if (entry == null) return;
    if (_loadedMetadataUri == entry.uri) return;
    if (isVisible) {
      final rawMetadata = await MetadataService.getAllMetadata(entry) ?? {};
      _metadata = rawMetadata.entries.map((dirKV) {
        final directoryName = dirKV.key as String ?? '';
        final rawTags = dirKV.value as Map ?? {};
        final tags = SplayTreeMap.of(Map.fromEntries(rawTags.entries.map((tagKV) {
          final value = tagKV.value as String ?? '';
          if (value.isEmpty) return null;
          final tagName = tagKV.key as String ?? '';
          return MapEntry(tagName, value);
        }).where((kv) => kv != null)));
        return MetadataDirectory(directoryName, tags);
      }).toList()
        ..sort((a, b) => compareAsciiUpperCase(a.name, b.name));
      _loadedMetadataUri = entry.uri;
    } else {
      _metadata = [];
      _loadedMetadataUri = null;
    }
    // _expandedDirectoryNotifier.value = null;
    if (mounted) setState(() {});
  }
}
