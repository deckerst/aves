import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata/overlay.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/settings/enums/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/common/services.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/viewer/multipage/controller.dart';
import 'package:aves/widgets/viewer/page_entry_builder.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

const double _iconPadding = 8.0;
const double _iconSize = 16.0;
const double _interRowPadding = 2.0;
const double _subRowMinWidth = 300.0;

class ViewerDetailOverlay extends StatefulWidget {
  final List<AvesEntry> entries;
  final int index;
  final bool hasCollection;
  final MultiPageController? multiPageController;

  const ViewerDetailOverlay({
    Key? key,
    required this.entries,
    required this.index,
    required this.hasCollection,
    required this.multiPageController,
  }) : super(key: key);

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

  static const padding = EdgeInsets.symmetric(vertical: 4, horizontal: 8);

  const ViewerDetailOverlayContent({
    Key? key,
    required this.pageEntry,
    required this.details,
    required this.position,
    required this.availableWidth,
    required this.multiPageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final infoMaxWidth = availableWidth - padding.horizontal;
    final positionTitle = _PositionTitleRow(entry: pageEntry, collectionPosition: position, multiPageController: multiPageController);
    final hasShootingDetails = details != null && !details!.isEmpty && settings.showOverlayShootingDetails;
    final animationDuration = context.select<DurationsData, Duration>((v) => v.viewerOverlayChangeAnimation);

    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2!.copyWith(
            shadows: Constants.embossShadows,
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

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (positionTitle.isNotEmpty) positionTitle,
                if (twoColumns)
                  Padding(
                    padding: const EdgeInsets.only(top: _interRowPadding),
                    child: Row(
                      children: [
                        SizedBox(
                            width: subRowWidth,
                            child: _DateRow(
                              entry: pageEntry,
                              multiPageController: multiPageController,
                            )),
                        _buildDuoShootingRow(subRowWidth, hasShootingDetails, animationDuration),
                      ],
                    ),
                  )
                else ...[
                  Container(
                    padding: const EdgeInsets.only(top: _interRowPadding),
                    width: subRowWidth,
                    child: _DateRow(
                      entry: pageEntry,
                      multiPageController: multiPageController,
                    ),
                  ),
                  _buildSoloShootingRow(subRowWidth, hasShootingDetails, animationDuration),
                ],
                _buildSoloLocationRow(animationDuration),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSoloLocationRow(Duration animationDuration) => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: _soloTransition,
        child: pageEntry.hasGps
            ? Container(
                padding: const EdgeInsets.only(top: _interRowPadding),
                child: _LocationRow(entry: pageEntry),
              )
            : const SizedBox(),
      );

  Widget _buildSoloShootingRow(double subRowWidth, bool hasShootingDetails, Duration animationDuration) => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: _soloTransition,
        child: hasShootingDetails
            ? Container(
                padding: const EdgeInsets.only(top: _interRowPadding),
                width: subRowWidth,
                child: _ShootingRow(details!),
              )
            : const SizedBox(),
      );

  Widget _buildDuoShootingRow(double subRowWidth, bool hasShootingDetails, Duration animationDuration) => AnimatedSwitcher(
        duration: animationDuration,
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: hasShootingDetails
            ? SizedBox(
                width: subRowWidth,
                child: _ShootingRow(details!),
              )
            : const SizedBox(),
      );

  static Widget _soloTransition(Widget child, Animation<double> animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          axisAlignment: 1,
          sizeFactor: animation,
          child: child,
        ),
      );
}

class _LocationRow extends AnimatedWidget {
  final AvesEntry entry;

  _LocationRow({
    Key? key,
    required this.entry,
  }) : super(key: key, listenable: entry.addressChangeNotifier);

  @override
  Widget build(BuildContext context) {
    late final String location;
    if (entry.hasAddress) {
      location = entry.shortAddress;
    } else {
      final latLng = entry.latLng;
      if (latLng != null) {
        location = settings.coordinateFormat.format(context.l10n, latLng);
      } else {
        location = '';
      }
    }
    return Row(
      children: [
        const DecoratedIcon(AIcons.location, shadows: Constants.embossShadows, size: _iconSize),
        const SizedBox(width: _iconPadding),
        Expanded(child: Text(location, strutStyle: Constants.overflowStrutStyle)),
      ],
    );
  }
}

class _PositionTitleRow extends StatelessWidget {
  final AvesEntry entry;
  final String? collectionPosition;
  final MultiPageController? multiPageController;

  const _PositionTitleRow({
    required this.entry,
    required this.collectionPosition,
    required this.multiPageController,
  });

  String? get title => entry.bestTitle;

  bool get isNotEmpty => collectionPosition != null || multiPageController != null || title != null;

  static const separator = ' • ';

  @override
  Widget build(BuildContext context) {
    Text toText({String? pagePosition}) => Text(
        [
          if (collectionPosition != null) collectionPosition,
          if (pagePosition != null) pagePosition,
          if (title != null) '${Constants.fsi}$title${Constants.pdi}',
        ].join(separator),
        strutStyle: Constants.overflowStrutStyle);

    if (multiPageController == null) return toText();

    return StreamBuilder<MultiPageInfo?>(
      stream: multiPageController!.infoStream,
      builder: (context, snapshot) {
        final multiPageInfo = multiPageController!.info;
        String? pagePosition;
        if (multiPageInfo != null) {
          // page count may be 0 when we know an entry to have multiple pages
          // but fail to get information about these pages
          final pageCount = multiPageInfo.pageCount;
          if (pageCount > 0) {
            final page = multiPageInfo.getById(entry.pageId ?? entry.id) ?? multiPageInfo.defaultPage;
            pagePosition = '${(page?.index ?? 0) + 1}/$pageCount';
          }
        }
        return toText(pagePosition: pagePosition);
      },
    );
  }
}

class _DateRow extends StatelessWidget {
  final AvesEntry entry;
  final MultiPageController? multiPageController;

  const _DateRow({
    required this.entry,
    required this.multiPageController,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;
    final use24hour = context.select<MediaQueryData, bool>((v) => v.alwaysUse24HourFormat);

    final date = entry.bestDate;
    final dateText = date != null ? formatDateTime(date, locale, use24hour) : Constants.overlayUnknown;
    final resolutionText = entry.isSvg
        ? entry.aspectRatioText
        : entry.isSized
            ? entry.resolutionText
            : '';

    return Row(
      children: [
        const DecoratedIcon(AIcons.date, shadows: Constants.embossShadows, size: _iconSize),
        const SizedBox(width: _iconPadding),
        Expanded(flex: 3, child: Text(dateText, strutStyle: Constants.overflowStrutStyle)),
        Expanded(flex: 2, child: Text(resolutionText, strutStyle: Constants.overflowStrutStyle)),
      ],
    );
  }
}

class _ShootingRow extends StatelessWidget {
  final OverlayMetadata details;

  const _ShootingRow(this.details);

  @override
  Widget build(BuildContext context) {
    final locale = context.l10n.localeName;

    final aperture = details.aperture;
    final apertureText = aperture != null ? 'ƒ/${NumberFormat('0.0', locale).format(aperture)}' : Constants.overlayUnknown;

    final focalLength = details.focalLength;
    final focalLengthText = focalLength != null ? context.l10n.focalLength(NumberFormat('0.#', locale).format(focalLength)) : Constants.overlayUnknown;

    final iso = details.iso;
    final isoText = iso != null ? 'ISO$iso' : Constants.overlayUnknown;

    return Row(
      children: [
        const DecoratedIcon(AIcons.shooting, shadows: Constants.embossShadows, size: _iconSize),
        const SizedBox(width: _iconPadding),
        Expanded(child: Text(apertureText, strutStyle: Constants.overflowStrutStyle)),
        Expanded(child: Text(details.exposureTime ?? Constants.overlayUnknown, strutStyle: Constants.overflowStrutStyle)),
        Expanded(child: Text(focalLengthText, strutStyle: Constants.overflowStrutStyle)),
        Expanded(child: Text(isoText, strutStyle: Constants.overflowStrutStyle)),
      ],
    );
  }
}
