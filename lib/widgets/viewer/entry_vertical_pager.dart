import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/magnifier/pan/scroll_physics.dart';
import 'package:aves/widgets/viewer/entry_horizontal_pager.dart';
import 'package:aves/widgets/viewer/info/info_page.dart';
import 'package:aves/widgets/viewer/info/notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';

class ViewerVerticalPageView extends StatefulWidget {
  final CollectionLens? collection;
  final ValueNotifier<AvesEntry?> entryNotifier;
  final PageController horizontalPager, verticalPager;
  final void Function(int page) onVerticalPageChanged, onHorizontalPageChanged;
  final VoidCallback onImagePageRequested;
  final void Function(AvesEntry mainEntry, AvesEntry? pageEntry) onViewDisposed;

  const ViewerVerticalPageView({
    Key? key,
    required this.collection,
    required this.entryNotifier,
    required this.verticalPager,
    required this.horizontalPager,
    required this.onVerticalPageChanged,
    required this.onHorizontalPageChanged,
    required this.onImagePageRequested,
    required this.onViewDisposed,
  }) : super(key: key);

  @override
  State<ViewerVerticalPageView> createState() => _ViewerVerticalPageViewState();
}

class _ViewerVerticalPageViewState extends State<ViewerVerticalPageView> {
  final ValueNotifier<double> _backgroundOpacityNotifier = ValueNotifier(1);
  final ValueNotifier<bool> _isVerticallyScrollingNotifier = ValueNotifier(false);
  Timer? _verticalScrollMonitoringTimer;
  AvesEntry? _oldEntry;
  Future<double>? _systemBrightness;

  CollectionLens? get collection => widget.collection;

  bool get hasCollection => collection != null;

  AvesEntry? get entry => widget.entryNotifier.value;

  static const double maximumBrightness = 1.0;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);

    if (settings.viewerMaxBrightness) {
      _systemBrightness = ScreenBrightness().system;
    }
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
    _stopScrollMonitoringTimer();
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
    _oldEntry?.imageChangeNotifier.removeListener(_onImageChanged);
  }

  @override
  Widget build(BuildContext context) {
    // fake page for opacity transition between collection and viewer
    const transitionPage = SizedBox();

    final imagePage = _buildImagePage();

    final infoPage = NotificationListener<ShowImageNotification>(
      onNotification: (notification) {
        widget.onImagePageRequested();
        return true;
      },
      child: AnimatedBuilder(
        animation: widget.verticalPager,
        builder: (context, child) {
          return Visibility(
            visible: widget.verticalPager.page! > 1,
            child: child!,
          );
        },
        child: InfoPage(
          collection: collection,
          entryNotifier: widget.entryNotifier,
          isScrollingNotifier: _isVerticallyScrollingNotifier,
        ),
      ),
    );

    final pages = [
      transitionPage,
      imagePage,
      infoPage,
    ];
    return ValueListenableBuilder<double>(
      valueListenable: _backgroundOpacityNotifier,
      builder: (context, backgroundOpacity, child) {
        final background = Theme.of(context).brightness == Brightness.dark ? Colors.black : Colors.white;
        return Container(
          color: background.withOpacity(backgroundOpacity),
          child: child,
        );
      },
      child: PageView(
        // key is expected by test driver
        key: const Key('vertical-pageview'),
        scrollDirection: Axis.vertical,
        controller: widget.verticalPager,
        physics: const MagnifierScrollerPhysics(parent: PageScrollPhysics()),
        onPageChanged: widget.onVerticalPageChanged,
        children: pages,
      ),
    );
  }

  Widget _buildImagePage() {
    Widget? child;
    Map<ShortcutActivator, Intent>? shortcuts;

    if (hasCollection) {
      child = MultiEntryScroller(
        collection: collection!,
        pageController: widget.horizontalPager,
        onPageChanged: widget.onHorizontalPageChanged,
        onViewDisposed: widget.onViewDisposed,
      );
      shortcuts = const {
        SingleActivator(LogicalKeyboardKey.arrowLeft): ShowPreviousIntent(),
        SingleActivator(LogicalKeyboardKey.arrowRight): ShowNextIntent(),
        SingleActivator(LogicalKeyboardKey.arrowUp): LeaveIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): ShowInfoIntent(),
      };
    } else if (entry != null) {
      child = SingleEntryScroller(
        entry: entry!,
      );
      shortcuts = const {
        SingleActivator(LogicalKeyboardKey.arrowUp): LeaveIntent(),
        SingleActivator(LogicalKeyboardKey.arrowDown): ShowInfoIntent(),
      };
    }
    if (child != null) {
      return FocusableActionDetector(
        autofocus: true,
        shortcuts: shortcuts,
        actions: {
          ShowPreviousIntent: CallbackAction<Intent>(onInvoke: (intent) => _jumpHorizontalPage(-1)),
          ShowNextIntent: CallbackAction<Intent>(onInvoke: (intent) => _jumpHorizontalPage(1)),
          LeaveIntent: CallbackAction<Intent>(onInvoke: (intent) => Navigator.pop(context)),
          ShowInfoIntent: CallbackAction<Intent>(onInvoke: (intent) => ShowInfoNotification().dispatch(context)),
        },
        child: child,
      );
    }
    return const SizedBox();
  }

  void _jumpHorizontalPage(int delta) {
    final pageController = widget.horizontalPager;
    final page = pageController.page?.round();
    final _collection = collection;
    if (page != null && _collection != null) {
      final target = (page + delta).clamp(0, _collection.entryCount - 1);
      pageController.jumpToPage(target);
    }
  }

  void _onVerticalPageControllerChanged() {
    final page = widget.verticalPager.page!;

    final opacity = min(1.0, page);
    _backgroundOpacityNotifier.value = opacity * opacity;

    if (page <= 1 && settings.viewerMaxBrightness) {
      _systemBrightness?.then((system) {
        final transition = max(system, lerpDouble(system, maximumBrightness, page / 2)!);
        ScreenBrightness().setScreenBrightness(transition);
      });
    }

    _isVerticallyScrollingNotifier.value = true;
    _stopScrollMonitoringTimer();
    _verticalScrollMonitoringTimer = Timer(Durations.infoScrollMonitoringTimerDelay, () {
      _isVerticallyScrollingNotifier.value = false;
    });
  }

  void _stopScrollMonitoringTimer() {
    _verticalScrollMonitoringTimer?.cancel();
  }

  // when the entry changed (e.g. by scrolling through the PageView, or if the entry got deleted)
  Future<void> _onEntryChanged() async {
    _oldEntry?.imageChangeNotifier.removeListener(_onImageChanged);
    _oldEntry = entry;

    final _entry = entry;
    if (_entry != null) {
      _entry.imageChangeNotifier.addListener(_onImageChanged);
      // make sure to locate the entry,
      // so that we can display the address instead of coordinates
      // even when initial collection locating has not reached this entry yet
      await _entry.catalog(background: false, force: false, persist: true);
      await _entry.locate(background: false, force: false, geocoderLocale: settings.appliedLocale);
    } else {
      Navigator.pop(context);
    }

    // needed to refresh when entry changes but the page does not (e.g. on page deletion)
    if (mounted) {
      setState(() {});
    }
  }

  // when the entry image itself changed (e.g. after rotation)
  void _onImageChanged() async {
    // rebuild to refresh the Image inside ImagePage
    if (mounted) {
      setState(() {});
    }
  }
}

// keyboard shortcut intents

class ShowPreviousIntent extends Intent {
  const ShowPreviousIntent();
}

class ShowNextIntent extends Intent {
  const ShowNextIntent();
}

class LeaveIntent extends Intent {
  const LeaveIntent();
}

class ShowInfoIntent extends Intent {
  const ShowInfoIntent();
}
