import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/details/date.dart';
import 'package:aves/widgets/viewer/overlay/details/location.dart';
import 'package:aves/widgets/viewer/overlay/details/position_title.dart';
import 'package:aves/widgets/viewer/overlay/details/rating_tags.dart';
import 'package:aves/widgets/viewer/overlay/details/shooting.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerDetailOverlay extends StatefulWidget {
  final List<AvesEntry> entries;
  final int index;
  final bool hasCollection;
  final MultiPageController? multiPageController;

  const ViewerDetailOverlay({
    super.key,
    required this.entries,
    required this.index,
    required this.hasCollection,
    required this.multiPageController,
  });

  @override
  State<ViewerDetailOverlay> createState() => _ViewerDetailOverlayState();
}

class _ViewerDetailOverlayState extends State<ViewerDetailOverlay> {
  List<AvesEntry> get entries => widget.entries;

  AvesEntry? get entry {
    final index = widget.index;
    return index < entries.length ? entries[index] : null;
  }

  late Future<OverlayMetadata?> _detailLoader;
  AvesEntry? _lastEntry;
  OverlayMetadata? _lastDetails;

  @override
  void initState() {
    super.initState();
    _initDetailLoader();
  }

  @override
  void didUpdateWidget(covariant ViewerDetailOverlay oldWidget) {
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
    return SafeArea(
      top: false,
      bottom: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;

          return FutureBuilder<OverlayMetadata?>(
            future: _detailLoader,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                _lastDetails = snapshot.data;
                _lastEntry = entry;
              }
              if (_lastEntry == null) return const SizedBox();
              final mainEntry = _lastEntry!;

              final multiPageController = widget.multiPageController;
              Widget _buildContent({AvesEntry? pageEntry}) => ViewerDetailOverlayContent(
                    pageEntry: pageEntry ?? mainEntry,
                    details: _lastDetails,
                    position: widget.hasCollection ? '${widget.index + 1}/${entries.length}' : null,
                    availableWidth: availableWidth,
                    multiPageController: multiPageController,
                  );

              return multiPageController != null
                  ? PageEntryBuilder(
                      multiPageController: multiPageController,
                      builder: (pageEntry) => _buildContent(pageEntry: pageEntry),
                    )
                  : _buildContent();
            },
          );
        },
      ),
    );
  }
}

class ViewerDetailOverlayContent extends StatelessWidget {
  final AvesEntry pageEntry;
  final OverlayMetadata? details;
  final String? position;
  final double availableWidth;
  final MultiPageController? multiPageController;

  static const double _interRowPadding = 2.0;
  static const double _subRowMinWidth = 300.0;
  static const padding = EdgeInsets.symmetric(vertical: 4, horizontal: 8);
  static const double iconPadding = 8.0;
  static const double iconSize = 16.0;

  static List<Shadow>? shadows(BuildContext context) => Theme.of(context).brightness == Brightness.dark ? Constants.embossShadows : null;

  const ViewerDetailOverlayContent({
    super.key,
    required this.pageEntry,
    required this.details,
    required this.position,
    required this.availableWidth,
    required this.multiPageController,
  });

  @override
  Widget build(BuildContext context) {
    final infoMaxWidth = availableWidth - padding.horizontal;
    final showRatingTags = settings.showOverlayRatingTags;
    final showShooting = settings.showOverlayShootingDetails;

    return AnimatedBuilder(
      animation: pageEntry.metadataChangeNotifier,
      builder: (context, child) {
        final positionTitle = OverlayPositionTitleRow(entry: pageEntry, collectionPosition: position, multiPageController: multiPageController);
        return DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                shadows: shadows(context),
              ),
          softWrap: false,
          overflow: TextOverflow.fade,
          maxLines: 1,
          child: Padding(
            padding: padding,
            child: Selector<MediaQueryData, Orientation>(
              selector: (context, mq) => mq.orientation,
              builder: (context, orientation, child) {
                final twoColumns = orientation == Orientation.landscape && infoMaxWidth / 2 > _subRowMinWidth;
                final subRowWidth = twoColumns ? min(_subRowMinWidth, infoMaxWidth / 2) : infoMaxWidth;
                final collapsedShooting = twoColumns && showShooting;
                final collapsedLocation = twoColumns && !showShooting;

                final rows = <Widget>[];
                if (positionTitle.isNotEmpty) {
                  rows.add(positionTitle);
                  rows.add(const SizedBox(height: _interRowPadding));
                }
                if (twoColumns) {
                  rows.add(
                    Row(
                      children: [
                        _buildDateSubRow(subRowWidth),
                        if (collapsedShooting) _buildShootingSubRow(context, subRowWidth),
                        if (collapsedLocation) _buildLocationSubRow(context, subRowWidth),
                      ],
                    ),
                  );
                } else {
                  rows.add(_buildDateSubRow(subRowWidth));
                  if (showShooting) {
                    rows.add(_buildShootingFullRow(context, subRowWidth));
                  }
                }
                if (!collapsedLocation) {
                  rows.add(_buildLocationFullRow(context));
                }
                if (showRatingTags) {
                  rows.add(_buildRatingTagsFullRow(context));
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rows,
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSubRow(double subRowWidth) => SizedBox(
        width: subRowWidth,
        child: OverlayDateRow(
          entry: pageEntry,
          multiPageController: multiPageController,
        ),
      );

  Widget _buildRatingTagsFullRow(BuildContext context) => _buildFullRowSwitcher(
        context: context,
        visible: pageEntry.rating != 0 || pageEntry.tags.isNotEmpty,
        builder: (context) => OverlayRatingTagsRow(entry: pageEntry),
      );

  Widget _buildShootingFullRow(BuildContext context, double subRowWidth) => _buildFullRowSwitcher(
        context: context,
        visible: details != null && details!.isNotEmpty,
        builder: (context) => SizedBox(
          width: subRowWidth,
          child: OverlayShootingRow(details: details!),
        ),
      );

  Widget _buildShootingSubRow(BuildContext context, double subRowWidth) => _buildSubRowSwitcher(
        context: context,
        subRowWidth: subRowWidth,
        visible: details != null && details!.isNotEmpty,
        builder: (context) => OverlayShootingRow(details: details!),
      );

  Widget _buildLocationFullRow(BuildContext context) => _buildFullRowSwitcher(
        context: context,
        visible: pageEntry.hasGps,
        builder: (context) => OverlayLocationRow(entry: pageEntry),
      );

  Widget _buildLocationSubRow(BuildContext context, double subRowWidth) => _buildSubRowSwitcher(
        context: context,
        subRowWidth: subRowWidth,
        visible: pageEntry.hasGps,
        builder: (context) => OverlayLocationRow(entry: pageEntry),
      );

  Widget _buildSubRowSwitcher({
    required BuildContext context,
    required double subRowWidth,
    required bool visible,
    required WidgetBuilder builder,
  }) =>
      AnimatedSwitcher(
        duration: context.select<DurationsData, Duration>((v) => v.viewerOverlayChangeAnimation),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: visible
            ? SizedBox(
                width: subRowWidth,
                child: builder(context),
              )
            : const SizedBox(),
      );

  Widget _buildFullRowSwitcher({
    required BuildContext context,
    required bool visible,
    required WidgetBuilder builder,
  }) =>
      AnimatedSwitcher(
        duration: context.select<DurationsData, Duration>((v) => v.viewerOverlayChangeAnimation),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(
            axisAlignment: 1,
            sizeFactor: animation,
            child: child,
          ),
        ),
        child: visible
            ? Padding(
                padding: const EdgeInsets.only(top: _interRowPadding),
                child: builder(context),
              )
            : const SizedBox(),
      );
}
