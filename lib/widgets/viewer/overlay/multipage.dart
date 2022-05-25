import 'package:aves/model/multipage.dart';
import 'package:aves/widgets/common/thumbnail/scroller.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiPageOverlay extends StatefulWidget {
  final MultiPageController controller;
  final double availableWidth;
  final bool scrollable;

  const MultiPageOverlay({
    super.key,
    required this.controller,
    required this.availableWidth,
    required this.scrollable,
  });

  @override
  State<MultiPageOverlay> createState() => _MultiPageOverlayState();
}

class _MultiPageOverlayState extends State<MultiPageOverlay> {
  int? _previousPage;

  MultiPageController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant MultiPageOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != controller) {
      _unregisterWidget(oldWidget);
      _registerWidget(widget);
    }
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(MultiPageOverlay widget) {
    widget.controller.pageNotifier.addListener(_onPageChange);
  }

  void _unregisterWidget(MultiPageOverlay widget) {
    widget.controller.pageNotifier.removeListener(_onPageChange);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<MultiPageInfo?>(
      stream: controller.infoStream,
      builder: (context, snapshot) {
        final multiPageInfo = controller.info;
        return ThumbnailScroller(
          key: ValueKey(multiPageInfo),
          availableWidth: widget.availableWidth,
          entryCount: multiPageInfo?.pageCount ?? 0,
          entryBuilder: (page) => multiPageInfo?.getPageEntryByIndex(page),
          indexNotifier: controller.pageNotifier,
          scrollable: widget.scrollable,
        );
      },
    );
  }

  void _onPageChange() {
    if (_previousPage != null) {
      final info = controller.info;
      if (info != null) {
        final oldPageEntry = info.getPageEntryByIndex(_previousPage);
        context.read<ViewStateConductor>().reset(oldPageEntry);
      }
    }
    _previousPage = controller.page;
  }
}
