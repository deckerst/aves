import 'package:aves/model/settings/settings.dart';
import 'package:aves/view/view.dart';
import 'package:aves/widgets/common/action_controls/togglers/play.dart';
import 'package:aves/widgets/common/identity/buttons/overlay_button.dart';
import 'package:aves/widgets/viewer/overlay/bottom/bottom.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_video/aves_video.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class const VideoControlRow({
  super.key,
  final AvesVideoController? controller,
  final Animation<double> scale = kAlwaysCompleteAnimation,
  final bool canOpenVideoPlayer = true,
  required final Function(EntryAction value) onActionSelected,
}) extends StatelessWidget {
  static const double _edgeButtonPadding = 3;
  static const Radius _radius = Radius.circular(123);

  static double preferredHeight(BuildContext context) => OverlayButton.getSize(context);

  @override
  Widget build(BuildContext context) {
    final actions = context.select<Settings, List<EntryAction>>((v) => v.videoControlActions);
    return Row(
      mainAxisSize: .min,
      textDirection: ViewerBottomOverlay.actionsDirection,
      children: actions.map((action) {
        // null radius yields a circular button
        BorderRadius? borderRadius;
        if (actions.length > 1) {
          // zero radius yields a square button
          borderRadius = BorderRadius.zero;
          if (action == actions.first) {
            borderRadius = const BorderRadius.horizontal(left: _radius);
          } else if (action == actions.last) {
            borderRadius = const BorderRadius.horizontal(right: _radius);
          }
        }
        return _VideoOverlayButton(
          controller: controller,
          scale: scale,
          canOpenVideoPlayer: canOpenVideoPlayer,
          onActionSelected: onActionSelected,
          action: action,
          borderRadius: borderRadius,
        );
      }).toList(),
    );
  }

  static double computeWidth(BuildContext context, List<EntryAction> actions) {
    return actions.length * OverlayButton.getSize(context) + (actions.isEmpty ? 0 : 2 * _edgeButtonPadding);
  }
}

class const _VideoOverlayButton({
  required final AvesVideoController? controller,
  required final Animation<double> scale,
  required final bool canOpenVideoPlayer,
  required final Function(EntryAction value) onActionSelected,
  required final EntryAction action,
  required final BorderRadius? borderRadius,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget child;
    if (action == EntryAction.videoTogglePlay) {
      child = PlayToggler(
        controller: controller,
        onPressed: () => onActionSelected(action),
      );
    } else {
      final enabled = action == EntryAction.openVideoPlayer ? canOpenVideoPlayer : true;
      child = IconButton(
        onPressed: enabled ? () => onActionSelected(action) : null,
        tooltip: action.getText(context),
        icon: action.getIcon(),
      );
    }

    final _borderRadius = borderRadius;
    if (_borderRadius != null) {
      child = Padding(
        padding: EdgeInsets.only(
          left: _borderRadius.topLeft.x > 0 ? VideoControlRow._edgeButtonPadding : 0,
          right: _borderRadius.topRight.x > 0 ? VideoControlRow._edgeButtonPadding : 0,
        ),
        child: child,
      );
    }

    return OverlayButton(
      scale: scale,
      borderRadius: _borderRadius,
      child: child,
    );
  }
}
