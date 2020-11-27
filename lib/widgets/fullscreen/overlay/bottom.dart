import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/metadata_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:decorated_icon/decorated_icon.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class FullscreenBottomOverlay extends StatefulWidget {
  final List<ImageEntry> entries;
  final int index;
  final bool showPosition;
  final EdgeInsets viewInsets, viewPadding;

  const FullscreenBottomOverlay({
    Key key,
    @required this.entries,
    @required this.index,
    @required this.showPosition,
    this.viewInsets,
    this.viewPadding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FullscreenBottomOverlayState();
}

class _FullscreenBottomOverlayState extends State<FullscreenBottomOverlay> {
  Future<OverlayMetadata> _detailLoader;
  ImageEntry _lastEntry;
  OverlayMetadata _lastDetails;

  static const innerPadding = EdgeInsets.symmetric(vertical: 4, horizontal: 8);

  ImageEntry get entry {
    final entries = widget.entries;
    final index = widget.index;
    return index < entries.length ? entries[index] : null;
  }

  @override
  void initState() {
    super.initState();
    _initDetailLoader();
  }

  @override
  void didUpdateWidget(FullscreenBottomOverlay oldWidget) {
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
    return IgnorePointer(
      child: BlurredRect(
        child: Selector<MediaQueryData, Tuple3<double, EdgeInsets, EdgeInsets>>(
          selector: (c, mq) => Tuple3(mq.size.width, mq.viewInsets, mq.viewPadding),
          builder: (c, mq, child) {
            final mqWidth = mq.item1;
            final mqViewInsets = mq.item2;
            final mqViewPadding = mq.item3;

            final viewInsets = widget.viewInsets ?? mqViewInsets;
            final viewPadding = widget.viewPadding ?? mqViewPadding;
            final overlayContentMaxWidth = mqWidth - viewPadding.horizontal - innerPadding.horizontal;

            return Container(
              color: kOverlayBackgroundColor,
              padding: viewInsets + viewPadding.copyWith(top: 0),
              child: FutureBuilder<OverlayMetadata>(
                future: _detailLoader,
                builder: (futureContext, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                    _lastDetails = snapshot.data;
                    _lastEntry = entry;
                  }
                  return _lastEntry == null
                      ? SizedBox.shrink()
                      : Padding(
                          // keep padding inside `FutureBuilder` so that overlay takes no space until data is ready
                          padding: innerPadding,
                          child: _FullscreenBottomOverlayContent(
                            entry: _lastEntry,
                            details: _lastDetails,
                            position: widget.showPosition ? '${widget.index + 1}/${widget.entries.length}' : null,
                            maxWidth: overlayContentMaxWidth,
                          ),
                        );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

const double _iconPadding = 8.0;
const double _iconSize = 16.0;
const double _interRowPadding = 2.0;
const double _subRowMinWidth = 300.0;

class _FullscreenBottomOverlayContent extends AnimatedWidget {
  final ImageEntry entry;
  final OverlayMetadata details;
  final String position;
  final double maxWidth;

  _FullscreenBottomOverlayContent({
    Key key,
    this.entry,
    this.details,
    this.position,
    this.maxWidth,
  }) : super(key: key, listenable: entry.metadataChangeNotifier);

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
        width: maxWidth,
        child: Selector<MediaQueryData, Orientation>(
          selector: (c, mq) => mq.orientation,
          builder: (c, orientation, child) {
            final twoColumns = orientation == Orientation.landscape && maxWidth / 2 > _subRowMinWidth;
            final subRowWidth = twoColumns ? min(_subRowMinWidth, maxWidth / 2) : maxWidth;
            final positionTitle = [
              if (position != null) position,
              if (entry.bestTitle != null) entry.bestTitle,
            ].join(' • ');
            final hasShootingDetails = details != null && !details.isEmpty && settings.showOverlayShootingDetails;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (positionTitle.isNotEmpty) Text(positionTitle, strutStyle: Constants.overflowStrutStyle),
                _buildSoloLocationRow(),
                if (twoColumns)
                  Padding(
                    padding: EdgeInsets.only(top: _interRowPadding),
                    child: Row(
                      children: [
                        Container(width: subRowWidth, child: _DateRow(entry)),
                        _buildDuoShootingRow(subRowWidth, hasShootingDetails),
                      ],
                    ),
                  )
                else ...[
                  Container(
                    padding: EdgeInsets.only(top: _interRowPadding),
                    width: subRowWidth,
                    child: _DateRow(entry),
                  ),
                  _buildSoloShootingRow(subRowWidth, hasShootingDetails),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSoloLocationRow() => AnimatedSwitcher(
        duration: Durations.fullscreenOverlayChangeAnimation,
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
        duration: Durations.fullscreenOverlayChangeAnimation,
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
        duration: Durations.fullscreenOverlayChangeAnimation,
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
  final ImageEntry entry;

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

class _DateRow extends StatelessWidget {
  final ImageEntry entry;

  const _DateRow(this.entry);

  @override
  Widget build(BuildContext context) {
    final date = entry.bestDate;
    final dateText = date != null ? '${DateFormat.yMMMd().format(date)} • ${DateFormat.Hm().format(date)}' : Constants.overlayUnknown;
    return Row(
      children: [
        DecoratedIcon(AIcons.date, shadows: [Constants.embossShadow], size: _iconSize),
        SizedBox(width: _iconPadding),
        Expanded(flex: 3, child: Text(dateText, strutStyle: Constants.overflowStrutStyle)),
        if (!entry.isSvg) Expanded(flex: 2, child: Text(entry.resolutionText, strutStyle: Constants.overflowStrutStyle)),
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
