import 'package:aves/model/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/magnifier/pan/gesture_detector_scope.dart';
import 'package:aves/widgets/common/magnifier/pan/scroll_physics.dart';
import 'package:aves/widgets/viewer/multipage.dart';
import 'package:aves/widgets/viewer/visual/entry_page_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class MultiEntryScroller extends StatefulWidget {
  final CollectionLens collection;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final List<Tuple2<String, MultiPageController>> multiPageControllers;
  final void Function(String uri) onViewDisposed;

  const MultiEntryScroller({
    this.collection,
    this.pageController,
    this.onPageChanged,
    this.multiPageControllers,
    this.onViewDisposed,
  });

  @override
  State<StatefulWidget> createState() => _MultiEntryScrollerState();
}

class _MultiEntryScrollerState extends State<MultiEntryScroller> with AutomaticKeepAliveClientMixin {
  List<AvesEntry> get entries => widget.collection.sortedEntries;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MagnifierGestureDetectorScope(
      axis: [Axis.horizontal, Axis.vertical],
      child: PageView.builder(
        key: Key('horizontal-pageview'),
        scrollDirection: Axis.horizontal,
        controller: widget.pageController,
        physics: MagnifierScrollerPhysics(parent: BouncingScrollPhysics()),
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          final entry = entries[index];

          Widget child;
          if (entry.isMultipage) {
            final multiPageController = _getMultiPageController(entry);
            if (multiPageController != null) {
              child = FutureBuilder<MultiPageInfo>(
                future: multiPageController.info,
                builder: (context, snapshot) {
                  final multiPageInfo = snapshot.data;
                  return ValueListenableBuilder<int>(
                    valueListenable: multiPageController.pageNotifier,
                    builder: (context, page, child) {
                      return _buildViewer(entry, page: multiPageInfo?.getByIndex(page));
                    },
                  );
                },
              );
            }
          }
          child ??= _buildViewer(entry);

          return ClipRect(
            child: child,
          );
        },
        itemCount: entries.length,
      ),
    );
  }

  Widget _buildViewer(AvesEntry entry, {SinglePageInfo page}) {
    return Selector<MediaQueryData, Size>(
      selector: (c, mq) => mq.size,
      builder: (c, mqSize, child) {
        return EntryPageView(
          key: Key('imageview'),
          mainEntry: entry,
          page: page,
          viewportSize: mqSize,
          onDisposed: () => widget.onViewDisposed?.call(entry.uri),
        );
      },
    );
  }

  MultiPageController _getMultiPageController(AvesEntry entry) {
    return widget.multiPageControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2;
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleEntryScroller extends StatefulWidget {
  final AvesEntry entry;
  final List<Tuple2<String, MultiPageController>> multiPageControllers;

  const SingleEntryScroller({
    this.entry,
    this.multiPageControllers,
  });

  @override
  State<StatefulWidget> createState() => _SingleEntryScrollerState();
}

class _SingleEntryScrollerState extends State<SingleEntryScroller> with AutomaticKeepAliveClientMixin {
  AvesEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget child;
    if (entry.isMultipage) {
      final multiPageController = _getMultiPageController(entry);
      if (multiPageController != null) {
        child = FutureBuilder<MultiPageInfo>(
          future: multiPageController.info,
          builder: (context, snapshot) {
            final multiPageInfo = snapshot.data;
            return ValueListenableBuilder<int>(
              valueListenable: multiPageController.pageNotifier,
              builder: (context, page, child) {
                return _buildViewer(page: multiPageInfo?.getByIndex(page));
              },
            );
          },
        );
      }
    }
    child ??= _buildViewer();

    return MagnifierGestureDetectorScope(
      axis: [Axis.vertical],
      child: child,
    );
  }

  Widget _buildViewer({SinglePageInfo page}) {
    return Selector<MediaQueryData, Size>(
      selector: (c, mq) => mq.size,
      builder: (c, mqSize, child) {
        return EntryPageView(
          mainEntry: entry,
          page: page,
          viewportSize: mqSize,
        );
      },
    );
  }

  MultiPageController _getMultiPageController(AvesEntry entry) {
    return widget.multiPageControllers.firstWhere((kv) => kv.item1 == entry.uri, orElse: () => null)?.item2;
  }

  @override
  bool get wantKeepAlive => true;
}
