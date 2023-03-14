import 'package:aves/model/entry/entry.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';

class VideoView extends StatefulWidget {
  final AvesEntry entry;
  final AvesVideoController controller;

  const VideoView({
    super.key,
    required this.entry,
    required this.controller,
  });

  @override
  State<StatefulWidget> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  AvesEntry get entry => widget.entry;

  AvesVideoController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant VideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(VideoView widget) {
    widget.controller.playCompletedListenable.addListener(_onPlayCompleted);
  }

  void _unregisterWidget(VideoView widget) {
    widget.controller.playCompletedListenable.removeListener(_onPlayCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VideoStatus>(
        stream: controller.statusStream,
        builder: (context, snapshot) {
          return controller.isReady ? controller.buildPlayerWidget(context) : const SizedBox();
        });
  }

  // not called when looping
  void _onPlayCompleted() => controller.seekTo(0);
}
