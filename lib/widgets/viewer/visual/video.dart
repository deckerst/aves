import 'dart:ui';

import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/collection/collection_page.dart';
import 'package:aves/widgets/common/video/controller.dart';
import 'package:flutter/material.dart';

class VideoView extends StatefulWidget {
  final AvesEntry entry;
  final AvesVideoController controller;

  const VideoView({
    Key key,
    @required this.entry,
    @required this.controller,
  }) : super(key: key);

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
    if (controller == null) return SizedBox();
    return StreamBuilder<VideoStatus>(
        stream: controller.statusStream,
        builder: (context, snapshot) {
          return Stack(
            fit: StackFit.expand,
            children: [
              if (controller.isPlayable) controller.buildPlayerWidget(context, entry),
              // fade out image to ease transition with the player as it starts with a black texture
              AnimatedOpacity(
                opacity: controller.isPlayable ? 0 : 1,
                curve: Curves.easeInCirc,
                duration: Durations.viewerVideoPlayerTransition,
                child: Image(
                  image: entry.getBestThumbnail(settings.getTileExtent(CollectionPage.routeName)),
                  fit: BoxFit.fill,
                ),
              ),
            ],
          );
        });
  }

  // not called when looping
  void _onPlayCompleted() => controller.seekTo(0);
}
