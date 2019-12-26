import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_app_service.dart';
import 'package:aves/utils/time_utils.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/fullscreen/overlay/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

class VideoControlOverlay extends StatefulWidget {
  final ImageEntry entry;
  final Animation<double> scale;
  final VideoPlayerController controller;
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

  ImageEntry get entry => widget.entry;

  Animation<double> get scale => widget.scale;

  VideoPlayerController get controller => widget.controller;

  VideoPlayerValue get value => widget.controller.value;

  double get progress => value.position != null && value.duration != null ? value.position.inMilliseconds / value.duration.inMilliseconds : 0;

  @override
  void initState() {
    super.initState();
    _playPauseAnimation = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _registerWidget(widget);
    _onValueChange();
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
    widget.controller.addListener(_onValueChange);
  }

  void _unregisterWidget(VideoControlOverlay widget) {
    widget.controller.removeListener(_onValueChange);
  }

  @override
  Widget build(BuildContext context) {
    return Selector<MediaQueryData, Tuple3<double, EdgeInsets, EdgeInsets>>(
      selector: (c, mq) => Tuple3(mq.size.width, mq.viewInsets, mq.viewPadding),
      builder: (c, mq, child) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: value.hasError
                  ? [
                      OverlayButton(
                        scale: scale,
                        child: IconButton(
                          icon: Icon(Icons.open_in_new),
                          onPressed: () => AndroidAppService.open(entry.uri, entry.mimeType),
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
                          tooltip: value.isPlaying ? 'Pause' : 'Play',
                        ),
                      ),
                    ],
            ),
          ),
        );
      },
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
            _seek(details.globalPosition);
          },
          onHorizontalDragStart: (DragStartDetails details) {
            _playingOnDragStart = controller.value.isPlaying;
            if (_playingOnDragStart) controller.pause();
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            _seek(details.globalPosition);
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            if (_playingOnDragStart) controller.play();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16) + const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black26,
              border: Border.all(color: Colors.white30, width: 0.5),
              borderRadius: const BorderRadius.all(
                Radius.circular(progressBarBorderRadius),
              ),
            ),
            child: Column(
              key: _progressBarKey,
              children: [
                Row(
                  children: [
                    Text(formatDuration(value.position ?? Duration.zero)),
                    const Spacer(),
                    Text(formatDuration(value.duration ?? Duration.zero)),
                  ],
                ),
                LinearProgressIndicator(value: progress),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onValueChange() {
    setState(() {});
    updatePlayPauseIcon();
  }

  Future<void> _playPause() async {
    if (value.isPlaying) {
      await controller.pause();
    } else {
      if (!value.initialized) await controller.initialize();
      await controller.play();
    }
    setState(() {});
  }

  void updatePlayPauseIcon() {
    final isPlaying = value.isPlaying;
    final status = _playPauseAnimation.status;
    if (isPlaying && status != AnimationStatus.forward && status != AnimationStatus.completed) {
      _playPauseAnimation.forward();
    } else if (!isPlaying && status != AnimationStatus.reverse && status != AnimationStatus.dismissed) {
      _playPauseAnimation.reverse();
    }
  }

  void _seek(Offset globalPosition) {
    final keyContext = _progressBarKey.currentContext;
    final RenderBox box = keyContext.findRenderObject();
    final localPosition = box.globalToLocal(globalPosition);
    controller.seekTo(value.duration * (localPosition.dx / box.size.width));
  }
}
