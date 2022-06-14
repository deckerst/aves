import 'dart:math';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/multipage.dart';
import 'package:aves/widgets/viewer/overlay/thumbnail_preview.dart';
import 'package:aves/widgets/viewer/overlay/viewer_buttons.dart';
import 'package:aves/widgets/viewer/overlay/wallpaper_buttons.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerBottomOverlay extends StatefulWidget {
  final List<AvesEntry> entries;
  final int index;
  final bool hasCollection;
  final AnimationController animationController;
  final EdgeInsets? viewInsets, viewPadding;
  final MultiPageController? multiPageController;

  const ViewerBottomOverlay({
    super.key,
    required this.entries,
    required this.index,
    required this.hasCollection,
    required this.animationController,
    this.viewInsets,
    this.viewPadding,
    required this.multiPageController,
  });

  @override
  State<StatefulWidget> createState() => _ViewerBottomOverlayState();

  static double actionSafeHeight(BuildContext context) {
    return ViewerButtons.preferredHeight(context) + (settings.showOverlayThumbnailPreview ? ViewerThumbnailPreview.preferredHeight : 0);
  }
}

class _ViewerBottomOverlayState extends State<ViewerBottomOverlay> {
  List<AvesEntry> get entries => widget.entries;

  AvesEntry? get entry {
    final index = widget.index;
    return index < entries.length ? entries[index] : null;
  }

  MultiPageController? get multiPageController => widget.multiPageController;

  @override
  Widget build(BuildContext context) {
    final mainEntry = entry;
    if (mainEntry == null) return const SizedBox();

    Widget _buildContent({AvesEntry? pageEntry}) => _BottomOverlayContent(
          entries: entries,
          index: widget.index,
          mainEntry: mainEntry,
          pageEntry: pageEntry ?? mainEntry,
          hasCollection: widget.hasCollection,
          viewInsets: widget.viewInsets,
          viewPadding: widget.viewPadding,
          multiPageController: multiPageController,
          animationController: widget.animationController,
        );

    Widget child = multiPageController != null
        ? PageEntryBuilder(
            multiPageController: multiPageController!,
            builder: (pageEntry) => _buildContent(pageEntry: pageEntry),
          )
        : _buildContent();

    return Selector<MediaQueryData, double>(
      selector: (context, mq) => max(mq.effectiveBottomPadding, mq.systemGestureInsets.bottom),
      builder: (context, mqPaddingBottom, child) {
        return Padding(
          padding: EdgeInsets.only(bottom: mqPaddingBottom),
          child: child,
        );
      },
      child: child,
    );
  }
}

class _BottomOverlayContent extends StatefulWidget {
  final List<AvesEntry> entries;
  final int index;
  final AvesEntry mainEntry, pageEntry;
  final bool hasCollection;
  final EdgeInsets? viewInsets, viewPadding;
  final MultiPageController? multiPageController;
  final AnimationController animationController;

  const _BottomOverlayContent({
    required this.entries,
    required this.index,
    required this.mainEntry,
    required this.pageEntry,
    required this.hasCollection,
    required this.viewInsets,
    required this.viewPadding,
    required this.multiPageController,
    required this.animationController,
  });

  @override
  State<_BottomOverlayContent> createState() => _BottomOverlayContentState();
}

class _BottomOverlayContentState extends State<_BottomOverlayContent> {
  late Animation<double> _buttonScale, _thumbnailOpacity;

  @override
  void initState() {
    super.initState();
    final animationController = widget.animationController;
    _buttonScale = CurvedAnimation(
      parent: animationController,
      // a little bounce at the top
      curve: Curves.easeOutBack,
    );
    _thumbnailOpacity = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainEntry = widget.mainEntry;
    final pageEntry = widget.pageEntry;
    final multiPageController = widget.multiPageController;
    final isWallpaperMode = context.read<ValueNotifier<AppMode>>().value == AppMode.setWallpaper;

    return AnimatedBuilder(
        animation: Listenable.merge([
          mainEntry.metadataChangeNotifier,
          pageEntry.metadataChangeNotifier,
        ]),
        builder: (context, child) {
          return Selector<MediaQueryData, double>(
            selector: (context, mq) => mq.size.width,
            builder: (context, mqWidth, child) {
              final viewInsetsPadding = (widget.viewInsets ?? EdgeInsets.zero) + (widget.viewPadding ?? EdgeInsets.zero);
              final viewerButtonRow = SafeArea(
                top: false,
                bottom: false,
                minimum: EdgeInsets.only(
                  left: viewInsetsPadding.left,
                  right: viewInsetsPadding.right,
                ),
                child: isWallpaperMode
                    ? WallpaperButtons(
                        entry: pageEntry,
                        scale: _buttonScale,
                      )
                    : ViewerButtons(
                        mainEntry: mainEntry,
                        pageEntry: pageEntry,
                        scale: _buttonScale,
                        canToggleFavourite: widget.hasCollection,
                      ),
              );

              final showMultiPageOverlay = mainEntry.isMultiPage && multiPageController != null;
              final collapsedPageScroller = mainEntry.isMotionPhoto;

              return SizedBox(
                width: mqWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showMultiPageOverlay && !collapsedPageScroller)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FadeTransition(
                          opacity: _thumbnailOpacity,
                          child: MultiPageOverlay(
                            controller: multiPageController,
                            availableWidth: mqWidth,
                            scrollable: true,
                          ),
                        ),
                      ),
                    (showMultiPageOverlay && collapsedPageScroller)
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SafeArea(
                                top: false,
                                bottom: false,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: MultiPageOverlay(
                                    controller: multiPageController,
                                    availableWidth: mqWidth,
                                    scrollable: false,
                                  ),
                                ),
                              ),
                              Expanded(child: viewerButtonRow),
                            ],
                          )
                        : viewerButtonRow,
                    if (settings.showOverlayThumbnailPreview && !isWallpaperMode)
                      FadeTransition(
                        opacity: _thumbnailOpacity,
                        child: ViewerThumbnailPreview(
                          availableWidth: mqWidth,
                          displayedIndex: widget.index,
                          entries: widget.entries,
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        });
  }
}

class ExtraBottomOverlay extends StatelessWidget {
  final EdgeInsets? viewInsets, viewPadding;
  final Widget child;

  const ExtraBottomOverlay({
    super.key,
    this.viewInsets,
    this.viewPadding,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mq = context.select<MediaQueryData, Tuple3<double, EdgeInsets, EdgeInsets>>((mq) => Tuple3(mq.size.width, mq.viewInsets, mq.viewPadding));
    final mqWidth = mq.item1;
    final mqViewInsets = mq.item2;
    final mqViewPadding = mq.item3;

    final viewInsets = this.viewInsets ?? mqViewInsets;
    final viewPadding = this.viewPadding ?? mqViewPadding;
    final safePadding = (viewInsets + viewPadding).copyWith(bottom: 8) + const EdgeInsets.symmetric(horizontal: 8.0);

    return Padding(
      padding: safePadding,
      child: SizedBox(
        width: mqWidth - safePadding.horizontal,
        child: child,
      ),
    );
  }
}
