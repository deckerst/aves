import 'dart:math';
import 'dart:ui';

import 'package:aves/model/android_app_service.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/model/metadata_service.dart';
import 'package:aves/widgets/common/blurred.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const kOverlayBackground = Colors.black26;

class FullscreenTopOverlay extends StatelessWidget {
  final List<ImageEntry> entries;
  final int index;
  final Animation<double> scale;
  final EdgeInsets viewInsets, viewPadding;

  ImageEntry get entry => entries[index];

  const FullscreenTopOverlay({
    Key key,
    this.entries,
    this.index,
    this.scale,
    this.viewInsets,
    this.viewPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: (viewInsets ?? EdgeInsets.zero) + (viewPadding ?? EdgeInsets.zero),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          children: [
            OverlayButton(
              scale: scale,
              child: BackButton(),
            ),
            Spacer(),
            OverlayButton(
              scale: scale,
              child: IconButton(
                icon: Icon(Icons.share),
                onPressed: share,
                tooltip: 'Share',
              ),
            ),
          ],
        ),
      ),
    );
  }

  delete() {}

  share() {
    AndroidAppService.share(entry.uri, entry.mimeType);
  }
}

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
  Future<Map> _detailLoader;
  ImageEntry _lastEntry;
  Map _lastDetails;

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
    _detailLoader = MetadataService.getOverlayMetadata(entry.path);
  }

  @override
  Widget build(BuildContext context) {
    final innerPadding = EdgeInsets.all(8.0);
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = widget.viewInsets ?? mediaQuery.viewInsets;
    final viewPadding = widget.viewPadding ?? mediaQuery.viewPadding;
    final overlayContentMaxWidth = mediaQuery.size.width - viewPadding.horizontal - innerPadding.horizontal;
    return BlurredRect(
      child: Container(
        color: kOverlayBackground,
        child: IgnorePointer(
          child: Padding(
            padding: viewInsets + viewPadding.copyWith(top: 0),
            child: Container(
              padding: innerPadding,
              child: FutureBuilder(
                future: _detailLoader,
                builder: (futureContext, AsyncSnapshot<Map> snapshot) {
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
      ),
    );
  }
}

class _FullscreenBottomOverlayContent extends StatelessWidget {
  final ImageEntry entry;
  final Map details;
  final String position;
  final double maxWidth;

  _FullscreenBottomOverlayContent({this.entry, this.details, this.position, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final subRowWidth = min(400.0, maxWidth);
    final date = entry.getBestDate();
    return DefaultTextStyle(
      style: TextStyle(
        shadows: [
          Shadow(
            color: Colors.black87,
            offset: Offset(0.0, 1.0),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: maxWidth,
            child: Text(
              '$position – ${entry.title}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: 4),
          SizedBox(
            width: subRowWidth,
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 16),
                SizedBox(width: 8),
                Expanded(child: Text('${DateFormat.yMMMd().format(date)} – ${DateFormat.Hm().format(date)}')),
                Expanded(child: Text('${entry.width} × ${entry.height}')),
              ],
            ),
          ),
          if (details != null && details.isNotEmpty) ...[
            SizedBox(height: 4),
            SizedBox(
              width: subRowWidth,
              child: Row(
                children: [
                  Icon(Icons.camera, size: 16),
                  SizedBox(width: 8),
                  Expanded(child: Text((details['aperture'] as String).replaceAll('f', 'ƒ'))),
                  Expanded(child: Text(details['exposureTime'])),
                  Expanded(child: Text(details['focalLength'])),
                  Expanded(child: Text(details['iso'])),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class OverlayButton extends StatelessWidget {
  final Animation<double> scale;
  final Widget child;

  const OverlayButton({Key key, this.scale, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: BlurredOval(
        child: Material(
          type: MaterialType.circle,
          color: kOverlayBackground,
          child: Ink(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 0.5),
              shape: BoxShape.circle,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
