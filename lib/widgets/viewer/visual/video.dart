import 'dart:async';
import 'dart:ui';

import 'package:aves/model/entry.dart';
import 'package:aves/model/entry_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

class VideoView extends StatefulWidget {
  final AvesEntry entry;
  final IjkMediaController controller;

  const VideoView({
    Key key,
    @required this.entry,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  final List<StreamSubscription> _subscriptions = [];

  AvesEntry get entry => widget.entry;

  IjkMediaController get controller => widget.controller;

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
    _subscriptions.add(widget.controller.playFinishStream.listen(_onPlayFinish));
  }

  void _unregisterWidget(VideoView widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  bool isPlayable(IjkStatus status) => controller != null && [IjkStatus.prepared, IjkStatus.playing, IjkStatus.pause, IjkStatus.complete].contains(status);

  @override
  Widget build(BuildContext context) {
    if (controller == null) return SizedBox();
    return StreamBuilder<IjkStatus>(
        stream: widget.controller.ijkStatusStream,
        builder: (context, snapshot) {
          final status = snapshot.data;
          return isPlayable(status)
              ? IjkPlayer(
                  mediaController: controller,
                  controllerWidgetBuilder: (controller) => SizedBox.shrink(),
                  statusWidgetBuilder: (context, controller, status) => SizedBox.shrink(),
                  textureBuilder: (context, controller, info) {
                    var id = controller.textureId;
                    var child = id != null
                        ? Texture(
                            textureId: id,
                          )
                        : Container(
                            color: Colors.black,
                          );

                    final degree = entry.rotationDegrees ?? 0;
                    if (degree != 0) {
                      child = RotatedBox(
                        quarterTurns: degree ~/ 90,
                        child: child,
                      );
                    }

                    return Center(
                      child: AspectRatio(
                        aspectRatio: entry.displayAspectRatio,
                        child: child,
                      ),
                    );
                  },
                  backgroundColor: Colors.transparent,
                )
              : Image(
                  image: entry.getBestThumbnail(entry.displaySize.longestSide),
                  fit: BoxFit.contain,
                );
        });
  }

  void _onPlayFinish(IjkMediaController controller) => controller.seekTo(0);
}
