import 'dart:async';

import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/basic/popup_menu_button.dart';
import 'package:aves/widgets/viewer/overlay/bottom/video/controls.dart';
import 'package:aves/widgets/viewer/overlay/bottom/video/progress_bar.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

class VideoControlOverlay extends StatefulWidget {
  final AvesEntry entry;
  final AvesVideoController? controller;
  final Animation<double> scale;
  final Function(VideoAction value) onActionSelected;
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

  Stream<int> get positionStream => controller?.positionStream ?? Stream.value(0);

  bool get isPlaying => controller?.isPlaying ?? false;

  static const double outerPadding = 8;
  static const double innerPadding = 8;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VideoStatus>(
        stream: statusStream,
        builder: (context, snapshot) {
          // do not use stream snapshot because it is obsolete when switching between videos
          final status = controller?.status ?? VideoStatus.idle;
          Widget child;
          if (status == VideoStatus.error) {
            const action = VideoAction.playOutside;
            child = Align(
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
          } else {
            child = Selector<MediaQueryData, double>(
              selector: (context, mq) => mq.size.width - mq.padding.horizontal,
              builder: (context, mqWidth, child) {
                final buttonWidth = OverlayButton.getSize(context);
                final availableCount = ((mqWidth - outerPadding * 2) / (buttonWidth + innerPadding)).floor();
                return Selector<Settings, List<VideoAction>>(
                  selector: (context, s) => s.videoQuickActions,
                  builder: (context, videoQuickActions, child) {
                    final quickActions = videoQuickActions.take(availableCount - 1).toList();
                    final menuActions = VideoActions.menu.where((action) => !quickActions.contains(action)).toList();
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _ButtonRow(
                          quickActions: quickActions,
                          menuActions: menuActions,
                          scale: scale,
                          controller: controller,
                          onActionSelected: widget.onActionSelected,
                          onActionMenuOpened: widget.onActionMenuOpened,
                        ),
                        const SizedBox(height: 8),
                        Row(
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
                        ),
                      ],
                    );
                  },
                );
              },
            );
          }

          return TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: child,
          );
        });
  }
}

class _ButtonRow extends StatelessWidget {
  final List<VideoAction> quickActions, menuActions;
  final Animation<double> scale;
  final AvesVideoController? controller;
  final Function(VideoAction value) onActionSelected;
  final VoidCallback onActionMenuOpened;

  const _ButtonRow({
    Key? key,
    required this.quickActions,
    required this.menuActions,
    required this.scale,
    required this.controller,
    required this.onActionSelected,
    required this.onActionMenuOpened,
  }) : super(key: key);

  static const double padding = 8;

  bool get isPlaying => controller?.isPlaying ?? false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...quickActions.map((action) => _buildOverlayButton(context, action)),
        if (menuActions.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: padding),
            child: OverlayButton(
              scale: scale,
              child: MenuIconTheme(
                child: AvesPopupMenuButton<VideoAction>(
                  itemBuilder: (context) => menuActions.map((action) => _buildPopupMenuItem(context, action)).toList(),
                  onSelected: (action) async {
                    // wait for the popup menu to hide before proceeding with the action
                    await Future.delayed(Durations.popupMenuAnimation * timeDilation);
                    onActionSelected(action);
                  },
                  onMenuOpened: onActionMenuOpened,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOverlayButton(BuildContext context, VideoAction action) {
    late Widget child;
    void onPressed() => onActionSelected(action);

    ValueListenableBuilder<bool> _buildFromListenable(ValueListenable<bool>? enabledNotifier) {
      return ValueListenableBuilder<bool>(
        valueListenable: enabledNotifier ?? ValueNotifier(false),
        builder: (context, canDo, child) => IconButton(
          icon: child!,
          onPressed: canDo ? onPressed : null,
          tooltip: action.getText(context),
        ),
        child: action.getIcon(),
      );
    }

    switch (action) {
      case VideoAction.captureFrame:
        child = _buildFromListenable(controller?.canCaptureFrameNotifier);
        break;
      case VideoAction.selectStreams:
        child = _buildFromListenable(controller?.canSelectStreamNotifier);
        break;
      case VideoAction.setSpeed:
        child = _buildFromListenable(controller?.canSetSpeedNotifier);
        break;
      case VideoAction.togglePlay:
        child = PlayToggler(
          controller: controller,
          onPressed: onPressed,
        );
        break;
      case VideoAction.playOutside:
      case VideoAction.replay10:
      case VideoAction.skip10:
      case VideoAction.settings:
        child = IconButton(
          icon: action.getIcon(),
          onPressed: onPressed,
          tooltip: action.getText(context),
        );
        break;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: padding),
      child: OverlayButton(
        scale: scale,
        child: child,
      ),
    );
  }

  PopupMenuEntry<VideoAction> _buildPopupMenuItem(BuildContext context, VideoAction action) {
    late final bool enabled;
    switch (action) {
      case VideoAction.captureFrame:
        enabled = controller?.canCaptureFrameNotifier.value ?? false;
        break;
      case VideoAction.selectStreams:
        enabled = controller?.canSelectStreamNotifier.value ?? false;
        break;
      case VideoAction.setSpeed:
        enabled = controller?.canSetSpeedNotifier.value ?? false;
        break;
      case VideoAction.replay10:
      case VideoAction.skip10:
      case VideoAction.settings:
      case VideoAction.togglePlay:
        enabled = true;
        break;
      case VideoAction.playOutside:
        enabled = !(controller?.entry.trashed ?? true);
        break;
    }

    Widget? child;
    switch (action) {
      case VideoAction.togglePlay:
        child = PlayToggler(
          controller: controller,
          isMenuItem: true,
        );
        break;
      case VideoAction.captureFrame:
      case VideoAction.playOutside:
      case VideoAction.replay10:
      case VideoAction.skip10:
      case VideoAction.selectStreams:
      case VideoAction.setSpeed:
      case VideoAction.settings:
        child = MenuRow(text: action.getText(context), icon: action.getIcon());
        break;
    }

    return PopupMenuItem(
      value: action,
      enabled: enabled,
      child: child,
    );
  }
}
