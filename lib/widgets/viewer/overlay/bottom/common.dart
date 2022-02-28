import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/media_query.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/bottom/details.dart';
import 'package:aves/widgets/viewer/overlay/bottom/multipage.dart';
import 'package:aves/widgets/viewer/overlay/bottom/thumbnail_preview.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerBottomOverlay extends StatefulWidget {
  final List<AvesEntry> entries;
  final int index;
  final bool showPosition;
  final EdgeInsets? viewInsets, viewPadding;
  final MultiPageController? multiPageController;

  const ViewerBottomOverlay({
    Key? key,
    required this.entries,
    required this.index,
    required this.showPosition,
    this.viewInsets,
    this.viewPadding,
    required this.multiPageController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewerBottomOverlayState();
}

class _ViewerBottomOverlayState extends State<ViewerBottomOverlay> {
  late Future<OverlayMetadata?> _detailLoader;
  AvesEntry? _lastEntry;
  OverlayMetadata? _lastDetails;

  List<AvesEntry> get entries => widget.entries;

  AvesEntry? get entry {
    final index = widget.index;
    return index < entries.length ? entries[index] : null;
  }

  MultiPageController? get multiPageController => widget.multiPageController;

  @override
  void initState() {
    super.initState();
    _initDetailLoader();
  }

  @override
  void didUpdateWidget(covariant ViewerBottomOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (entry != _lastEntry) {
      _initDetailLoader();
    }
  }

  void _initDetailLoader() {
    final requestEntry = entry;
    _detailLoader = requestEntry != null ? metadataFetchService.getOverlayMetadata(requestEntry) : SynchronousFuture(null);
  }

  @override
  Widget build(BuildContext context) {
    final showOverlayInfo = settings.showOverlayInfo;
    final hasEdgeContent = showOverlayInfo || multiPageController != null;
    final blurred = settings.enableOverlayBlurEffect;
    return BlurredRect(
      enabled: hasEdgeContent && blurred,
      child: Selector<MediaQueryData, Tuple3<double, EdgeInsets, EdgeInsets>>(
        selector: (context, mq) => Tuple3(mq.size.width, mq.viewInsets, mq.viewPadding),
        builder: (context, mq, child) {
          final mqWidth = mq.item1;
          final mqViewInsets = mq.item2;
          final mqViewPadding = mq.item3;

          final viewInsets = widget.viewInsets ?? mqViewInsets;
          final viewPadding = widget.viewPadding ?? mqViewPadding;
          final availableWidth = mqWidth - viewPadding.horizontal;

          return Selector<MediaQueryData, double>(
            selector: (context, mq) => max(mq.effectiveBottomPadding, showOverlayInfo ? 0 : mq.systemGestureInsets.bottom),
            builder: (context, mqPaddingBottom, child) {
              return Container(
                color: hasEdgeContent ? overlayBackgroundColor(blurred: blurred) : Colors.transparent,
                padding: EdgeInsets.only(
                  left: max(viewInsets.left, viewPadding.left),
                  top: 0,
                  right: max(viewInsets.right, viewPadding.right),
                  bottom: mqPaddingBottom,
                ),
                child: child,
              );
            },
            child: FutureBuilder<OverlayMetadata?>(
              future: _detailLoader,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                  _lastDetails = snapshot.data;
                  _lastEntry = entry;
                }
                if (_lastEntry == null) return const SizedBox();
                final mainEntry = _lastEntry!;

                Widget _buildContent({AvesEntry? pageEntry}) => _BottomOverlayContent(
                      entries: entries,
                      index: widget.index,
                      mainEntry: mainEntry,
                      pageEntry: pageEntry ?? mainEntry,
                      details: _lastDetails,
                      showPosition: widget.showPosition,
                      safeWidth: availableWidth,
                      multiPageController: multiPageController,
                    );

                return multiPageController != null
                    ? PageEntryBuilder(
                        multiPageController: multiPageController!,
                        builder: (pageEntry) => _buildContent(pageEntry: pageEntry),
                      )
                    : _buildContent();
              },
            ),
          );
        },
      ),
    );
  }
}

class _BottomOverlayContent extends AnimatedWidget {
  final List<AvesEntry> entries;
  final int index;
  final AvesEntry mainEntry, pageEntry;
  final OverlayMetadata? details;
  final bool showPosition;
  final double safeWidth;
  final MultiPageController? multiPageController;

  _BottomOverlayContent({
    Key? key,
    required this.entries,
    required this.index,
    required this.mainEntry,
    required this.pageEntry,
    required this.details,
    required this.showPosition,
    required this.safeWidth,
    required this.multiPageController,
  }) : super(
          key: key,
          listenable: Listenable.merge([
            mainEntry.metadataChangeNotifier,
            pageEntry.metadataChangeNotifier,
          ]),
        );

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2!.copyWith(
            shadows: Constants.embossShadows,
          ),
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
      child: SizedBox(
        width: safeWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (mainEntry.isMultiPage && multiPageController != null)
              MultiPageOverlay(
                controller: multiPageController!,
                availableWidth: safeWidth,
              ),
            if (settings.showOverlayInfo)
              ViewerDetailOverlay(
                pageEntry: pageEntry,
                details: details,
                position: showPosition ? '${index + 1}/${entries.length}' : null,
                availableWidth: safeWidth,
                multiPageController: multiPageController,
              ),
            if (settings.showOverlayThumbnailPreview)
              ViewerThumbnailPreview(
                availableWidth: safeWidth,
                displayedIndex: index,
                entries: entries,
              ),
          ],
        ),
      ),
    );
  }
}

class ExtraBottomOverlay extends StatelessWidget {
  final EdgeInsets? viewInsets, viewPadding;
  final Widget child;

  const ExtraBottomOverlay({
    Key? key,
    this.viewInsets,
    this.viewPadding,
    required this.child,
  }) : super(key: key);

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
