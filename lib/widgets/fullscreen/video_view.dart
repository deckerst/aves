import 'dart:ui';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AvesVideo extends StatefulWidget {
  final ImageEntry entry;
  final VideoPlayerController controller;

  const AvesVideo({
    Key key,
    @required this.entry,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => AvesVideoState();
}

class AvesVideoState extends State<AvesVideo> {
  ImageEntry get entry => widget.entry;

  VideoPlayerValue get value => widget.controller.value;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
    _onValueChange();
  }

  @override
  void didUpdateWidget(AvesVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(AvesVideo widget) {
    widget.controller.addListener(_onValueChange);
  }

  void _unregisterWidget(AvesVideo widget) {
    widget.controller.removeListener(_onValueChange);
  }

  @override
  Widget build(BuildContext context) {
    if (value == null) return const SizedBox();
    if (value.hasError) {
      return Image(
        image: UriImage(uri: entry.uri, mimeType: entry.mimeType),
        width: entry.width.toDouble(),
        height: entry.height.toDouble(),
      );
    }
    return Center(
      child: AspectRatio(
        aspectRatio: entry.aspectRatio,
        child: VideoPlayer(widget.controller),
      ),
    );
  }

  void _onValueChange() {
    if (!value.isPlaying && value.position == value.duration) _goToStart();
    setState(() {});
  }

  Future<void> _goToStart() async {
    await widget.controller.seekTo(Duration.zero);
    await widget.controller.pause();
  }
}
