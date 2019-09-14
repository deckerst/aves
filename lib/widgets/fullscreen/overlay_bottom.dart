import 'dart:math';
import 'dart:ui';

import 'package:aves/model/image_entry.dart';
import 'package:aves/model/image_metadata.dart';
import 'package:aves/model/metadata_service.dart';
import 'package:aves/utils/geo_utils.dart';
import 'package:aves/widgets/common/blurred.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FullscreenBottomOverlay extends StatefulWidget {
  final List<ImageEntry> entries;
  final int index;
  final EdgeInsets viewInsets, viewPadding;

  const FullscreenBottomOverlay({
    Key key,
    this.entries,
    this.index,
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

  ImageEntry get entry => widget.entries[widget.index];

  @override
  void initState() {
    super.initState();
    initDetailLoader();
  }

  @override
  void didUpdateWidget(FullscreenBottomOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    initDetailLoader();
  }

  initDetailLoader() {
    _detailLoader = MetadataService.getOverlayMetadata(entry);
  }

  @override
  Widget build(BuildContext context) {
    final innerPadding = EdgeInsets.all(8.0);
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = widget.viewInsets ?? mediaQuery.viewInsets;
    final viewPadding = widget.viewPadding ?? mediaQuery.viewPadding;
    final overlayContentMaxWidth = mediaQuery.size.width - viewPadding.horizontal - innerPadding.horizontal;
    return IgnorePointer(
      child: BlurredRect(
        child: Container(
          color: Colors.black26,
          padding: viewInsets + viewPadding.copyWith(top: 0),
          child: Padding(
            padding: innerPadding,
            child: FutureBuilder(
              future: _detailLoader,
              builder: (futureContext, AsyncSnapshot<OverlayMetadata> snapshot) {
                if (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                  _lastDetails = snapshot.data;
                  _lastEntry = entry;
                }
                return _lastEntry == null
                    ? SizedBox.shrink()
                    : _FullscreenBottomOverlayContent(
                        entry: _lastEntry,
                        details: _lastDetails,
                        position: '${widget.index + 1}/${widget.entries.length}',
                        maxWidth: overlayContentMaxWidth,
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FullscreenBottomOverlayContent extends StatelessWidget {
  final ImageEntry entry;
  final OverlayMetadata details;
  final String position;
  final double maxWidth;

  static const double interRowPadding = 4.0;
  static const double iconPadding = 8.0;
  static const double iconSize = 16.0;
  static const double subRowMinWidth = 300.0;

  _FullscreenBottomOverlayContent({this.entry, this.details, this.position, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    // use MediaQuery instead of unreliable OrientationBuilder
    final orientation = MediaQuery.of(context).orientation;
    final twoColumns = orientation == Orientation.landscape && maxWidth / 2 > subRowMinWidth;
    final subRowWidth = twoColumns ? min(subRowMinWidth, maxWidth / 2) : maxWidth;
    final hasShootingDetails = details != null && !details.isEmpty;
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.body1.copyWith(
        shadows: [
          Shadow(
            color: Colors.black87,
            offset: Offset(0.5, 1.0),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: maxWidth,
            child: Text('$position – ${entry.title}', overflow: TextOverflow.ellipsis),
          ),
          if (entry.hasGps)
            Container(
              padding: EdgeInsets.only(top: interRowPadding),
              width: subRowWidth,
              child: _buildLocationRow(),
            ),
          if (twoColumns)
            Padding(
              padding: EdgeInsets.only(top: interRowPadding),
              child: Row(
                children: [
                  Container(width: subRowWidth, child: _buildDateRow()),
                  if (hasShootingDetails) Container(width: subRowWidth, child: _buildShootingRow()),
                ],
              ),
            )
          else ...[
            Container(
              padding: EdgeInsets.only(top: interRowPadding),
              width: subRowWidth,
              child: _buildDateRow(),
            ),
            if (hasShootingDetails)
              Container(
                padding: EdgeInsets.only(top: interRowPadding),
                width: subRowWidth,
                child: _buildShootingRow(),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationRow() {
    String text;
    if (entry.isLocated) {
      text = entry.shortAddress;
    } else if (entry.hasGps) {
      text = toDMS(entry.latLng).join(', ');
    }
    return Row(
      children: [
        Icon(Icons.place, size: iconSize),
        SizedBox(width: iconPadding),
        Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildDateRow() {
    final date = entry.bestDate;
    return Row(
      children: [
        Icon(Icons.calendar_today, size: iconSize),
        SizedBox(width: iconPadding),
        Expanded(flex: 3, child: Text('${DateFormat.yMMMd().format(date)} at ${DateFormat.Hm().format(date)}')),
        Expanded(flex: 2, child: Text('${entry.width} × ${entry.height}')),
      ],
    );
  }

  Widget _buildShootingRow() {
    return Row(
      children: [
        Icon(Icons.camera, size: iconSize),
        SizedBox(width: iconPadding),
        Expanded(child: Text(details.aperture)),
        Expanded(child: Text(details.exposureTime)),
        Expanded(child: Text(details.focalLength)),
        Expanded(child: Text(details.iso)),
      ],
    );
  }
}
