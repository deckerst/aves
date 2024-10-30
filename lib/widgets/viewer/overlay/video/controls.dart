import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_controls/togglers/play.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/overlay/bottom.dart';
import 'package:aves_model/aves_model.dart';
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
    return Selector<Settings, List<EntryAction>>(
      selector: (context, s) => s.videoControlActions,
      builder: (context, actions, child) {
        if (actions.isEmpty) {
          return const SizedBox();
        }

        if (actions.length == 1) {
          final action = actions.first;
          return Padding(
            padding: const EdgeInsets.only(left: padding),
            child: _buildOverlayButton(context, action, const BorderRadius.all(radius)),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: padding),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: ViewerBottomOverlay.actionsDirection,
            children: actions.map((action) {
              var borderRadius = BorderRadius.zero;
              if (action == actions.first) {
                borderRadius = const BorderRadius.horizontal(left: radius);
              } else if (action == actions.last) {
                borderRadius = const BorderRadius.horizontal(right: radius);
              }
              return _buildOverlayButton(context, action, borderRadius);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildOverlayButton(
    BuildContext context,
    EntryAction action,
    BorderRadius borderRadius,
  ) {
    Widget child;
    if (action == EntryAction.videoTogglePlay) {
      child = PlayToggler(
        controller: controller,
        onPressed: () => onActionSelected(action),
      );
    } else {
      final enabled = action == EntryAction.openVideoPlayer ? !entry.trashed : true;
      child = IconButton(
        icon: action.getIcon(),
        onPressed: enabled ? () => onActionSelected(action) : null,
        tooltip: action.getText(context),
      );
    }

    child = Padding(
      padding: EdgeInsets.only(
        left: borderRadius.topLeft.x > 0 ? padding / 3 : 0,
        right: borderRadius.topRight.x > 0 ? padding / 3 : 0,
      ),
      child: child,
    );

    return OverlayButton(
      scale: scale,
      borderRadius: borderRadius,
      child: child,
    );
  }
}
