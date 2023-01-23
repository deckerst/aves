import 'dart:async';

import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/actions/events.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/basic/tv_edge_focus.dart';
import 'package:aves/widgets/filter_grids/common/action_delegates/chip.dart';
import 'package:aves/widgets/viewer/action/entry_info_action_delegate.dart';
import 'package:aves/widgets/viewer/embedded/embedded_data_opener.dart';
import 'package:aves/widgets/viewer/info/basic_section.dart';
import 'package:aves/widgets/viewer/info/info_app_bar.dart';
import 'package:aves/widgets/viewer/info/location_section.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/notifications.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  final CollectionLens? collection;
  final ValueNotifier<AvesEntry?> entryNotifier;
  final ValueNotifier<bool> isScrollingNotifier;

  const InfoPage({
    super.key,
    required this.collection,
    required this.entryNotifier,
    required this.isScrollingNotifier,
  });

  @override
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _scrollStartFromTop = false;

  static const splitScreenWidthThreshold = 600;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    _onScrollingChanged();
  }

  @override
  void didUpdateWidget(covariant InfoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _registerWidget(InfoPage widget) {
    widget.isScrollingNotifier.addListener(_onScrollingChanged);
  }

  void _unregisterWidget(InfoPage widget) {
    widget.isScrollingNotifier.removeListener(_onScrollingChanged);
  }

  void _onScrollingChanged() {
    if (!widget.isScrollingNotifier.value) {
      // using `autofocus` while scrolling seems to fail for widget built offscreen
      // so we give focus to this page when the screen is no longer scrolling
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      body: GestureAreaProtectorStack(
        child: SafeArea(
          bottom: false,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleTopScroll,
            child: Selector<MediaQueryData, double>(
              selector: (context, mq) => mq.size.width,
              builder: (context, mqWidth, child) {
                return ValueListenableBuilder<AvesEntry?>(
                  valueListenable: widget.entryNotifier,
                  builder: (context, mainEntry, child) {
                    if (mainEntry == null) return const SizedBox();

                    Widget _buildContent({AvesEntry? pageEntry}) {
                      final targetEntry = pageEntry ?? mainEntry;
                      return EmbeddedDataOpener(
                        entry: targetEntry,
                        child: Focus(
                          focusNode: _focusNode,
                          child: _InfoPageContent(
                            collection: widget.collection,
                            entry: targetEntry,
                            isScrollingNotifier: widget.isScrollingNotifier,
                            scrollController: _scrollController,
                            split: mqWidth > splitScreenWidthThreshold,
                            goToViewer: _goToViewer,
                          ),
                        ),
                      );
                    }

                    return mainEntry.isBurst
                        ? PageEntryBuilder(
                            multiPageController: context.read<MultiPageConductor>().getController(mainEntry),
                            builder: (pageEntry) => _buildContent(pageEntry: pageEntry),
                          )
                        : _buildContent();
                  },
                );
              },
            ),
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
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
    final animationDuration = context.read<DurationsData>().viewerVerticalPageScrollAnimation;
    ShowImageNotification().dispatch(context);
    _scrollController.animateTo(
      0,
      duration: animationDuration,
      curve: Curves.easeInOut,
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
    required this.collection,
    required this.entry,
    required this.isScrollingNotifier,
    required this.scrollController,
    required this.split,
    required this.goToViewer,
  });

  @override
  State<_InfoPageContent> createState() => _InfoPageContentState();
}

class _InfoPageContentState extends State<_InfoPageContent> {
  final List<StreamSubscription> _subscriptions = [];
  late EntryInfoActionDelegate _actionDelegate;
  final ValueNotifier<Map<String, MetadataDirectory>> _metadataNotifier = ValueNotifier({});
  final ValueNotifier<EntryAction?> _isEditingMetadataNotifier = ValueNotifier(null);

  static const horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

  CollectionLens? get collection => widget.collection;

  AvesEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant _InfoPageContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.entry != widget.entry) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _metadataNotifier.dispose();
    _isEditingMetadataNotifier.dispose();
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(_InfoPageContent widget) {
    _actionDelegate = EntryInfoActionDelegate();
    _subscriptions.add(_actionDelegate.eventStream.listen(_onActionDelegateEvent));
  }

  void _unregisterWidget(_InfoPageContent widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    final basicSection = BasicSection(
      entry: entry,
      collection: collection,
      actionDelegate: _actionDelegate,
      isEditingMetadataNotifier: _isEditingMetadataNotifier,
      onFilter: _onFilter,
    );
    final locationAtTop = widget.split && entry.hasGps;
    final locationSection = LocationSection(
      collection: collection,
      entry: entry,
      showTitle: !locationAtTop,
      isScrollingNotifier: widget.isScrollingNotifier,
      onFilter: _onFilter,
    );
    final basicAndLocationSliver = locationAtTop
        ? SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: basicSection),
                const SizedBox(width: 8),
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

    return NotificationListener<ReverseFilterNotification>(
      onNotification: (notification) {
        _onFilter(notification.reversedFilter);
        return true;
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          const SliverToBoxAdapter(
            child: TvEdgeFocus(),
          ),
          InfoAppBar(
            entry: entry,
            collection: collection,
            actionDelegate: _actionDelegate,
            metadataNotifier: _metadataNotifier,
            onBackPressed: widget.goToViewer,
          ),
          SliverPadding(
            padding: horizontalPadding + const EdgeInsets.only(top: 8),
            sliver: basicAndLocationSliver,
          ),
          SliverPadding(
            padding: horizontalPadding + const EdgeInsets.only(bottom: 8),
            sliver: metadataSliver,
          ),
          const BottomPaddingSliver(),
        ],
      ),
    );
  }

  void _onActionDelegateEvent(ActionEvent<EntryAction> event) {
    Future.delayed(Durations.dialogTransitionAnimation).then((_) {
      if (event is ActionStartedEvent) {
        _isEditingMetadataNotifier.value = event.action;
      } else if (event is ActionEndedEvent) {
        _isEditingMetadataNotifier.value = null;
      }
    });
  }

  void _onFilter(CollectionFilter filter) => FilterSelectedNotification(filter).dispatch(context);
}
