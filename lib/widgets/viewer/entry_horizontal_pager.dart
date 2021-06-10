import 'package:aves/model/entry.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/magnifier/pan/gesture_detector_scope.dart';
import 'package:aves/widgets/common/magnifier/pan/scroll_physics.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/visual/entry_page_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiEntryScroller extends StatefulWidget {
  final CollectionLens collection;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final void Function(String uri) onViewDisposed;

  const MultiEntryScroller({
    required this.collection,
    required this.pageController,
    required this.onPageChanged,
    required this.onViewDisposed,
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
        key: const Key('horizontal-pageview'),
        scrollDirection: Axis.horizontal,
        controller: widget.pageController,
        physics: const MagnifierScrollerPhysics(parent: BouncingScrollPhysics()),
        onPageChanged: widget.onPageChanged,
        itemBuilder: (context, index) {
          final entry = entries[index];

          Widget? child;
          if (entry.isMultiPage) {
            final multiPageController = context.read<MultiPageConductor>().getController(entry);
            if (multiPageController != null) {
              child = StreamBuilder<MultiPageInfo?>(
                stream: multiPageController.infoStream,
                builder: (context, snapshot) {
                  final multiPageInfo = multiPageController.info;
                  return ValueListenableBuilder<int?>(
                    valueListenable: multiPageController.pageNotifier,
                    builder: (context, page, child) {
                      return _buildViewer(entry, pageEntry: multiPageInfo?.getPageEntryByIndex(page));
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

  Widget _buildViewer(AvesEntry mainEntry, {AvesEntry? pageEntry}) {
    return Selector<MediaQueryData, Size>(
      selector: (c, mq) => mq.size,
      builder: (c, mqSize, child) {
        return EntryPageView(
          key: const Key('imageview'),
          mainEntry: mainEntry,
          pageEntry: pageEntry ?? mainEntry,
          viewportSize: mqSize,
          onDisposed: () => widget.onViewDisposed(mainEntry.uri),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleEntryScroller extends StatefulWidget {
  final AvesEntry entry;

  const SingleEntryScroller({
    required this.entry,
  });

  @override
  State<StatefulWidget> createState() => _SingleEntryScrollerState();
}

class _SingleEntryScrollerState extends State<SingleEntryScroller> with AutomaticKeepAliveClientMixin {
  AvesEntry get mainEntry => widget.entry;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget? child;
    if (mainEntry.isMultiPage) {
      final multiPageController = context.read<MultiPageConductor>().getController(mainEntry);
      if (multiPageController != null) {
        child = StreamBuilder<MultiPageInfo?>(
          stream: multiPageController.infoStream,
          builder: (context, snapshot) {
            final multiPageInfo = multiPageController.info;
            return ValueListenableBuilder<int?>(
              valueListenable: multiPageController.pageNotifier,
              builder: (context, page, child) {
                return _buildViewer(pageEntry: multiPageInfo?.getPageEntryByIndex(page));
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

  Widget _buildViewer({AvesEntry? pageEntry}) {
    return Selector<MediaQueryData, Size>(
      selector: (c, mq) => mq.size,
      builder: (c, mqSize, child) {
        return EntryPageView(
          mainEntry: mainEntry,
          pageEntry: pageEntry ?? mainEntry,
          viewportSize: mqSize,
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
