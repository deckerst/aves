import 'dart:math';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:aves/widgets/fullscreen/image_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TiledImageView extends StatefulWidget {
  final ImageEntry entry;
  final Size viewportSize;
  final ValueNotifier<ViewState> viewStateNotifier;
  final Widget baseChild;
  final ImageErrorWidgetBuilder errorBuilder;

  const TiledImageView({
    @required this.entry,
    @required this.viewportSize,
    @required this.viewStateNotifier,
    @required this.baseChild,
    @required this.errorBuilder,
  });

  @override
  _TiledImageViewState createState() => _TiledImageViewState();
}

class _TiledImageViewState extends State<TiledImageView> {
  ImageEntry get entry => widget.entry;

  Size get viewportSize => widget.viewportSize;

  ValueNotifier<ViewState> get viewStateNotifier => widget.viewStateNotifier;

  @override
  Widget build(BuildContext context) {
    if (viewStateNotifier == null) return SizedBox.shrink();

    final uriImage = UriImage(
      uri: entry.uri,
      mimeType: entry.mimeType,
      rotationDegrees: entry.rotationDegrees,
      isFlipped: entry.isFlipped,
      expectedContentLength: entry.sizeBytes,
    );

    return AnimatedBuilder(
        animation: viewStateNotifier,
        builder: (context, child) {
          final displayWidth = entry.displaySize.width;
          final displayHeight = entry.displaySize.height;
          var scale = viewStateNotifier.value.scale;
          if (scale == 0.0) {
            // for initial scale as `PhotoViewComputedScale.contained`
            scale = min(viewportSize.width / displayWidth, viewportSize.height / displayHeight);
          }
          return Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: displayWidth * scale,
                height: displayHeight * scale,
                child: widget.baseChild,
              ),
              Image(
                image: uriImage,
                width: displayWidth * scale,
                height: displayHeight * scale,
                errorBuilder: widget.errorBuilder,
                fit: BoxFit.contain,
              ),
              // TODO TLAD positioned tiles according to scale/sampleSize
            ],
          );
        });
  }
}
