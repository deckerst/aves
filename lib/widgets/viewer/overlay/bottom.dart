import 'dart:math';

import 'package:aves/app_mode.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/multipage.dart';
import 'package:aves/model/selection.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/model/source/collection_lens.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/viewer/controls/intents.dart';
import 'package:aves/widgets/viewer/controls/notifications.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/multipage.dart';
import 'package:aves/widgets/viewer/overlay/selection_button.dart';
import 'package:aves/widgets/viewer/overlay/thumbnail_preview.dart';
import 'package:aves/widgets/viewer/overlay/viewer_buttons.dart';
import 'package:aves/widgets/viewer/overlay/wallpaper_buttons.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ViewerBottomOverlay extends StatelessWidget {
  final List<AvesEntry> entries;
  final int index;
  final CollectionLens? collection;
  final AnimationController animationController;
  final Size availableSize;
  final EdgeInsets? viewInsets, viewPadding;
  final MultiPageController? multiPageController;

  // always keep action buttons in the lower right corner, even with RTL locales
  static const actionsDirection = TextDirection.ltr;

  AvesEntry? get entry {
    return index < entries.length ? entries[index] : null;
  }

  const ViewerBottomOverlay({
    super.key,
    required this.entries,
    required this.index,
    required this.collection,
    required this.animationController,
    required this.availableSize,
    this.viewInsets,
    this.viewPadding,
    required this.multiPageController,
  });

  @override
  Widget build(BuildContext context) {
    final mainEntry = entry;
    if (mainEntry == null) return const SizedBox();

    Widget _buildContent({AvesEntry? pageEntry}) => _BottomOverlayContent(
          entries: entries,
          index: index,
          mainEntry: mainEntry,
          pageEntry: pageEntry ?? mainEntry,
          collection: collection,
          availableSize: availableSize,
          viewInsets: viewInsets,
          viewPadding: viewPadding,
          multiPageController: multiPageController,
          animationController: animationController,
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

  static double actionSafeHeight(BuildContext context) {
    final mqPaddingBottom = context.select<MediaQueryData, double>((mq) => max(mq.effectiveBottomPadding, mq.systemGestureInsets.bottom));
    final buttonHeight = ViewerButtons.preferredHeight(context);
    final thumbnailHeight = (settings.showOverlayThumbnailPreview ? ViewerThumbnailPreview.preferredHeight : 0);
    return mqPaddingBottom + buttonHeight + thumbnailHeight;
  }
}

class _BottomOverlayContent extends StatefulWidget {
  final List<AvesEntry> entries;
  final int index;
  final AvesEntry mainEntry, pageEntry;
  final CollectionLens? collection;
  final Size availableSize;
  final EdgeInsets? viewInsets, viewPadding;
  final MultiPageController? multiPageController;
  final AnimationController animationController;

  const _BottomOverlayContent({
    required this.entries,
    required this.index,
    required this.mainEntry,
    required this.pageEntry,
    required this.collection,
    required this.availableSize,
    required this.viewInsets,
    required this.viewPadding,
    required this.multiPageController,
    required this.animationController,
  });

  @override
  State<_BottomOverlayContent> createState() => _BottomOverlayContentState();
}

class _BottomOverlayContentState extends State<_BottomOverlayContent> {
  final FocusScopeNode _buttonRowFocusScopeNode = FocusScopeNode();
  late CurvedAnimation _buttonScale, _thumbnailOpacity;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestFocus());
  }

  @override
  void didUpdateWidget(covariant _BottomOverlayContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _buttonRowFocusScopeNode.dispose();
    super.dispose();
  }

  void _registerWidget(_BottomOverlayContent widget) {
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

  void _unregisterWidget(_BottomOverlayContent widget) {
    _buttonScale.dispose();
    _thumbnailOpacity.dispose();
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
        final viewInsetsPadding = (widget.viewInsets ?? EdgeInsets.zero) + (widget.viewPadding ?? EdgeInsets.zero);
        final selection = context.read<Selection<AvesEntry>?>();
        final viewerButtonRow = (selection?.isSelecting ?? false)
            ? SelectionButton(
                mainEntry: mainEntry,
                scale: _buttonScale,
              )
            : FocusableActionDetector(
                focusNode: _buttonRowFocusScopeNode,
                shortcuts: settings.useTvLayout
                    ? const {
                        SingleActivator(LogicalKeyboardKey.arrowUp): TvShowLessInfoIntent(),
                      }
                    : null,
                actions: {
                  TvShowLessInfoIntent: CallbackAction<Intent>(onInvoke: (intent) => TvShowLessInfoNotification().dispatch(context)),
                },
                child: SafeArea(
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
                          collection: widget.collection,
                          scale: _buttonScale,
                        ),
                ),
              );

        final showMultiPageOverlay = mainEntry.isMultiPage && multiPageController != null;
        final collapsedPageScroller = mainEntry.isMotionPhoto;

        final availableWidth = widget.availableSize.width;
        return SizedBox(
          width: availableWidth,
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
                      availableWidth: availableWidth,
                      scrollable: true,
                    ),
                  ),
                ),
              (showMultiPageOverlay && collapsedPageScroller)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      textDirection: ViewerBottomOverlay.actionsDirection,
                      children: [
                        SafeArea(
                          top: false,
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: MultiPageOverlay(
                              controller: multiPageController,
                              availableWidth: availableWidth,
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
                    availableWidth: availableWidth,
                    displayedIndex: widget.index,
                    entries: widget.entries,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _requestFocus() => _buttonRowFocusScopeNode.children.firstOrNull?.requestFocus();
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
    final viewInsets = this.viewInsets ?? MediaQuery.viewInsetsOf(context);
    final viewPadding = this.viewPadding ?? MediaQuery.viewPaddingOf(context);
    final safePadding = (viewInsets + viewPadding).copyWith(bottom: 8) + const EdgeInsets.symmetric(horizontal: 8);

    return Padding(
      padding: safePadding,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width - safePadding.horizontal,
        child: child,
      ),
    );
  }
}
