import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/magnifier/pan/scroll_physics.dart';
import 'package:aves/widgets/viewer/entry_horizontal_pager.dart';
import 'package:aves/widgets/viewer/info/info_page.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ViewerVerticalPageView extends StatefulWidget {
  final CollectionLens collection;
  final ValueNotifier<AvesEntry> entryNotifier;
  final PageController horizontalPager, verticalPager;
  final void Function(int page) onVerticalPageChanged, onHorizontalPageChanged;
  final VoidCallback onImagePageRequested;
  final void Function(String uri) onViewDisposed;

  const ViewerVerticalPageView({
    @required this.collection,
    @required this.entryNotifier,
    @required this.verticalPager,
    @required this.horizontalPager,
    @required this.onVerticalPageChanged,
    @required this.onHorizontalPageChanged,
    @required this.onImagePageRequested,
    @required this.onViewDisposed,
  });

  @override
  _ViewerVerticalPageViewState createState() => _ViewerVerticalPageViewState();
}

class _ViewerVerticalPageViewState extends State<ViewerVerticalPageView> {
  final ValueNotifier<Color> _backgroundColorNotifier = ValueNotifier(Colors.black);
  final ValueNotifier<bool> _infoPageVisibleNotifier = ValueNotifier(false);
  AvesEntry _oldEntry;

  CollectionLens get collection => widget.collection;

  bool get hasCollection => collection != null;

  AvesEntry get entry => widget.entryNotifier.value;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant ViewerVerticalPageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(ViewerVerticalPageView widget) {
    widget.verticalPager.addListener(_onVerticalPageControllerChanged);
    widget.entryNotifier.addListener(_onEntryChanged);
    if (_oldEntry != entry) _onEntryChanged();
  }

  void _unregisterWidget(ViewerVerticalPageView widget) {
    widget.verticalPager.removeListener(_onVerticalPageControllerChanged);
    widget.entryNotifier.removeListener(_onEntryChanged);
    _oldEntry?.imageChangeNotifier?.removeListener(_onImageChanged);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // fake page for opacity transition between collection and viewer
      SizedBox(),
      hasCollection
          ? MultiEntryScroller(
              collection: collection,
              pageController: widget.horizontalPager,
              onPageChanged: widget.onHorizontalPageChanged,
              onViewDisposed: widget.onViewDisposed,
            )
          : SingleEntryScroller(
              entry: entry,
            ),
      NotificationListener(
        onNotification: (notification) {
          if (notification is BackUpNotification) widget.onImagePageRequested();
          return false;
        },
        child: InfoPage(
          collection: collection,
          entryNotifier: widget.entryNotifier,
          visibleNotifier: _infoPageVisibleNotifier,
        ),
      ),
    ];
    return ValueListenableBuilder<Color>(
      valueListenable: _backgroundColorNotifier,
      builder: (context, backgroundColor, child) => Container(
        color: backgroundColor,
        child: child,
      ),
      child: PageView(
        key: Key('vertical-pageview'),
        scrollDirection: Axis.vertical,
        controller: widget.verticalPager,
        physics: MagnifierScrollerPhysics(parent: PageScrollPhysics()),
        onPageChanged: (page) {
          widget.onVerticalPageChanged(page);
          _infoPageVisibleNotifier.value = page == pages.length - 1;
        },
        children: pages,
      ),
    );
  }

  void _onVerticalPageControllerChanged() {
    final opacity = min(1.0, widget.verticalPager.page);
    _backgroundColorNotifier.value = _backgroundColorNotifier.value.withOpacity(opacity * opacity);
  }

  // when the entry changed (e.g. by scrolling through the PageView, or if the entry got deleted)
  void _onEntryChanged() {
    _oldEntry?.imageChangeNotifier?.removeListener(_onImageChanged);
    _oldEntry = entry;

    if (entry != null) {
      entry.imageChangeNotifier.addListener(_onImageChanged);
      // make sure to locate the entry,
      // so that we can display the address instead of coordinates
      // even when initial collection locating has not reached this entry yet
      entry.catalog(background: false).then((_) => entry.locate(background: false));
    } else {
      Navigator.pop(context);
    }
  }

  // when the entry image itself changed (e.g. after rotation)
  void _onImageChanged() async {
    // rebuild to refresh the Image inside ImagePage
    setState(() {});
  }
}
