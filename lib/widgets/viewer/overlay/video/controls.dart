import 'package:aves/model/actions/entry_actions.dart';
import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/enums/enums.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/action_controls/togglers/play.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoControlRow extends StatelessWidget {
  final AvesEntry entry;
  final AvesVideoController? controller;
  final Animation<double> scale;
  final Function(EntryAction value) onActionSelected;

  static const double padding = 8;
  static const Radius radius = Radius.circular(123);

  const VideoControlRow({
    super.key,
    required this.entry,
    required this.controller,
    required this.scale,
    required this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<Settings, VideoControls>(
      selector: (context, s) => s.videoControls,
      builder: (context, videoControls, child) {
        switch (videoControls) {
          case VideoControls.play:
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: padding),
              child: _buildOverlayButton(
                child: PlayToggler(
                  controller: controller,
                  onPressed: () => onActionSelected(EntryAction.videoTogglePlay),
                ),
              ),
            );
          case VideoControls.playSeek:
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: padding),
                _buildIconButton(
                  context,
                  EntryAction.videoReplay10,
                  borderRadius: const BorderRadius.only(topLeft: radius, bottomLeft: radius),
                ),
                _buildOverlayButton(
                  child: PlayToggler(
                    controller: controller,
                    onPressed: () => onActionSelected(EntryAction.videoTogglePlay),
                  ),
                  borderRadius: const BorderRadius.all(Radius.zero),
                ),
                _buildIconButton(
                  context,
                  EntryAction.videoSkip10,
                  borderRadius: const BorderRadius.only(topRight: radius, bottomRight: radius),
                ),
              ],
            );
          case VideoControls.playOutside:
            return Padding(
              padding: const EdgeInsetsDirectional.only(start: padding),
              child: _buildIconButton(context, EntryAction.openVideo, enabled: !entry.trashed),
            );
          case VideoControls.none:
            return const SizedBox();
        }
      },
    );
  }

  Widget _buildOverlayButton({
    BorderRadius? borderRadius,
    required Widget child,
  }) =>
      OverlayButton(
        scale: scale,
        borderRadius: borderRadius,
        child: child,
      );

  Widget _buildIconButton(
    BuildContext context,
    EntryAction action, {
    bool enabled = true,
    BorderRadius? borderRadius,
  }) =>
      _buildOverlayButton(
        borderRadius: borderRadius,
        child: IconButton(
          icon: action.getIcon(),
          onPressed: enabled ? () => onActionSelected(action) : null,
          tooltip: action.getText(context),
        ),
      );
}
