import 'package:aves/model/image_entry.dart';
import 'package:aves/utils/android_app_service.dart';
import 'package:aves/utils/date_utils.dart';
import 'package:aves/widgets/common/blurred.dart';
import 'package:aves/widgets/fullscreen/overlay_top.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class VideoControlOverlayState extends State<VideoControlOverlay> {
  final GlobalKey _progressBarKey = GlobalKey();
  bool _playingOnDragStart = false;

  ImageEntry get entry => widget.entry;

  Animation<double> get scale => widget.scale;

  VideoPlayerController get controller => widget.controller;

  VideoPlayerValue get value => widget.controller.value;

  double get progress => value.position != null && value.duration != null ? value.position.inMilliseconds / value.duration.inMilliseconds : 0;

  @override
  void initState() {
    super.initState();
    registerWidget(widget);
    _onValueChange();
  }

  @override
  void didUpdateWidget(VideoControlOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    unregisterWidget(oldWidget);
    registerWidget(widget);
  }

  @override
  void dispose() {
    unregisterWidget(widget);
    super.dispose();
  }

  registerWidget(VideoControlOverlay widget) {
    widget.controller.addListener(_onValueChange);
  }

  unregisterWidget(VideoControlOverlay widget) {
    widget.controller.removeListener(_onValueChange);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final viewInsets = widget.viewInsets ?? mediaQuery.viewInsets;
    final viewPadding = widget.viewPadding ?? mediaQuery.viewPadding;
    final safePadding = (viewInsets + viewPadding).copyWith(bottom: 8) + EdgeInsets.symmetric(horizontal: 8.0);
    return Padding(
      padding: safePadding,
      child: value.hasError
          ? OverlayButton(
              scale: scale,
              child: IconButton(
                icon: Icon(Icons.open_in_new),
                onPressed: () => AndroidAppService.open(entry.uri, entry.mimeType),
                tooltip: 'Open',
              ),
            )
          : SizedBox(
              width: mediaQuery.size.width - safePadding.horizontal,
              child: Row(
                children: [
                  Expanded(
                    child: _buildProgressBar(),
                  ),
                  SizedBox(width: 8),
                  OverlayButton(
                    scale: scale,
                    child: value.isPlaying
                        ? IconButton(
                            icon: Icon(Icons.pause),
                            onPressed: () => _playPause(),
                            tooltip: 'Pause',
                          )
                        : IconButton(
                            icon: Icon(Icons.play_arrow),
                            onPressed: () => _playPause(),
                            tooltip: 'Play',
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  SizeTransition _buildProgressBar() {
    final progressBarBorderRadius = 123.0;
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
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16) + EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.black26,
              border: Border.all(color: Colors.white30, width: 0.5),
              borderRadius: BorderRadius.all(
                Radius.circular(progressBarBorderRadius),
              ),
            ),
            child: Column(
              key: _progressBarKey,
              children: [
                Row(
                  children: [
                    Text(formatDuration(value.position ?? Duration.zero)),
                    Spacer(),
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

  _onValueChange() => setState(() {});

  _playPause() async {
    if (value.isPlaying) {
      controller.pause();
    } else {
      if (!value.initialized) {
        await controller.initialize();
      }
      controller.play();
    }
    setState(() {});
  }

  _seek(Offset globalPosition) {
    final keyContext = _progressBarKey.currentContext;
    final RenderBox box = keyContext.findRenderObject();
    final localPosition = box.globalToLocal(globalPosition);
    controller.seekTo(value.duration * (localPosition.dx / box.size.width));
  }
}
