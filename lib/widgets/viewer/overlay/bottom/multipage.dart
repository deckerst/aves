import 'package:aves/model/multipage.dart';
import 'package:aves/widgets/common/thumbnail/scroller.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/visual/conductor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiPageOverlay extends StatefulWidget {
  final MultiPageController controller;
  final double availableWidth;

  const MultiPageOverlay({
    Key? key,
    required this.controller,
    required this.availableWidth,
  }) : super(key: key);

  @override
  _MultiPageOverlayState createState() => _MultiPageOverlayState();
}

class _MultiPageOverlayState extends State<MultiPageOverlay> {
  int? _initControllerPage;

  MultiPageController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _registerWidget();
  }

  @override
  void didUpdateWidget(covariant MultiPageOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != controller) {
      _registerWidget();
    }
  }

  void _registerWidget() {
    _initControllerPage = controller.page;
    if (_initControllerPage == null) {
      _correctDefaultPageScroll();
    }
  }

  // correct scroll offset to match default page
  // if default page was unknown when the scroll controller was created
  void _correctDefaultPageScroll() async {
    await controller.infoStream.first;
    if (_initControllerPage == null) {
      setState(() => _initControllerPage = controller.page);
    }
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
          initialIndex: _initControllerPage,
          isCurrentIndex: (page) => controller.page == page,
          onIndexChange: _setPage,
        );
      },
    );
  }

  void _setPage(int newPage) {
    final oldPage = controller.page;
    if (oldPage == newPage) return;

    final oldPageEntry = controller.info!.getPageEntryByIndex(oldPage);
    controller.page = newPage;
    context.read<ViewStateConductor>().reset(oldPageEntry);
  }
}
