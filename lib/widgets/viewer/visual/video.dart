import 'dart:async';
import 'dart:ui';

import 'package:aves/image_providers/uri_image_provider.dart';
import 'package:aves/model/image_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ijkplayer/flutter_ijkplayer.dart';

class AvesVideo extends StatefulWidget {
  final ImageEntry entry;
  final IjkMediaController controller;

  const AvesVideo({
    Key key,
    @required this.entry,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AvesVideoState();
}

class _AvesVideoState extends State<AvesVideo> {
  final List<StreamSubscription> _subscriptions = [];

  ImageEntry get entry => widget.entry;

  IjkMediaController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant AvesVideo oldWidget) {
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
    _subscriptions.add(widget.controller.playFinishStream.listen(_onPlayFinish));
  }

  void _unregisterWidget(AvesVideo widget) {
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
                  image: UriImage(
                    uri: entry.uri,
                    mimeType: entry.mimeType,
                    page: entry.page,
                    rotationDegrees: entry.rotationDegrees,
                    isFlipped: entry.isFlipped,
                    expectedContentLength: entry.sizeBytes,
                  ),
                  width: entry.width.toDouble(),
                  height: entry.height.toDouble(),
                );
        });
  }

  void _onPlayFinish(IjkMediaController controller) => controller.seekTo(0);
}
