import 'dart:async';

import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/video/controls.dart';
import 'package:aves/widgets/viewer/overlay/video/progress_bar.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:flutter/material.dart';

class VideoControlOverlay extends StatefulWidget {
  final AvesEntry entry;
  final AvesVideoController? controller;
  final Animation<double> scale;
  final Function(EntryAction value) onActionSelected;
  final VoidCallback onActionMenuOpened;

  const VideoControlOverlay({
    Key? key,
    required this.entry,
    required this.controller,
    required this.scale,
    required this.onActionSelected,
    required this.onActionMenuOpened,
  }) : super(key: key);

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
          const action = EntryAction.open;
          return Align(
            alignment: AlignmentDirectional.centerEnd,
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

        return Row(
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
              onActionSelected: widget.onActionSelected,
            ),
          ],
        );
      },
    );
  }
}
