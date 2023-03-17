import 'dart:async';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/theme/format.dart';
import 'package:aves/theme/icons.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/utils/constants.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoProgressBar extends StatefulWidget {
  final AvesVideoController? controller;
  final Animation<double> scale;

  const VideoProgressBar({
    super.key,
    required this.controller,
    required this.scale,
  });

  @override
  State<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  final GlobalKey _progressBarKey = GlobalKey(debugLabel: 'video-progress-bar');
  bool _playingOnDragStart = false;

  static const double radius = 123;

  AvesVideoController? get controller => widget.controller;

  Stream<int> get positionStream => controller?.positionStream ?? Stream.value(0);

  bool get isPlaying => controller?.isPlaying ?? false;

  @override
  Widget build(BuildContext context) {
    final blurred = settings.enableBlurEffect;
    final brightness = Theme.of(context).brightness;
    final textStyle = TextStyle(
      shadows: brightness == Brightness.dark ? Constants.embossShadows : null,
    );
    return SizeTransition(
      sizeFactor: widget.scale,
      child: BlurredRRect.all(
        enabled: blurred,
        borderRadius: radius,
        child: GestureDetector(
          onTapDown: (details) {
            _seekFromTap(details.globalPosition);
          },
          onHorizontalDragStart: (details) {
            _playingOnDragStart = isPlaying;
            if (_playingOnDragStart) controller!.pause();
          },
          onHorizontalDragUpdate: (details) {
            _seekFromTap(details.globalPosition);
          },
          onHorizontalDragEnd: (details) {
            if (_playingOnDragStart) controller!.play();
          },
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              decoration: BoxDecoration(
                color: Themes.overlayBackgroundColor(brightness: brightness, blurred: blurred),
                border: AvesBorder.border(context),
                borderRadius: const BorderRadius.all(Radius.circular(radius)),
              ),
              child: Column(
                key: _progressBarKey,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      StreamBuilder<int>(
                          stream: positionStream,
                          builder: (context, snapshot) {
                            // do not use stream snapshot because it is obsolete when switching between videos
                            final position = controller?.currentPosition.floor() ?? 0;
                            return Text(
                              formatFriendlyDuration(Duration(milliseconds: position)),
                              style: textStyle,
                            );
                          }),
                      const Spacer(),
                      Text(
                        formatFriendlyDuration(Duration(milliseconds: controller?.duration ?? 0)),
                        style: textStyle,
                      ),
                    ],
                  ),
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    child: Directionality(
                      // force directionality for `LinearProgressIndicator`
                      textDirection: TextDirection.ltr,
                      child: StreamBuilder<int>(
                          stream: positionStream,
                          builder: (context, snapshot) {
                            // do not use stream snapshot because it is obsolete when switching between videos
                            var progress = controller?.progress ?? 0.0;
                            if (!progress.isFinite) progress = 0.0;
                            return LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(.2),
                            );
                          }),
                    ),
                  ),
                  Row(
                    children: [
                      _buildSpeedIndicator(),
                      _buildMuteIndicator(),
                      Text(
                        // fake text below to match the height of the text above and center the whole thing
                        '',
                        style: textStyle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedIndicator() => StreamBuilder<double>(
        stream: controller?.speedStream ?? Stream.value(1.0),
        builder: (context, snapshot) {
          final speed = controller?.speed ?? 1.0;
          return speed != 1
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Text('x$speed'),
                )
              : const SizedBox();
        },
      );

  Widget _buildMuteIndicator() => StreamBuilder<double>(
        stream: controller?.volumeStream ?? Stream.value(1.0),
        builder: (context, snapshot) {
          final isMuted = controller?.isMuted ?? false;
          return isMuted
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8),
                  child: Selector<MediaQueryData, double>(
                    selector: (context, mq) => mq.textScaleFactor,
                    builder: (context, textScaleFactor, child) => Icon(
                      AIcons.mute,
                      size: 16 * textScaleFactor,
                    ),
                  ),
                )
              : const SizedBox();
        },
      );

  void _seekFromTap(Offset globalPosition) async {
    if (controller == null) return;
    final keyContext = _progressBarKey.currentContext!;
    final box = keyContext.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    await controller!.seekToProgress(localPosition.dx / box.size.width);
  }
}
