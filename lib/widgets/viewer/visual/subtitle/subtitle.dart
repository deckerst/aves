import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/basic/outlined_text.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves/widgets/viewer/visual/subtitle/ass_parser.dart';
import 'package:aves/widgets/viewer/visual/subtitle/style.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class VideoSubtitles extends StatelessWidget {
  final AvesVideoController controller;
  final ValueNotifier<ViewState> viewStateNotifier;
  final bool debugMode;

  static const baseStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    shadows: [
      Shadow(
        color: Colors.black54,
        offset: Offset(1, 1),
      ),
    ],
  );

  const VideoSubtitles({
    Key? key,
    required this.controller,
    required this.viewStateNotifier,
    this.debugMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Selector<MediaQueryData, Orientation>(
        selector: (c, mq) => mq.orientation,
        builder: (c, orientation, child) {
          final bottom = orientation == Orientation.portrait ? .5 : .8;
          Alignment toVerticalAlignment(SubtitleExtraStyle extraStyle) {
            switch (extraStyle.vAlign) {
              case TextAlignVertical.top:
                return Alignment(0, -bottom);
              case TextAlignVertical.center:
                return Alignment.center;
              case TextAlignVertical.bottom:
              default:
                return Alignment(0, bottom);
            }
          }

          return ValueListenableBuilder<ViewState>(
            valueListenable: viewStateNotifier,
            builder: (context, viewState, child) {
              return StreamBuilder<String?>(
                stream: controller.timedTextStream,
                builder: (context, snapshot) {
                  final text = snapshot.data;
                  if (text == null) return const SizedBox();

                  if (debugMode) {
                    return Center(
                      child: OutlinedText(
                        textSpans: [TextSpan(text: text)],
                        outlineWidth: 1,
                        outlineColor: Colors.black,
                        // textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final styledSpans = AssParser.parseAss(text, baseStyle, viewState.scale ?? 1);
                  final byStyle = groupBy<Tuple2<TextSpan, SubtitleExtraStyle>, SubtitleExtraStyle>(styledSpans, (v) => v.item2);
                  return Stack(
                    children: byStyle.entries.map((kv) {
                      final extraStyle = kv.key;
                      final spans = kv.value.map((v) => v.item1).toList();

                      Widget child = OutlinedText(
                        textSpans: spans,
                        outlineWidth: extraStyle.borderWidth ?? 1,
                        outlineColor: extraStyle.borderColor ?? Colors.black,
                        outlineBlurSigma: extraStyle.edgeBlur ?? 0,
                        textAlign: extraStyle.hAlign ?? TextAlign.center,
                      );

                      var transform = Matrix4.identity();
                      if (extraStyle.rotating) {
                        // for perspective
                        transform.setEntry(3, 2, 0.001);
                        final x = -toRadians(extraStyle.rotationX ?? 0);
                        final y = -toRadians(extraStyle.rotationY ?? 0);
                        final z = -toRadians(extraStyle.rotationZ ?? 0);
                        if (x != 0) transform.rotateX(x);
                        if (y != 0) transform.rotateY(y);
                        if (z != 0) transform.rotateZ(z);
                      }
                      if (extraStyle.scaling) {
                        final x = extraStyle.scaleX ?? 1;
                        final y = extraStyle.scaleY ?? 1;
                        transform.scale(x, y);
                      }
                      if (extraStyle.shearing) {
                        final x = extraStyle.shearX ?? 0;
                        final y = extraStyle.shearY ?? 0;
                        transform.multiply(Matrix4(1, y, 0, 0, x, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1));
                      }
                      if (!transform.isIdentity()) {
                        child = Transform(
                          transform: transform,
                          alignment: Alignment.center,
                          child: child,
                        );
                      }

                      return Align(
                        alignment: toVerticalAlignment(extraStyle),
                        child: child,
                      );
                    }).toList(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
