import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves/widgets/viewer/overlay/video/ab_repeat.dart';
import 'package:aves/widgets/viewer/overlay/video/controls.dart';
import 'package:aves/widgets/viewer/overlay/video/progress_bar.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  static const double _padding = 8;
  static const double _progressOverControlsWidthThreshold = 160;

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

        final progressBar = VideoProgressBar(
          controller: controller,
          scale: scale,
        );
        final controls = VideoControlRow(
          controller: controller,
          scale: scale,
          canOpenVideoPlayer: !entry.trashed,
          onActionSelected: widget.onActionSelected,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            var progressOverControls = false;
            final actions = context.select<Settings, List<EntryAction>>((v) => v.videoControlActions);
            if (actions.isNotEmpty) {
              final availableWidth = constraints.maxWidth - _padding - VideoControlRow.computeWidth(context, actions);
              progressOverControls = availableWidth < _progressOverControlsWidthThreshold;
            }
            final progressAndControls = progressOverControls
                ? [
                    progressBar,
                    const SizedBox(height: _padding),
                    controls,
                  ]
                : [
                    Row(
                      textDirection: ViewerBottomOverlay.actionsDirection,
                      children: [
                        Expanded(child: progressBar),
                        if (actions.isNotEmpty) const SizedBox(width: _padding),
                        controls,
                      ],
                    ),
                  ];
            return Column(
              crossAxisAlignment: .end,
              textDirection: ViewerBottomOverlay.actionsDirection,
              children: [
                VideoABRepeatOverlay(
                  controller: controller,
                  scale: scale,
                ),
                const SizedBox(height: _padding),
                ...progressAndControls,
              ],
            );
          },
        );
      },
    );
  }
}
