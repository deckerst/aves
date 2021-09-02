import 'dart:async';

import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/basic/menu.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
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

  const VideoControlOverlay({
    Key? key,
    required this.entry,
    required this.controller,
    required this.scale,
    required this.onActionSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoControlOverlayState();
}

class _VideoControlOverlayState extends State<VideoControlOverlay> with SingleTickerProviderStateMixin {
  final GlobalKey _progressBarKey = GlobalKey(debugLabel: 'video-progress-bar');
  bool _playingOnDragStart = false;

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
            child = Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OverlayButton(
                scale: scale,
                child: IconButton(
                  icon: const Icon(AIcons.openOutside),
                  onPressed: () => AndroidAppService.open(entry.uri, entry.mimeTypeAnySubtype),
                  tooltip: context.l10n.viewerOpenTooltip,
                ),
              ),
            );
          } else {
            child = Selector<MediaQueryData, double>(
              selector: (c, mq) => mq.size.width - mq.padding.horizontal,
              builder: (c, mqWidth, child) {
                final buttonWidth = OverlayButton.getSize(context);
                final availableCount = ((mqWidth - outerPadding * 2) / (buttonWidth + innerPadding)).floor();
                final quickActions = settings.videoQuickActions.take(availableCount - 1).toList();
                final menuActions = VideoActions.all.where((action) => !quickActions.contains(action)).toList();
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
                    ),
                    const SizedBox(height: 8),
                    _buildProgressBar(),
                  ],
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

  Widget _buildProgressBar() {
    const progressBarBorderRadius = 123.0;
    final blurred = settings.enableOverlayBlurEffect;
    return SizeTransition(
      sizeFactor: scale,
      child: BlurredRRect(
        enabled: blurred,
        borderRadius: progressBarBorderRadius,
        child: GestureDetector(
          onTapDown: (details) {
            _seekFromTap(details.globalPosition);
          },
          onHorizontalDragStart: (details) {
            _playingOnDragStart = isPlaying;
            if (_playingOnDragStart) controller!.pause();
          },
          onHorizontalDragUpdate: (details) {
            _seekFromTap(details.globalPosition);
          },
          onHorizontalDragEnd: (details) {
            if (_playingOnDragStart) controller!.play();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16) + const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: overlayBackgroundColor(blurred: blurred),
              border: AvesBorder.border,
              borderRadius: const BorderRadius.all(Radius.circular(progressBarBorderRadius)),
            ),
            child: Column(
              key: _progressBarKey,
              children: [
                Row(
                  children: [
                    StreamBuilder<int>(
                        stream: positionStream,
                        builder: (context, snapshot) {
                          // do not use stream snapshot because it is obsolete when switching between videos
                          final position = controller?.currentPosition.floor() ?? 0;
                          return Text(
                            formatFriendlyDuration(Duration(milliseconds: position)),
                            style: const TextStyle(shadows: Constants.embossShadows),
                          );
                        }),
                    const Spacer(),
                    Text(
                      entry.durationText,
                      style: const TextStyle(shadows: Constants.embossShadows),
                    ),
                  ],
                ),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  child: StreamBuilder<int>(
                      stream: positionStream,
                      builder: (context, snapshot) {
                        // do not use stream snapshot because it is obsolete when switching between videos
                        var progress = controller?.progress ?? 0.0;
                        if (!progress.isFinite) progress = 0.0;
                        return LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade700,
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _seekFromTap(Offset globalPosition) async {
    if (controller == null) return;
    final keyContext = _progressBarKey.currentContext!;
    final box = keyContext.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    await controller!.seekToProgress(localPosition.dx / box.size.width);
  }
}

class _ButtonRow extends StatelessWidget {
  final List<VideoAction> quickActions, menuActions;
  final Animation<double> scale;
  final AvesVideoController? controller;
  final Function(VideoAction value) onActionSelected;

  const _ButtonRow({
    Key? key,
    required this.quickActions,
    required this.menuActions,
    required this.scale,
    required this.controller,
    required this.onActionSelected,
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
                child: PopupMenuButton<VideoAction>(
                  itemBuilder: (context) => menuActions.map((action) => _buildPopupMenuItem(context, action)).toList(),
                  onSelected: (action) {
                    // wait for the popup menu to hide before proceeding with the action
                    Future.delayed(Durations.popupMenuAnimation * timeDilation, () => onActionSelected(action));
                  },
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
        child = _PlayToggler(
          controller: controller,
          onPressed: onPressed,
        );
        break;
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
    }

    Widget? child;
    switch (action) {
      case VideoAction.togglePlay:
        child = _PlayToggler(
          controller: controller,
          isMenuItem: true,
        );
        break;
      case VideoAction.captureFrame:
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

class _PlayToggler extends StatefulWidget {
  final AvesVideoController? controller;
  final bool isMenuItem;
  final VoidCallback? onPressed;

  const _PlayToggler({
    required this.controller,
    this.isMenuItem = false,
    this.onPressed,
  });

  @override
  _PlayTogglerState createState() => _PlayTogglerState();
}

class _PlayTogglerState extends State<_PlayToggler> with SingleTickerProviderStateMixin {
  final List<StreamSubscription> _subscriptions = [];
  late AnimationController _playPauseAnimation;

  AvesVideoController? get controller => widget.controller;

  bool get isPlaying => controller?.isPlaying ?? false;

  @override
  void initState() {
    super.initState();
    _playPauseAnimation = AnimationController(
      duration: Durations.iconAnimation,
      vsync: this,
    );
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant _PlayToggler oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    _playPauseAnimation.dispose();
    super.dispose();
  }

  void _registerWidget(_PlayToggler widget) {
    final controller = widget.controller;
    if (controller != null) {
      _subscriptions.add(controller.statusStream.listen(_onStatusChange));
      _onStatusChange(controller.status);
    }
  }

  void _unregisterWidget(_PlayToggler widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isMenuItem) {
      return isPlaying
          ? MenuRow(
              text: context.l10n.videoActionPause,
              icon: const Icon(AIcons.pause),
            )
          : MenuRow(
              text: context.l10n.videoActionPlay,
              icon: const Icon(AIcons.play),
            );
    }
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.play_pause,
        progress: _playPauseAnimation,
      ),
      onPressed: widget.onPressed,
      tooltip: isPlaying ? context.l10n.videoActionPause : context.l10n.videoActionPlay,
    );
  }

  void _onStatusChange(VideoStatus status) {
    final status = _playPauseAnimation.status;
    if (isPlaying && status != AnimationStatus.forward && status != AnimationStatus.completed) {
      _playPauseAnimation.forward();
    } else if (!isPlaying && status != AnimationStatus.reverse && status != AnimationStatus.dismissed) {
      _playPauseAnimation.reverse();
    }
  }
}
