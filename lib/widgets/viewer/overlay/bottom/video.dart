import 'dart:async';

import 'package:aves/model/actions/video_actions.dart';
import 'package:aves/model/entry.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/basic/menu_row.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/dialogs/video_speed_dialog.dart';
import 'package:aves/widgets/dialogs/video_stream_selection_dialog.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/notifications.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class VideoControlOverlay extends StatefulWidget {
  final AvesEntry entry;
  final AvesVideoController? controller;
  final Animation<double> scale;

  const VideoControlOverlay({
    Key? key,
    required this.entry,
    required this.controller,
    required this.scale,
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VideoStatus>(
        stream: statusStream,
        builder: (context, snapshot) {
          // do not use stream snapshot because it is obsolete when switching between videos
          final status = controller?.status ?? VideoStatus.idle;
          List<Widget> children;
          if (status == VideoStatus.error) {
            children = [
              OverlayButton(
                scale: scale,
                child: IconButton(
                  icon: const Icon(AIcons.openOutside),
                  onPressed: () => AndroidAppService.open(entry.uri, entry.mimeTypeAnySubtype),
                  tooltip: context.l10n.viewerOpenTooltip,
                ),
              ),
            ];
          } else {
            final quickActions = settings.videoQuickActions;
            final menuActions = VideoActions.all.where((action) => !quickActions.contains(action)).toList();
            children = [
              Expanded(
                child: _buildProgressBar(),
              ),
              const SizedBox(width: 8),
              _ButtonRow(
                quickActions: quickActions,
                menuActions: menuActions,
                scale: scale,
                controller: controller,
              ),
            ];
          }

          return TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: children,
            ),
          );
        });
  }

  Widget _buildProgressBar() {
    const progressBarBorderRadius = 123.0;
    return SizeTransition(
      sizeFactor: scale,
      child: BlurredRRect(
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
              color: kOverlayBackgroundColor,
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
                          return Text(formatFriendlyDuration(Duration(milliseconds: position)));
                        }),
                    const Spacer(),
                    Text(entry.durationText),
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

  const _ButtonRow({
    Key? key,
    required this.quickActions,
    required this.menuActions,
    required this.scale,
    required this.controller,
  }) : super(key: key);

  static const double padding = 8;

  bool get isPlaying => controller?.isPlaying ?? false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...quickActions.map((action) => _buildOverlayButton(context, action)),
        OverlayButton(
          scale: scale,
          child: PopupMenuButton<VideoAction>(
            itemBuilder: (context) => menuActions.map((action) => _buildPopupMenuItem(context, action)).toList(),
            onSelected: (action) {
              // wait for the popup menu to hide before proceeding with the action
              Future.delayed(Durations.popupMenuAnimation * timeDilation, () => _onActionSelected(context, action));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayButton(BuildContext context, VideoAction action) {
    late Widget child;
    void onPressed() => _onActionSelected(context, action);
    switch (action) {
      case VideoAction.togglePlay:
        child = _PlayToggler(
          controller: controller,
          onPressed: onPressed,
        );
        break;
      case VideoAction.captureFrame:
      case VideoAction.replay10:
      case VideoAction.selectStreams:
      case VideoAction.setSpeed:
        child = IconButton(
          icon: Icon(action.getIcon()),
          onPressed: onPressed,
          tooltip: action.getText(context),
        );
        break;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: padding),
      child: OverlayButton(
        scale: scale,
        child: child,
      ),
    );
  }

  PopupMenuEntry<VideoAction> _buildPopupMenuItem(BuildContext context, VideoAction action) {
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
      case VideoAction.selectStreams:
      case VideoAction.setSpeed:
        child = MenuRow(text: action.getText(context), icon: action.getIcon());
        break;
    }
    return PopupMenuItem(
      value: action,
      child: child,
    );
  }

  void _onActionSelected(BuildContext context, VideoAction action) {
    switch (action) {
      case VideoAction.togglePlay:
        _togglePlayPause(context);
        break;
      case VideoAction.setSpeed:
        _showSpeedDialog(context);
        break;
      case VideoAction.selectStreams:
        _showStreamSelectionDialog(context);
        break;
      case VideoAction.captureFrame:
        controller?.captureFrame();
        break;
      case VideoAction.replay10:
        {
          final _controller = controller;
          if (_controller != null && _controller.isReady) {
            _controller.seekTo(_controller.currentPosition - 10000);
          }
          break;
        }
    }
  }

  Future<void> _showSpeedDialog(BuildContext context) async {
    final _controller = controller;
    if (_controller == null) return;

    final newSpeed = await showDialog<double>(
      context: context,
      builder: (context) => VideoSpeedDialog(
        current: _controller.speed,
        min: _controller.minSpeed,
        max: _controller.maxSpeed,
      ),
    );
    if (newSpeed == null) return;

    _controller.speed = newSpeed;
  }

  Future<void> _showStreamSelectionDialog(BuildContext context) async {
    final _controller = controller;
    if (_controller == null) return;

    final selectedStreams = await showDialog<Map<StreamType, StreamSummary>>(
      context: context,
      builder: (context) => VideoStreamSelectionDialog(
        streams: _controller.streams,
      ),
    );
    if (selectedStreams == null || selectedStreams.isEmpty) return;

    // TODO TLAD [video] get stream list & guess default selected streams, when the controller is not initialized yet
    await Future.forEach<MapEntry<StreamType, StreamSummary>>(
      selectedStreams.entries,
      (kv) => _controller.selectStream(kv.key, kv.value),
    );
  }

  Future<void> _togglePlayPause(BuildContext context) async {
    final _controller = controller;
    if (_controller == null) return;

    if (isPlaying) {
      await _controller.pause();
    } else {
      await _controller.play();
      // hide overlay
      await Future.delayed(Durations.iconAnimation);
      ToggleOverlayNotification().dispatch(context);
    }
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
              icon: AIcons.pause,
            )
          : MenuRow(
              text: context.l10n.videoActionPlay,
              icon: AIcons.play,
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
