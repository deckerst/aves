import 'dart:async';

import 'package:aves/model/entry.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/viewer/overlay/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

class VideoControlOverlay extends StatefulWidget {
  final AvesEntry entry;
  final IjkMediaController controller;
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

  // video info is not refreshed by default, so we use a timer to do so
  Timer _progressTimer;

  AvesEntry get entry => widget.entry;

  Animation<double> get scale => widget.scale;

  IjkMediaController get controller => widget.controller;

  // `videoInfo` is never null (even if `toString` prints `null`)
  // check presence with `hasData` instead
  VideoInfo get videoInfo => controller.videoInfo;

  // we check whether video info is ready instead of checking for `noDatasource` status,
  // as the controller could also be uninitialized with the `pause` status
  // (e.g. when switching between video entries without playing them the first time)
  bool get isInitialized => videoInfo.hasData;

  bool get isPlaying => controller.ijkStatus == IjkStatus.playing;

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
    _subscriptions.add(widget.controller.ijkStatusStream.listen(_onStatusChange));
    _subscriptions.add(widget.controller.textureIdStream.listen(_onTextureIdChange));
    _onStatusChange(widget.controller.ijkStatus);
    _onTextureIdChange(widget.controller.textureId);
  }

  void _unregisterWidget(VideoControlOverlay widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    _stopTimer();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<IjkStatus>(
        stream: controller.ijkStatusStream,
        builder: (context, snapshot) {
          // do not use stream snapshot because it is obsolete when switching between videos
          final status = controller.ijkStatus;
          return TooltipTheme(
            data: TooltipTheme.of(context).copyWith(
              preferBelow: false,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: status == IjkStatus.error
                  ? [
                      OverlayButton(
                        scale: scale,
                        child: IconButton(
                          icon: Icon(AIcons.openOutside),
                          onPressed: () => AndroidAppService.open(entry.uri, entry.mimeTypeAnySubtype),
                          tooltip: 'Open',
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
                          onPressed: _playPause,
                          tooltip: isPlaying ? 'Pause' : 'Play',
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
                    StreamBuilder<VideoInfo>(
                        stream: controller.videoInfoStream,
                        builder: (context, snapshot) {
                          // do not use stream snapshot because it is obsolete when switching between videos
                          final position = videoInfo.currentPosition?.floor() ?? 0;
                          return Text(formatDuration(Duration(seconds: position)));
                        }),
                    Spacer(),
                    Text(entry.durationText),
                  ],
                ),
                StreamBuilder<VideoInfo>(
                    stream: controller.videoInfoStream,
                    builder: (context, snapshot) {
                      // do not use stream snapshot because it is obsolete when switching between videos
                      var progress = videoInfo.progress;
                      if (!progress.isFinite) progress = 0.0;
                      return LinearProgressIndicator(value: progress);
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    if (controller.textureId == null) return;
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(Durations.videoProgressTimerInterval, (_) => controller.refreshVideoInfo());
  }

  void _stopTimer() {
    _progressTimer?.cancel();
  }

  void _onTextureIdChange(int textureId) {
    if (textureId != null) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  void _onStatusChange(IjkStatus status) {
    if (status == IjkStatus.playing && _seekTargetPercent != null) {
      _seekFromTarget();
    }
    _updatePlayPauseIcon();
  }

  Future<void> _playPause() async {
    if (isPlaying) {
      await controller.pause();
    } else if (isInitialized) {
      await controller.play();
    } else {
      await controller.setDataSource(DataSource.photoManagerUrl(entry.uri), autoPlay: true);
    }
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

    if (isInitialized) {
      await _seekFromTarget();
    } else {
      // autoplay when seeking on uninitialized player, otherwise the texture is not updated
      // as a workaround, pausing after a brief duration is possible, but fiddly
      await controller.setDataSource(DataSource.photoManagerUrl(entry.uri), autoPlay: true);
    }
  }

  Future _seekFromTarget() async {
    // `seekToProgress` is not safe as it can be called when the `duration` is not set yet
    // so we make sure the video info is up to date first
    if (videoInfo.duration == null) {
      await controller.refreshVideoInfo();
    } else {
      await controller.seekToProgress(_seekTargetPercent);
      _seekTargetPercent = null;
    }
  }
}
