import 'dart:math';

import 'package:aves/model/entry.dart';
import 'package:aves/model/metadata.dart';
import 'package:aves/model/multipage.dart';
import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/viewer/multipage.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/multipage.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ViewerBottomOverlay extends StatefulWidget {
  final List<AvesEntry> entries;
  final int index;
  final bool showPosition;
  final EdgeInsets viewInsets, viewPadding;
  final MultiPageController multiPageController;

  const ViewerBottomOverlay({
    Key key,
    @required this.entries,
    @required this.index,
    @required this.showPosition,
    this.viewInsets,
    this.viewPadding,
    @required this.multiPageController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewerBottomOverlayState();
}

class _ViewerBottomOverlayState extends State<ViewerBottomOverlay> {
  Future<OverlayMetadata> _detailLoader;
  AvesEntry _lastEntry;
  OverlayMetadata _lastDetails;

  AvesEntry get entry {
    final entries = widget.entries;
    final index = widget.index;
    return index < entries.length ? entries[index] : null;
  }

  MultiPageController get multiPageController => widget.multiPageController;

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
    _detailLoader = MetadataService.getOverlayMetadata(entry);
  }

  @override
  Widget build(BuildContext context) {
    final hasEdgeContent = settings.showOverlayInfo || multiPageController != null;
    return BlurredRect(
      enabled: hasEdgeContent,
      child: Selector<MediaQueryData, Tuple3<double, EdgeInsets, EdgeInsets>>(
        selector: (c, mq) => Tuple3(mq.size.width, mq.viewInsets, mq.viewPadding),
        builder: (c, mq, child) {
          final mqWidth = mq.item1;
          final mqViewInsets = mq.item2;
          final mqViewPadding = mq.item3;

          final viewInsets = widget.viewInsets ?? mqViewInsets;
          final viewPadding = widget.viewPadding ?? mqViewPadding;
          final availableWidth = mqWidth - viewPadding.horizontal;

          return Container(
            color: hasEdgeContent ? kOverlayBackgroundColor : Colors.transparent,
            padding: viewInsets + viewPadding.copyWith(top: 0),
            child: FutureBuilder<OverlayMetadata>(
              future: _detailLoader,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                  _lastDetails = snapshot.data;
                  _lastEntry = entry;
                }
                if (_lastEntry == null) return SizedBox.shrink();

                Widget _buildContent({MultiPageInfo multiPageInfo, int page}) => _BottomOverlayContent(
                      mainEntry: _lastEntry,
                      page: multiPageInfo?.getByIndex(page),
                      details: _lastDetails,
                      position: widget.showPosition ? '${widget.index + 1}/${widget.entries.length}' : null,
                      availableWidth: availableWidth,
                      multiPageController: multiPageController,
                    );

                if (multiPageController == null) return _buildContent();

                return FutureBuilder<MultiPageInfo>(
                  future: multiPageController.info,
                  builder: (context, snapshot) {
                    final multiPageInfo = snapshot.data;
                    return ValueListenableBuilder<int>(
                      valueListenable: multiPageController.pageNotifier,
                      builder: (context, page, child) {
                        return _buildContent(multiPageInfo: multiPageInfo, page: page);
                      },
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

const double _iconPadding = 8.0;
const double _iconSize = 16.0;
const double _interRowPadding = 2.0;
const double _subRowMinWidth = 300.0;

class _BottomOverlayContent extends AnimatedWidget {
  final AvesEntry mainEntry, entry;
  final SinglePageInfo page;
  final OverlayMetadata details;
  final String position;
  final double availableWidth;
  final MultiPageController multiPageController;

  static const infoPadding = EdgeInsets.symmetric(vertical: 4, horizontal: 8);

  _BottomOverlayContent({
    Key key,
    this.mainEntry,
    this.page,
    this.details,
    this.position,
    this.availableWidth,
    this.multiPageController,
  })  : entry = mainEntry.getPageEntry(page),
        super(key: key, listenable: mainEntry.metadataChangeNotifier);

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyText2.copyWith(
        shadows: [Constants.embossShadow],
      ),
      softWrap: false,
      overflow: TextOverflow.fade,
      maxLines: 1,
      child: SizedBox(
        width: availableWidth,
        child: Selector<MediaQueryData, Orientation>(
          selector: (c, mq) => mq.orientation,
          builder: (c, orientation, child) {
            Widget infoColumn;

            if (settings.showOverlayInfo) {
              infoColumn = _buildInfoColumn(orientation);
            }

            if (mainEntry.isMultipage && multiPageController != null) {
              infoColumn = Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MultiPageOverlay(
                    mainEntry: mainEntry,
                    controller: multiPageController,
                    availableWidth: availableWidth,
                  ),
                  if (infoColumn != null) infoColumn,
                ],
              );
            }

            return infoColumn ?? SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildInfoColumn(Orientation orientation) {
    final infoMaxWidth = availableWidth - infoPadding.horizontal;
    final twoColumns = orientation == Orientation.landscape && infoMaxWidth / 2 > _subRowMinWidth;
    final subRowWidth = twoColumns ? min(_subRowMinWidth, infoMaxWidth / 2) : infoMaxWidth;
    final positionTitle = _PositionTitleRow(entry: entry, collectionPosition: position, multiPageController: multiPageController);
    final hasShootingDetails = details != null && !details.isEmpty && settings.showOverlayShootingDetails;

    return Padding(
      padding: infoPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (positionTitle.isNotEmpty) positionTitle,
          _buildSoloLocationRow(),
          if (twoColumns)
            Padding(
              padding: EdgeInsets.only(top: _interRowPadding),
              child: Row(
                children: [
                  Container(
                      width: subRowWidth,
                      child: _DateRow(
                        entry: entry,
                        multiPageController: multiPageController,
                      )),
                  _buildDuoShootingRow(subRowWidth, hasShootingDetails),
                ],
              ),
            )
          else ...[
            Container(
              padding: EdgeInsets.only(top: _interRowPadding),
              width: subRowWidth,
              child: _DateRow(
                entry: entry,
                multiPageController: multiPageController,
              ),
            ),
            _buildSoloShootingRow(subRowWidth, hasShootingDetails),
          ],
        ],
      ),
    );
  }

  Widget _buildSoloLocationRow() => AnimatedSwitcher(
        duration: Durations.viewerOverlayChangeAnimation,
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: _soloTransition,
        child: entry.hasGps
            ? Container(
                padding: EdgeInsets.only(top: _interRowPadding),
                child: _LocationRow(entry: entry),
              )
            : SizedBox.shrink(),
      );

  Widget _buildSoloShootingRow(double subRowWidth, bool hasShootingDetails) => AnimatedSwitcher(
        duration: Durations.viewerOverlayChangeAnimation,
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: _soloTransition,
        child: hasShootingDetails
            ? Container(
                padding: EdgeInsets.only(top: _interRowPadding),
                width: subRowWidth,
                child: _ShootingRow(details),
              )
            : SizedBox.shrink(),
      );

  Widget _buildDuoShootingRow(double subRowWidth, bool hasShootingDetails) => AnimatedSwitcher(
        duration: Durations.viewerOverlayChangeAnimation,
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: hasShootingDetails
            ? Container(
                width: subRowWidth,
                child: _ShootingRow(details),
              )
            : SizedBox.shrink(),
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
    Key key,
    this.entry,
  }) : super(key: key, listenable: entry.addressChangeNotifier);

  @override
  Widget build(BuildContext context) {
    String location;
    if (entry.isLocated) {
      location = entry.shortAddress;
    } else if (entry.hasGps) {
      location = settings.coordinateFormat.format(entry.latLng);
    }
    return Row(
      children: [
        DecoratedIcon(AIcons.location, shadows: [Constants.embossShadow], size: _iconSize),
        SizedBox(width: _iconPadding),
        Expanded(child: Text(location, strutStyle: Constants.overflowStrutStyle)),
      ],
    );
  }
}

class _PositionTitleRow extends StatelessWidget {
  final AvesEntry entry;
  final String collectionPosition;
  final MultiPageController multiPageController;

  const _PositionTitleRow({
    @required this.entry,
    @required this.collectionPosition,
    @required this.multiPageController,
  });

  String get title => entry.bestTitle;

  bool get isNotEmpty => collectionPosition != null || multiPageController != null || title != null;

  static const separator = ' • ';

  @override
  Widget build(BuildContext context) {
    Text toText({String pagePosition}) => Text(
        [
          if (collectionPosition != null) collectionPosition,
          if (pagePosition != null) pagePosition,
          if (title != null) title,
        ].join(separator),
        strutStyle: Constants.overflowStrutStyle);

    if (multiPageController == null) return toText();

    return FutureBuilder<MultiPageInfo>(
      future: multiPageController.info,
      builder: (context, snapshot) {
        final multiPageInfo = snapshot.data;
        String pagePosition;
        if (multiPageInfo != null) {
          // page count may be 0 when we know an entry to have multiple pages
          // but fail to get information about these pages
          final pageCount = multiPageInfo.pageCount;
          if (pageCount > 0) {
            final page = multiPageInfo.getById(entry.pageId) ?? multiPageInfo.defaultPage;
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
  final MultiPageController multiPageController;

  const _DateRow({
    @required this.entry,
    @required this.multiPageController,
  });

  @override
  Widget build(BuildContext context) {
    final date = entry.bestDate;
    final dateText = date != null ? '${DateFormat.yMMMd().format(date)} • ${DateFormat.Hm().format(date)}' : Constants.overlayUnknown;
    final resolutionText = entry.isSvg ? entry.aspectRatioText : entry.resolutionText;

    return Row(
      children: [
        DecoratedIcon(AIcons.date, shadows: [Constants.embossShadow], size: _iconSize),
        SizedBox(width: _iconPadding),
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
    return Row(
      children: [
        DecoratedIcon(AIcons.shooting, shadows: [Constants.embossShadow], size: _iconSize),
        SizedBox(width: _iconPadding),
        Expanded(child: Text(details.aperture ?? Constants.overlayUnknown, strutStyle: Constants.overflowStrutStyle)),
        Expanded(child: Text(details.exposureTime ?? Constants.overlayUnknown, strutStyle: Constants.overflowStrutStyle)),
        Expanded(child: Text(details.focalLength ?? Constants.overlayUnknown, strutStyle: Constants.overflowStrutStyle)),
        Expanded(child: Text(details.iso ?? Constants.overlayUnknown, strutStyle: Constants.overflowStrutStyle)),
      ],
    );
  }
}

class ExtraBottomOverlay extends StatelessWidget {
  final EdgeInsets viewInsets, viewPadding;
  final Widget child;

  const ExtraBottomOverlay({
    Key key,
    this.viewInsets,
    this.viewPadding,
    @required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = context.select<MediaQueryData, Tuple3<double, EdgeInsets, EdgeInsets>>((mq) => Tuple3(mq.size.width, mq.viewInsets, mq.viewPadding));
    final mqWidth = mq.item1;
    final mqViewInsets = mq.item2;
    final mqViewPadding = mq.item3;

    final viewInsets = this.viewInsets ?? mqViewInsets;
    final viewPadding = this.viewPadding ?? mqViewPadding;
    final safePadding = (viewInsets + viewPadding).copyWith(bottom: 8) + EdgeInsets.symmetric(horizontal: 8.0);

    return Padding(
      padding: safePadding,
      child: SizedBox(
        width: mqWidth - safePadding.horizontal,
        child: child,
      ),
    );
  }
}
