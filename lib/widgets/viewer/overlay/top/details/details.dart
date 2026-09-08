import 'dart:async';
import 'dart:math';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/styles.dart';
import 'package:aves/widgets/common/extensions/theme.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/overlay/top/details/date.dart';
import 'package:aves/widgets/viewer/overlay/top/details/description.dart';
import 'package:aves/widgets/viewer/overlay/top/details/expander.dart';
import 'package:aves/widgets/viewer/overlay/top/details/location.dart';
import 'package:aves/widgets/viewer/overlay/top/details/position_title.dart';
import 'package:aves/widgets/viewer/overlay/top/details/rating_tags.dart';
import 'package:aves/widgets/viewer/overlay/top/details/shooting.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:aves_model/aves_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const ViewerDetailOverlay({
  super.key,
  required final List<AvesEntry> entries,
  required final int index,
  required final bool hasCollection,
  required final MultiPageController? multiPageController,
  required final ValueNotifier<bool> expandedNotifier,
  required final Size availableSize,
}) extends StatefulWidget {
  @override
  State<ViewerDetailOverlay> createState() => _ViewerDetailOverlayState();
}

class _ViewerDetailOverlayState extends State<ViewerDetailOverlay> {
  final StreamController<OverlayMetadata> _detailStreamController = StreamController.broadcast();
  AvesEntry? _requestEntry;

  @override
  void didUpdateWidget(covariant ViewerDetailOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _unregisterEntry();
    super.dispose();
  }

  void _registerEntry() {
    _requestEntry?.metadataChangeNotifier.addListener(_onMetadataChange);
  }

  void _unregisterEntry() {
    _requestEntry?.metadataChangeNotifier.removeListener(_onMetadataChange);
  }

  @override
  Widget build(BuildContext context) {
    final collectionEntries = widget.entries;
    final collectionSize = collectionEntries.length;
    final mainEntryIndex = widget.index;
    final mainEntry = mainEntryIndex < collectionSize ? collectionEntries[mainEntryIndex] : null;
    final multiPageController = widget.multiPageController;

    Widget _buildContent({AvesEntry? pageEntry}) {
      final contentEntry = pageEntry ?? mainEntry;
      if (contentEntry != _requestEntry) {
        _updateDetailLoader(contentEntry);
      }

      return StreamBuilder<OverlayMetadata>(
        stream: _detailStreamController.stream,
        builder: (context, snapshot) {
          if (_requestEntry == null) return const SizedBox();

          return ViewerDetailOverlayContent(
            pageEntry: _requestEntry!,
            details: snapshot.data ?? const OverlayMetadata(),
            position: widget.hasCollection ? '${mainEntryIndex + 1}/$collectionSize' : null,
            availableWidth: widget.availableSize.width,
            multiPageController: multiPageController,
            expandedNotifier: widget.expandedNotifier,
          );
        },
      );
    }

    return SafeArea(
      top: false,
      bottom: false,
      child: multiPageController != null
          ? PageEntryBuilder(
              multiPageController: multiPageController,
              builder: (pageEntry) => _buildContent(pageEntry: pageEntry),
            )
          : _buildContent(),
    );
  }

  void _onMetadataChange() => _updateDetailLoader(_requestEntry);

  void _updateDetailLoader(AvesEntry? entry) {
    if (entry == null) {
      _detailStreamController.add(const OverlayMetadata());
    } else {
      metadataFetchService
          .getOverlayMetadata(entry, {
            if (settings.showOverlayShootingDetails) ...{
              MetadataSyntheticField.aperture,
              MetadataSyntheticField.exposureTime,
              MetadataSyntheticField.focalLength,
              MetadataSyntheticField.iso,
            },
            if (settings.showOverlayDescription) MetadataSyntheticField.description,
          })
          .then(_detailStreamController.add);
    }
    _unregisterEntry();
    _requestEntry = entry;
    _registerEntry();
  }
}

class const ViewerDetailOverlayContent({
  super.key,
  required final AvesEntry pageEntry,
  required final OverlayMetadata details,
  required final String? position,
  required final double availableWidth,
  required final MultiPageController? multiPageController,
  required final ValueNotifier<bool> expandedNotifier,
}) extends StatelessWidget {
  static const double _interRowPadding = 2.0;
  static const double _subRowMinWidth = 300.0;
  static const padding = EdgeInsets.symmetric(vertical: 4, horizontal: 8);
  static const double iconPadding = 8.0;
  static const double iconSize = 16.0;

  static List<Shadow>? shadows(BuildContext context) => Theme.of(context).isDark ? AStyles.embossShadows : null;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        shadows: shadows(context),
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: _buildRows(context),
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
    final positionTitleIsNotEmpty = position != null || multiPageController != null || pageEntry.bestTitle != null;

    final rows = <Widget>[];
    if (positionTitleIsNotEmpty) {
      rows.add(
        OverlayRowExpander(
          expandedNotifier: expandedNotifier,
          child: positionTitle,
        ),
      );
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

  Widget _buildDescriptionFullRow(BuildContext context, double infoMaxWidth) {
    var description = details.description;
    return _buildFullRowSwitcher(
      context: context,
      visible: description != null,
      builder: (context) => SizedBox(
        // size it so that a long description with multiple short lines
        // expands to the full width and the scroll bar is at the edge
        width: infoMaxWidth,
        child: OverlayRowExpander(
          expandedNotifier: expandedNotifier,
          child: OverlayDescriptionRow(description: description!),
        ),
      ),
    );
  }

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
          axis: Axis.vertical,
          sizeFactor: animation,
          alignment: const Alignment(-1, 1),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
