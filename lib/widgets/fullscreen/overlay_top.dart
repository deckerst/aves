import 'package:aves/model/android_app_service.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/blurred.dart';
import 'package:flutter/material.dart';

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
          color: Colors.black26,
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
