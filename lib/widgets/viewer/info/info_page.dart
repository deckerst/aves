import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/insets.dart';
import 'package:aves/widgets/common/basic/scaffold.dart';
import 'package:aves/widgets/common/basic/tv_edge_focus.dart';
import 'package:aves/widgets/viewer/action/entry_info_action_delegate.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/info/basic_section.dart';
import 'package:aves/widgets/viewer/info/color_section.dart';
import 'package:aves/widgets/viewer/info/embedded/embedded_data_opener.dart';
import 'package:aves/widgets/viewer/info/info_app_bar.dart';
import 'package:aves/widgets/viewer/info/location_section.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_dir.dart';
import 'package:aves/widgets/viewer/info/metadata/metadata_section.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InfoPage extends StatefulWidget {
  final CollectionLens? collection;
  final ValueNotifier<AvesEntry?> entryNotifier;
  final ValueNotifier<bool> isScrollingNotifier;
  final ValueNotifier<double> pageInViewNotifier;

  const InfoPage({
    super.key,
    required this.collection,
    required this.entryNotifier,
    required this.isScrollingNotifier,
    required this.pageInViewNotifier,
  });

  @override
  State<StatefulWidget> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  final ScrollController _scrollController = ScrollController();
  bool _scrollStartFromTop = false;

  static const splitScreenWidthThreshold = 600;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AvesScaffold(
      body: GestureAreaProtectorStack(
        child: SafeArea(
          bottom: false,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleTopScroll,
            child: ValueListenableBuilder<AvesEntry?>(
              valueListenable: widget.entryNotifier,
              builder: (context, mainEntry, child) {
                if (mainEntry == null) return const SizedBox();

                final isSelecting = context.select<Selection<AvesEntry>?, bool>((v) => v?.isSelecting ?? false);
                Widget _buildContent({AvesEntry? pageEntry}) {
                  final targetEntry = pageEntry ?? mainEntry;
                  return EmbeddedDataOpener(
                    enabled: !isSelecting,
                    entry: targetEntry,
                    child: _InfoPageContent(
                      collection: widget.collection,
                      entry: targetEntry,
                      isScrollingNotifier: widget.isScrollingNotifier,
                      pageInViewNotifier: widget.pageInViewNotifier,
                      scrollController: _scrollController,
                      split: MediaQuery.sizeOf(context).width > splitScreenWidthThreshold,
                      goToViewer: _goToViewer,
                    ),
                  );
                }

                return mainEntry.isStack
                    ? PageEntryBuilder(
                        multiPageController: context.read<MultiPageConductor>().getController(mainEntry),
                        builder: (pageEntry) => _buildContent(pageEntry: pageEntry),
                      )
                    : _buildContent();
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
    ShowImageNotification().dispatch(context);
    _scrollController.animateTo(
      0,
      duration: ADurations.pageTransitionLoose,
      curve: Curves.easeInOut,
    );
  }
}

class _InfoPageContent extends StatefulWidget {
  final CollectionLens? collection;
  final AvesEntry entry;
  final ValueNotifier<bool> isScrollingNotifier;
  final ValueNotifier<double> pageInViewNotifier;
  final ScrollController scrollController;
  final bool split;
  final VoidCallback goToViewer;

  const _InfoPageContent({
    required this.collection,
    required this.entry,
    required this.isScrollingNotifier,
    required this.pageInViewNotifier,
    required this.scrollController,
    required this.split,
    required this.goToViewer,
  });

  @override
  State<_InfoPageContent> createState() => _InfoPageContentState();
}

class _InfoPageContentState extends State<_InfoPageContent> {
  final Set<StreamSubscription> _subscriptions = {};
  late EntryInfoActionDelegate _actionDelegate;
  final ValueNotifier<bool> _isBasicSectionVisibleNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isMetadataSectionVisibleNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isColorSectionVisibleNotifier = ValueNotifier(false);
  final ValueNotifier<Map<String, MetadataDirectory>> _metadataNotifier = ValueNotifier({});
  final ValueNotifier<EntryAction?> _isEditingMetadataNotifier = ValueNotifier(null);

  static const _basicSectionVisibilityRatio = .2;
  static const _metadataSectionVisibilityRatio = .5;
  static const _colorSectionVisibilityRatio = .8;
  static const _horizontalPadding = EdgeInsets.symmetric(horizontal: 8);

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
      _isBasicSectionVisibleNotifier.value = false;
      _isMetadataSectionVisibleNotifier.value = false;
      _isColorSectionVisibleNotifier.value = false;
    }
  }

  @override
  void dispose() {
    _isBasicSectionVisibleNotifier.dispose();
    _isMetadataSectionVisibleNotifier.dispose();
    _isColorSectionVisibleNotifier.dispose();
    _metadataNotifier.dispose();
    _isEditingMetadataNotifier.dispose();
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(_InfoPageContent widget) {
    _actionDelegate = EntryInfoActionDelegate();
    _subscriptions.add(_actionDelegate.eventStream.listen(_onActionDelegateEvent));
    widget.pageInViewNotifier.addListener(_onPageInViewChanged);
  }

  void _unregisterWidget(_InfoPageContent widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    widget.pageInViewNotifier.removeListener(_onPageInViewChanged);
  }

  void _onPageInViewChanged() {
    final inView = widget.pageInViewNotifier.value;
    _isBasicSectionVisibleNotifier.value |= inView > _basicSectionVisibilityRatio;
    _isMetadataSectionVisibleNotifier.value |= inView > _metadataSectionVisibilityRatio;
    _isColorSectionVisibleNotifier.value |= inView > _colorSectionVisibilityRatio;
  }

  @override
  Widget build(BuildContext context) {
    final basicSection = BasicSection(
      entry: entry,
      collection: collection,
      actionDelegate: _actionDelegate,
      isScrollingNotifier: widget.isScrollingNotifier,
      isEditingMetadataNotifier: _isEditingMetadataNotifier,
      onFilterSelection: _onFilterSelection,
    );
    final locationAtTop = widget.split && entry.hasGps;
    final locationSection = LocationSection(
      collection: collection,
      entry: entry,
      showTitle: !locationAtTop,
      isScrollingNotifier: widget.isScrollingNotifier,
      onFilterSelection: _onFilterSelection,
    );
    final basicAndLocationSliver = locationAtTop
        ? SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: .start,
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
              addAutomaticKeepAlives: true,
            ),
          );

    return NotificationListener<SelectFilterNotification>(
      onNotification: (notification) {
        _onFilterSelection(notification.filter);
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
          ValueListenableBuilder<bool>(
            valueListenable: _isBasicSectionVisibleNotifier,
            builder: (context, visible, child) {
              return visible
                  ? SliverPadding(
                      padding: _horizontalPadding + const EdgeInsets.only(top: 8),
                      sliver: basicAndLocationSliver,
                    )
                  : const SliverToBoxAdapter(child: SizedBox());
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isMetadataSectionVisibleNotifier,
            builder: (context, visible, child) {
              return visible
                  ? SliverPadding(
                      padding: _horizontalPadding + const EdgeInsets.only(bottom: 8),
                      sliver: MetadataSectionSliver(
                        entry: entry,
                        metadataNotifier: _metadataNotifier,
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox());
            },
          ),
          if (!settings.useTvLayout)
            ValueListenableBuilder<bool>(
              valueListenable: _isColorSectionVisibleNotifier,
              builder: (context, visible, child) {
                return visible
                    ? SliverPadding(
                        padding: _horizontalPadding + const EdgeInsets.only(bottom: 8),
                        sliver: ColorSectionSliver(entry: entry),
                      )
                    : const SliverToBoxAdapter(child: SizedBox());
              },
            ),
          const BottomPaddingSliver(),
        ],
      ),
    );
  }

  void _onActionDelegateEvent(ActionEvent<EntryAction> event) {
    Future.delayed(ADurations.dialogTransitionLoose).then((_) {
      if (!mounted) return;
      if (event is ActionStartedEvent) {
        _isEditingMetadataNotifier.value = event.action;
      } else if (event is ActionEndedEvent) {
        _isEditingMetadataNotifier.value = null;
      }
    });
  }

  void _onFilterSelection(CollectionFilter filter) {
    if (!mounted) return;
    SelectFilterNotification(filter).dispatch(context);
  }
}
