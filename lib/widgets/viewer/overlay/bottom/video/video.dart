import 'dart:async';

import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/overlay/bottom/bottom.dart';
import 'package:aves/widgets/viewer/overlay/bottom/video/ab_repeat.dart';
import 'package:aves/widgets/viewer/overlay/bottom/video/controls.dart';
import 'package:aves/widgets/viewer/overlay/bottom/video/progress_bar.dart';
import 'package:aves/widgets/viewer/overlay/bottom/video/slow_motion_bar.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const VideoControlOverlay({
  super.key,
  required final AvesEntry entry,
  required final AvesVideoController? controller,
  required final Animation<double> scale,
  required final Function(EntryAction value) onActionSelected,
}) extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _VideoControlOverlayState();

  static double preferredHeight(BuildContext context) => VideoControlRow.preferredHeight(context);
}

class _VideoControlOverlayState extends State<VideoControlOverlay> with SingleTickerProviderStateMixin {
  AvesEntry get entry => widget.entry;

  Animation<double> get scale => widget.scale;

  AvesVideoController? get controller => widget.controller;

  Stream<PlaybackStatus> get statusStream => controller?.statusStream ?? Stream.value(.idle);

  static const double _padding = 8;
  static const double _progressOverControlsWidthThreshold = 160;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlaybackStatus>(
      stream: statusStream,
      builder: (context, _) {
        // do not use stream snapshot because it is obsolete when switching between videos
        final status = controller?.status ?? .idle;

        if (status == .error) {
          const action = EntryAction.openVideoPlayer;
          return Align(
            alignment: .centerRight,
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

        Widget progressBar = VideoProgressBar(
          controller: controller,
          scale: scale,
        );
        if (controller?.isSlowMotion ?? false) {
          progressBar = Column(
            children: [
              SlowMotionBar(
                controller: controller,
                scale: scale,
              ),
              const SizedBox(height: 8),
              progressBar,
            ],
          );
        }
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
                      crossAxisAlignment: .end,
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
                ...progressAndControls,
              ],
            );
          },
        );
      },
    );
  }
}
