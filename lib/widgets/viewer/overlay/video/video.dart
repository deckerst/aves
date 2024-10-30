import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves/widgets/viewer/overlay/video/ab_repeat.dart';
import 'package:aves/widgets/viewer/overlay/video/controls.dart';
import 'package:aves/widgets/viewer/overlay/video/progress_bar.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';

class VideoControlOverlay extends StatefulWidget {
  final AvesEntry entry;
  final AvesVideoController? controller;
  final Animation<double> scale;
  final Function(EntryAction value) onActionSelected;

  const VideoControlOverlay({
    super.key,
    required this.entry,
    required this.controller,
    required this.scale,
    required this.onActionSelected,
  });

  @override
  State<StatefulWidget> createState() => _VideoControlOverlayState();
}

class _VideoControlOverlayState extends State<VideoControlOverlay> with SingleTickerProviderStateMixin {
  AvesEntry get entry => widget.entry;

  Animation<double> get scale => widget.scale;

  AvesVideoController? get controller => widget.controller;

  Stream<VideoStatus> get statusStream => controller?.statusStream ?? Stream.value(VideoStatus.idle);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VideoStatus>(
      stream: statusStream,
      builder: (context, snapshot) {
        // do not use stream snapshot because it is obsolete when switching between videos
        final status = controller?.status ?? VideoStatus.idle;

        if (status == VideoStatus.error) {
          const action = EntryAction.openVideoPlayer;
          return Align(
            alignment: Alignment.centerRight,
            child: OverlayButton(
              scale: scale,
              child: IconButton(
                icon: action.getIcon(),
                onPressed: entry.trashed ? null : () => widget.onActionSelected(action),
                tooltip: action.getText(context),
              ),
            ),
          );
        }

        return Column(
          children: [
            VideoABRepeatOverlay(
              controller: controller,
              scale: scale,
            ),
            const SizedBox(height: 8),
            Row(
              textDirection: ViewerBottomOverlay.actionsDirection,
              children: [
                Expanded(
                  child: VideoProgressBar(
                    controller: controller,
                    scale: scale,
                  ),
                ),
                VideoControlRow(
                  controller: controller,
                  scale: scale,
                  canOpenVideoPlayer: !entry.trashed,
                  onActionSelected: widget.onActionSelected,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
