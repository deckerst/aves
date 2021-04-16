import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/extensions/build_context.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/common/video/controller.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:aves/widgets/viewer/overlay/notifications.dart';
import 'package:flutter/material.dart';

class VideoControlOverlay extends StatefulWidget {
  final AvesEntry entry;
  final AvesVideoController controller;
  final Animation<double> scale;

  const VideoControlOverlay({
    Key key,
    @required this.entry,
    @required this.controller,
    @required this.scale,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoControlOverlayState();
}

class _VideoControlOverlayState extends State<VideoControlOverlay> with SingleTickerProviderStateMixin {
  final GlobalKey _progressBarKey = GlobalKey(debugLabel: 'video-progress-bar');
  bool _playingOnDragStart = false;
  AnimationController _playPauseAnimation;
  final List<StreamSubscription> _subscriptions = [];
  double _seekTargetPercent;

  AvesEntry get entry => widget.entry;

  Animation<double> get scale => widget.scale;

  AvesVideoController get controller => widget.controller;

  bool get isPlayable => controller.isPlayable;

  bool get isPlaying => controller.isPlaying;

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
  void didUpdateWidget(covariant VideoControlOverlay oldWidget) {
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

  void _registerWidget(VideoControlOverlay widget) {
    _subscriptions.add(widget.controller.statusStream.listen(_onStatusChange));
    _onStatusChange(widget.controller.status);
  }

  void _unregisterWidget(VideoControlOverlay widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VideoStatus>(
        stream: controller.statusStream,
        builder: (context, snapshot) {
          // do not use stream snapshot because it is obsolete when switching between videos
          final status = controller.status;
          return TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: status == VideoStatus.error
                  ? [
                      OverlayButton(
                        scale: scale,
                        child: IconButton(
                          icon: Icon(AIcons.openOutside),
                          onPressed: () => AndroidAppService.open(entry.uri, entry.mimeTypeAnySubtype),
                          tooltip: context.l10n.viewerOpenTooltip,
                        ),
                      ),
                    ]
                  : [
                      Expanded(
                        child: _buildProgressBar(),
                      ),
                      SizedBox(width: 8),
                      OverlayButton(
                        scale: scale,
                        child: IconButton(
                          icon: AnimatedIcon(
                            icon: AnimatedIcons.play_pause,
                            progress: _playPauseAnimation,
                          ),
                          onPressed: _togglePlayPause,
                          tooltip: isPlaying ? context.l10n.viewerPauseTooltip : context.l10n.viewerPlayTooltip,
                        ),
                      ),
                    ],
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
            if (_playingOnDragStart) controller.pause();
          },
          onHorizontalDragUpdate: (details) {
            _seekFromTap(details.globalPosition);
          },
          onHorizontalDragEnd: (details) {
            if (_playingOnDragStart) controller.play();
          },
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16) + EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: kOverlayBackgroundColor,
              border: AvesCircleBorder.build(context),
              borderRadius: BorderRadius.circular(progressBarBorderRadius),
            ),
            child: Column(
              key: _progressBarKey,
              children: [
                Row(
                  children: [
                    StreamBuilder<int>(
                        stream: controller.positionStream,
                        builder: (context, snapshot) {
                          // do not use stream snapshot because it is obsolete when switching between videos
                          final position = controller.currentPosition?.floor() ?? 0;
                          return Text(formatFriendlyDuration(Duration(milliseconds: position)));
                        }),
                    Spacer(),
                    Text(entry.durationText),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: StreamBuilder<int>(
                      stream: controller.positionStream,
                      builder: (context, snapshot) {
                        // do not use stream snapshot because it is obsolete when switching between videos
                        var progress = controller.progress;
                        if (!progress.isFinite) progress = 0.0;
                        return LinearProgressIndicator(value: progress);
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStatusChange(VideoStatus status) {
    if (status == VideoStatus.playing && _seekTargetPercent != null) {
      _seekFromTarget();
    }
    _updatePlayPauseIcon();
  }

  Future<void> _togglePlayPause() async {
    if (isPlaying) {
      await controller.pause();
    } else {
      await _play();
    }
  }

  Future<void> _play() async {
    if (isPlayable) {
      await controller.play();
    } else {
      await controller.setDataSource(entry.uri);
    }

    // hide overlay
    await Future.delayed(Durations.iconAnimation);
    ToggleOverlayNotification().dispatch(context);
  }

  void _updatePlayPauseIcon() {
    final status = _playPauseAnimation.status;
    if (isPlaying && status != AnimationStatus.forward && status != AnimationStatus.completed) {
      _playPauseAnimation.forward();
    } else if (!isPlaying && status != AnimationStatus.reverse && status != AnimationStatus.dismissed) {
      _playPauseAnimation.reverse();
    }
  }

  void _seekFromTap(Offset globalPosition) async {
    final keyContext = _progressBarKey.currentContext;
    final RenderBox box = keyContext.findRenderObject();
    final localPosition = box.globalToLocal(globalPosition);
    _seekTargetPercent = (localPosition.dx / box.size.width);

    if (isPlayable) {
      await _seekFromTarget();
    } else {
      // controller duration is not set yet, so we use the expected duration instead
      final seekTargetMillis = (entry.durationMillis * _seekTargetPercent).toInt();
      await controller.setDataSource(entry.uri, startMillis: seekTargetMillis);
      _seekTargetPercent = null;
    }
  }

  Future _seekFromTarget() async {
    // `seekToProgress` is not safe as it can be called when the `duration` is not set yet
    // so we make sure the video info is up to date first
    if (controller.duration != null) {
      await controller.seekToProgress(_seekTargetPercent);
      _seekTargetPercent = null;
    }
  }
}
