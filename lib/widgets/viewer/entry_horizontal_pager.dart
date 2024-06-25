import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/enums/viewer_transition.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/viewer/controls/controller.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/multipage/conductor.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves/widgets/viewer/visual/entry_page_view.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiEntryScroller extends StatefulWidget {
  final CollectionLens collection;
  final ViewerController viewerController;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final void Function(AvesEntry mainEntry, AvesEntry? pageEntry) onViewDisposed;

  const MultiEntryScroller({
    super.key,
    required this.collection,
    required this.viewerController,
    required this.pageController,
    required this.onPageChanged,
    required this.onViewDisposed,
  });

  @override
  State<StatefulWidget> createState() => _MultiEntryScrollerState();
}

class _MultiEntryScrollerState extends State<MultiEntryScroller> with AutomaticKeepAliveClientMixin {
  List<AvesEntry> get entries => widget.collection.sortedEntries;

  ViewerController get viewerController => widget.viewerController;

  PageController get pageController => widget.pageController;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return MagnifierGestureDetectorScope(
      axis: const [Axis.horizontal, Axis.vertical],
      child: NotificationListener(
        onNotification: _handleNotification,
        child: PageView.builder(
          // key is expected by test driver
          key: const Key('horizontal-pageview'),
          scrollDirection: Axis.horizontal,
          controller: pageController,
          physics: MagnifierScrollerPhysics(
            gestureSettings: MediaQuery.gestureSettingsOf(context),
            parent: const BouncingScrollPhysics(),
          ),
          onPageChanged: widget.onPageChanged,
          itemBuilder: (context, index) {
            final mainEntry = entries[index % entries.length];

            final child = mainEntry.isMultiPage
                ? PageEntryBuilder(
                    multiPageController: context.read<MultiPageConductor>().getController(mainEntry),
                    builder: (pageEntry) => _buildViewer(mainEntry, pageEntry: pageEntry),
                  )
                : _buildViewer(mainEntry);

            return Selector<Settings, bool>(
              selector: (context, s) => s.animate,
              builder: (context, animate, child) {
                if (!animate) return child!;
                return AnimatedBuilder(
                  animation: pageController,
                  builder: viewerController.transition.builder(pageController, index),
                  child: child,
                );
              },
              child: child,
            );
          },
          itemCount: viewerController.repeat ? null : entries.length,
        ),
      ),
    );
  }

  Widget _buildViewer(AvesEntry mainEntry, {AvesEntry? pageEntry}) {
    return EntryPageView(
      // key is expected by test driver
      key: const Key('image_view'),
      mainEntry: mainEntry,
      pageEntry: pageEntry ?? mainEntry,
      viewerController: viewerController,
      onDisposed: () => widget.onViewDisposed(mainEntry, pageEntry),
    );
  }

  bool _handleNotification(dynamic notification) {
    if (notification is ShowPreviousVideoNotification) {
      _showPreviousVideo();
    } else if (notification is ShowNextVideoNotification) {
      _showNextVideo();
    } else {
      return false;
    }
    return true;
  }

  void _showPreviousVideo() {
    final currentIndex = pageController.page?.round();
    if (currentIndex != null) {
      final previousVideoEntry = entries.take(currentIndex).lastWhereOrNull((entry) => entry.isVideo);
      if (previousVideoEntry != null) {
        final previousIndex = entries.indexOf(previousVideoEntry);
        if (previousIndex != -1) {
          ShowEntryNotification(animate: false, index: previousIndex).dispatch(context);
        }
      }
    }
  }

  void _showNextVideo() {
    final currentIndex = pageController.page?.round();
    if (currentIndex != null) {
      final nextVideoEntry = entries.skip(currentIndex + 1).firstWhereOrNull((entry) => entry.isVideo);
      if (nextVideoEntry != null) {
        final nextIndex = entries.indexOf(nextVideoEntry);
        if (nextIndex != -1) {
          ShowEntryNotification(animate: false, index: nextIndex).dispatch(context);
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleEntryScroller extends StatefulWidget {
  final AvesEntry entry;
  final ViewerController viewerController;

  const SingleEntryScroller({
    super.key,
    required this.entry,
    required this.viewerController,
  });

  @override
  State<StatefulWidget> createState() => _SingleEntryScrollerState();
}

class _SingleEntryScrollerState extends State<SingleEntryScroller> with AutomaticKeepAliveClientMixin {
  AvesEntry get mainEntry => widget.entry;

  ViewerController get viewerController => widget.viewerController;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var child = mainEntry.isMultiPage
        ? PageEntryBuilder(
            multiPageController: context.read<MultiPageConductor>().getController(mainEntry),
            builder: (pageEntry) => _buildViewer(pageEntry: pageEntry),
          )
        : _buildViewer();

    return MagnifierGestureDetectorScope(
      axis: const [Axis.vertical],
      child: child,
    );
  }

  Widget _buildViewer({AvesEntry? pageEntry}) {
    return EntryPageView(
      mainEntry: mainEntry,
      pageEntry: pageEntry ?? mainEntry,
      viewerController: widget.viewerController,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
