import 'dart:async';
import 'dart:ui';

import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/common/image_providers/uri_image_provider.dart';
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
  State<StatefulWidget> createState() => AvesVideoState();
}

class AvesVideoState extends State<AvesVideo> {
  final List<StreamSubscription> _subscriptions = [];

  ImageEntry get entry => widget.entry;

  IjkMediaController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    _registerWidget(widget);
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
    _subscriptions.add(widget.controller.playFinishStream.listen(_onPlayFinish));
  }

  void _unregisterWidget(AvesVideo widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
  }

  bool isPlayable(IjkStatus status) => [IjkStatus.prepared, IjkStatus.playing, IjkStatus.pause, IjkStatus.complete].contains(status);

  @override
  Widget build(BuildContext context) {
    if (controller == null) return const SizedBox();
    return StreamBuilder<IjkStatus>(
        stream: widget.controller.ijkStatusStream,
        builder: (context, snapshot) {
          final status = snapshot.data;
          return isPlayable(status)
              ? IjkPlayer(
                  mediaController: controller,
                  controllerWidgetBuilder: (controller) => const SizedBox.shrink(),
                  statusWidgetBuilder: (context, controller, status) => const SizedBox.shrink(),
                  textureBuilder: (context, controller, info) {
                    var id = controller.textureId;
                    if (id == null) {
                      return AspectRatio(
                        aspectRatio: entry.displayAspectRatio,
                        child: Container(
                          color: Colors.green,
                        ),
                      );
                    }

                    Widget child = Container(
                      color: Colors.blue,
                      child: Texture(
                        textureId: id,
                      ),
                    );

                    if (!controller.autoRotate) {
                      return child;
                    }

                    final degree = entry.catalogMetadata?.videoRotation ?? 0;
                    if (degree != 0) {
                      child = RotatedBox(
                        quarterTurns: degree ~/ 90,
                        child: child,
                      );
                    }

                    child = AspectRatio(
                      aspectRatio: entry.displayAspectRatio,
                      child: child,
                    );

                    return Container(
                      child: child,
                      alignment: Alignment.center,
                      color: Colors.transparent,
                    );
                  },
                )
              : Image(
                  image: UriImage(uri: entry.uri, mimeType: entry.mimeType),
                  width: entry.width.toDouble(),
                  height: entry.height.toDouble(),
                );
        });
  }

  void _onPlayFinish(IjkMediaController controller) => controller.seekTo(0);
}
