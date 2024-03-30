import 'package:aves/theme/icons.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';

class VideoABRepeatOverlay extends StatefulWidget {
  final AvesVideoController? controller;
  final Animation<double> scale;

  const VideoABRepeatOverlay({
    super.key,
    required this.controller,
    required this.scale,
  });

  @override
  State<StatefulWidget> createState() => _VideoABRepeatOverlayState();
}

class _VideoABRepeatOverlayState extends State<VideoABRepeatOverlay> {
  Animation<double> get scale => widget.scale;

  AvesVideoController? get controller => widget.controller;

  ValueNotifier<ABRepeat?> get abRepeatNotifier => controller?.abRepeatNotifier ?? ValueNotifier(null);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ValueListenableBuilder<ABRepeat?>(
      valueListenable: abRepeatNotifier,
      builder: (context, abRepeat, child) {
        if (abRepeat == null) return const SizedBox();

        Widget boundButton;
        if (abRepeat.start == null) {
          boundButton = IconButton(
            icon: Icon(AIcons.setStart),
            onPressed: controller?.setABRepeatStart,
            tooltip: l10n.videoRepeatActionSetStart,
          );
        } else if (abRepeat.end == null) {
          boundButton = IconButton(
            icon: Icon(AIcons.setEnd),
            onPressed: controller?.setABRepeatEnd,
            tooltip: l10n.videoRepeatActionSetEnd,
          );
        } else {
          boundButton = IconButton(
            icon: Icon(AIcons.resetBounds),
            onPressed: controller?.resetABRepeat,
            tooltip: l10n.resetTooltip,
          );
        }
        return Row(
          children: [
            const Spacer(),
            OverlayButton(
              scale: scale,
              child: boundButton,
            ),
            const SizedBox(width: 8),
            OverlayButton(
              scale: scale,
              child: IconButton(
                icon: Icon(AIcons.repeatOff),
                onPressed: () => controller?.toggleABRepeat(),
                tooltip: l10n.stopTooltip,
              ),
            ),
          ],
        );
      },
    );
  }
}
