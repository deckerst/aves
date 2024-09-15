import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/details/date.dart';
import 'package:aves/widgets/viewer/overlay/details/description.dart';
import 'package:aves/widgets/viewer/overlay/details/expander.dart';
import 'package:aves/widgets/viewer/overlay/details/location.dart';
import 'package:aves/widgets/viewer/overlay/details/position_title.dart';
import 'package:aves/widgets/viewer/overlay/details/rating_tags.dart';
import 'package:aves/widgets/viewer/overlay/details/shooting.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves_model/aves_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewerDetailOverlay extends StatefulWidget {
  final List<AvesEntry> entries;
  final int index;
  final bool hasCollection;
  final MultiPageController? multiPageController;
  final ValueNotifier<bool> expandedNotifier;
  final Size availableSize;

  const ViewerDetailOverlay({
    super.key,
    required this.entries,
    required this.index,
    required this.hasCollection,
    required this.multiPageController,
    required this.expandedNotifier,
    required this.availableSize,
  });

  @override
  State<ViewerDetailOverlay> createState() => _ViewerDetailOverlayState();
}

class _ViewerDetailOverlayState extends State<ViewerDetailOverlay> {
  List<AvesEntry> get entries => widget.entries;

  AvesEntry? get entry => entryForIndex(widget.index);

  AvesEntry? entryForIndex(int index) => index < entries.length ? entries[index] : null;

  late Future<OverlayMetadata> _detailLoader;
  AvesEntry? _lastEntry;
  OverlayMetadata _lastDetails = const OverlayMetadata();

  @override
  void initState() {
    super.initState();
    _initDetailLoader();
  }

  @override
  void didUpdateWidget(covariant ViewerDetailOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newEntry = entryForIndex(widget.index);
    if (newEntry != entryForIndex(oldWidget.index) && newEntry != _lastEntry) {
      _initDetailLoader();
    }
  }

  void _initDetailLoader() {
    final requestEntry = entry;
    if (requestEntry == null) {
      _detailLoader = SynchronousFuture(const OverlayMetadata());
    } else {
      _detailLoader = metadataFetchService.getOverlayMetadata(requestEntry, {
        if (settings.showOverlayShootingDetails) ...{
          MetadataSyntheticField.aperture,
          MetadataSyntheticField.exposureTime,
          MetadataSyntheticField.focalLength,
          MetadataSyntheticField.iso,
        },
        if (settings.showOverlayDescription) MetadataSyntheticField.description,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: FutureBuilder<OverlayMetadata>(
        future: _detailLoader,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
            _lastDetails = snapshot.data!;
            _lastEntry = entry;
          }
          if (_lastEntry == null) return const SizedBox();
          final mainEntry = _lastEntry!;

          final multiPageController = widget.multiPageController;
          Widget _buildContent({AvesEntry? pageEntry}) => ViewerDetailOverlayContent(
                pageEntry: pageEntry ?? mainEntry,
                details: _lastDetails,
                position: widget.hasCollection ? '${widget.index + 1}/${entries.length}' : null,
                availableWidth: widget.availableSize.width,
                multiPageController: multiPageController,
                expandedNotifier: widget.expandedNotifier,
              );

          return multiPageController != null
              ? PageEntryBuilder(
                  multiPageController: multiPageController,
                  builder: (pageEntry) => _buildContent(pageEntry: pageEntry),
                )
              : _buildContent();
        },
      ),
    );
  }
}

class ViewerDetailOverlayContent extends StatelessWidget {
  final AvesEntry pageEntry;
  final OverlayMetadata details;
  final String? position;
  final double availableWidth;
  final MultiPageController? multiPageController;
  final ValueNotifier<bool> expandedNotifier;

  static const double _interRowPadding = 2.0;
  static const double _subRowMinWidth = 300.0;
  static const padding = EdgeInsets.symmetric(vertical: 4, horizontal: 8);
  static const double iconPadding = 8.0;
  static const double iconSize = 16.0;

  static List<Shadow>? shadows(BuildContext context) => Theme.of(context).isDark ? AStyles.embossShadows : null;

  const ViewerDetailOverlayContent({
    super.key,
    required this.pageEntry,
    required this.details,
    required this.position,
    required this.availableWidth,
    required this.multiPageController,
    required this.expandedNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageEntry.metadataChangeNotifier,
      builder: (context, child) => DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              shadows: shadows(context),
            ),
        softWrap: false,
        overflow: TextOverflow.fade,
        maxLines: 1,
        child: Padding(
          padding: padding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildRows(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRows(BuildContext context) {
    final infoMaxWidth = availableWidth - padding.horizontal;
    final showRatingTags = settings.showOverlayRatingTags;
    final showShootingDetails = settings.showOverlayShootingDetails;
    final showDescription = settings.showOverlayDescription;

    final isLandscape = MediaQuery.orientationOf(context) == Orientation.landscape;
    final twoColumns = isLandscape && infoMaxWidth / 2 > _subRowMinWidth;
    final subRowWidth = twoColumns ? min(_subRowMinWidth, infoMaxWidth / 2) : infoMaxWidth;
    final collapsedShooting = twoColumns && showShootingDetails;
    final collapsedLocation = twoColumns && !showShootingDetails;

    final positionTitle = OverlayPositionTitleRow(
      entry: pageEntry,
      collectionPosition: position,
      multiPageController: multiPageController,
    );

    final rows = <Widget>[];
    if (positionTitle.isNotEmpty) {
      rows.add(OverlayRowExpander(
        expandedNotifier: expandedNotifier,
        child: positionTitle,
      ));
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
      if (showShootingDetails) {
        rows.add(_buildShootingFullRow(context, subRowWidth));
      }
    }
    if (!collapsedLocation) {
      rows.add(_buildLocationFullRow(context));
    }
    if (showRatingTags) {
      rows.add(_buildRatingTagsFullRow(context));
    }
    if (showDescription) {
      rows.add(_buildDescriptionFullRow(context, infoMaxWidth));
    }
    return rows;
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
        builder: (context) => OverlayRowExpander(
          expandedNotifier: expandedNotifier,
          child: OverlayRatingTagsRow(entry: pageEntry),
        ),
      );

  Widget _buildDescriptionFullRow(BuildContext context, double infoMaxWidth) => _buildFullRowSwitcher(
        context: context,
        visible: details.description != null,
        builder: (context) => SizedBox(
          // size it so that a long description with multiple short lines
          // expands to the full width and the scroll bar is at the edge
          width: infoMaxWidth,
          child: OverlayRowExpander(
            expandedNotifier: expandedNotifier,
            child: OverlayDescriptionRow(description: details.description!),
          ),
        ),
      );

  Widget _buildShootingFullRow(BuildContext context, double subRowWidth) => _buildFullRowSwitcher(
        context: context,
        visible: details.hasShootingDetails,
        builder: (context) => SizedBox(
          width: subRowWidth,
          child: OverlayShootingRow(details: details),
        ),
      );

  Widget _buildShootingSubRow(BuildContext context, double subRowWidth) => _buildSubRowSwitcher(
        context: context,
        subRowWidth: subRowWidth,
        visible: details.hasShootingDetails,
        builder: (context) => OverlayShootingRow(details: details),
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
  }) {
    final child = visible
        ? SizedBox(
            width: subRowWidth,
            child: builder(context),
          )
        : const SizedBox();
    return AnimatedSwitcher(
      duration: context.select<DurationsData, Duration>((v) => v.viewerOverlayChangeAnimation),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: child,
    );
  }

  Widget _buildFullRowSwitcher({
    required BuildContext context,
    required bool visible,
    required WidgetBuilder builder,
  }) {
    final child = visible
        ? Padding(
            padding: const EdgeInsets.only(top: _interRowPadding),
            child: builder(context),
          )
        : const SizedBox();
    return AnimatedSwitcher(
      duration: context.select<DurationsData, Duration>((v) => v.viewerOverlayChangeAnimation),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          axisAlignment: 1,
          child: child,
        ),
      ),
      child: child,
    );
  }
}
