import 'dart:io';

import 'package:aves/model/image_entry.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AvesVideo extends StatefulWidget {
  final ImageEntry entry;

  const AvesVideo({Key key, this.entry}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AvesVideoState();
}

class AvesVideoState extends State<AvesVideo> {
  VideoPlayerController videoPlayerController;
  ChewieController chewieController;

  ImageEntry get entry => widget.entry;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.file(
      File(entry.path),
    );
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      aspectRatio: entry.aspectRatio,
      autoInitialize: true,
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Chewie(
      controller: chewieController,
    );
  }
}
