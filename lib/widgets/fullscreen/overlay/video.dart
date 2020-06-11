import 'dart:async';

import 'package:aves/model/image_entry.dart';
import 'package:aves/services/android_app_service.dart';
import 'package:aves/utils/durations.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/icons.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class VideoControlOverlay extends StatefulWidget {
  final ImageEntry entry;
  final Animation<double> scale;
  final IjkMediaController controller;
  final EdgeInsets viewInsets, viewPadding;

  const VideoControlOverlay({
    Key key,
    @required this.entry,
    @required this.controller,
    @required this.scale,
    this.viewInsets,
    this.viewPadding,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => VideoControlOverlayState();
}

class VideoControlOverlayState extends State<VideoControlOverlay> with SingleTickerProviderStateMixin {
  final GlobalKey _progressBarKey = GlobalKey();
  bool _playingOnDragStart = false;
  AnimationController _playPauseAnimation;
  final List<StreamSubscription> _subscriptions = [];
  double _seekTargetPercent;

  // video info is not refreshed by default, so we use a timer to do so
  Timer _progressTimer;

  ImageEntry get entry => widget.entry;

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
  void didUpdateWidget(VideoControlOverlay oldWidget) {
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
    final mq = context.select((MediaQueryData mq) => Tuple3(mq.size.width, mq.viewInsets, mq.viewPadding));
    final mqWidth = mq.item1;
    final mqViewInsets = mq.item2;
    final mqViewPadding = mq.item3;

    final viewInsets = widget.viewInsets ?? mqViewInsets;
    final viewPadding = widget.viewPadding ?? mqViewPadding;
    final safePadding = (viewInsets + viewPadding).copyWith(bottom: 8) + const EdgeInsets.symmetric(horizontal: 8.0);

    return Padding(
      padding: safePadding,
      child: SizedBox(
        width: mqWidth - safePadding.horizontal,
        child: StreamBuilder<IjkStatus>(
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
                              icon: const Icon(AIcons.openInNew),
                              onPressed: () => AndroidAppService.open(entry.uri, entry.mimeTypeAnySubtype),
                              tooltip: 'Open',
                            ),
                          ),
                        ]
                      : [
                          Expanded(
                            child: _buildProgressBar(),
                          ),
                          const SizedBox(width: 8),
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
            }),
      ),
    );
  }

  Widget _buildProgressBar() {
    const progressBarBorderRadius = 123.0;
    return SizeTransition(
      sizeFactor: scale,
      child: BlurredRRect(
        borderRadius: progressBarBorderRadius,
        child: GestureDetector(
          onTapDown: (TapDownDetails details) {
            _seekFromTap(details.globalPosition);
          },
          onHorizontalDragStart: (DragStartDetails details) {
            _playingOnDragStart = isPlaying;
            if (_playingOnDragStart) controller.pause();
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            _seekFromTap(details.globalPosition);
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if (_playingOnDragStart) controller.play();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16) + const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: FullscreenOverlay.backgroundColor,
              border: FullscreenOverlay.buildBorder(context),
              borderRadius: const BorderRadius.all(
                Radius.circular(progressBarBorderRadius),
              ),
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
                    const Spacer(),
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
