import 'package:aves/utils/math_utils.dart';
import 'package:aves/widgets/common/basic/outlined_text.dart';
import 'package:aves/widgets/viewer/video/controller.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves/widgets/viewer/visual/subtitle/ass_parser.dart';
import 'package:aves/widgets/viewer/visual/subtitle/span.dart';
import 'package:aves/widgets/viewer/visual/subtitle/style.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

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
    final videoDisplaySize = controller.entry.videoDisplaySize(controller.sarNotifier.value);
    return IgnorePointer(
      child: Selector<MediaQueryData, Orientation>(
        selector: (c, mq) => mq.orientation,
        builder: (c, orientation, child) {
          final bottom = orientation == Orientation.portrait ? .5 : .8;
          Alignment toVerticalAlignment(SubtitleStyle extraStyle) {
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

          final viewportSize = context.read<MediaQueryData>().size;

          return ValueListenableBuilder<ViewState>(
            valueListenable: viewStateNotifier,
            builder: (context, viewState, child) {
              final viewPosition = viewState.position;
              final viewScale = viewState.scale ?? 1;
              final viewSize = videoDisplaySize * viewScale;
              final viewOffset = Offset(
                (viewportSize.width - viewSize.width) / 2,
                (viewportSize.height - viewSize.height) / 2,
              );

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
                      ),
                    );
                  }

                  final styledLine = AssParser.parse(text, baseStyle, viewScale);
                  final position = styledLine.position;
                  final clip = styledLine.clip;
                  final styledSpans = styledLine.spans;
                  final byExtraStyle = groupBy<StyledSubtitleSpan, SubtitleStyle>(styledSpans, (v) => v.extraStyle);
                  return Stack(
                    children: byExtraStyle.entries.map((kv) {
                      final extraStyle = kv.key;
                      final spans = kv.value.map((v) => v.textSpan).toList();
                      final drawingPaths = extraStyle.drawingPaths;

                      final outlineColor = extraStyle.borderColor ?? Colors.black;
                      var child = drawingPaths != null
                          ? CustomPaint(
                              painter: SubtitlePathPainter(
                                paths: drawingPaths,
                                scale: viewScale,
                                fillColor: spans.firstOrNull?.style?.color ?? Colors.white,
                                strokeColor: outlineColor,
                              ),
                            )
                          : OutlinedText(
                              textSpans: spans,
                              outlineWidth: extraStyle.borderWidth ?? (extraStyle.edgeBlur != null ? 2 : 1),
                              outlineColor: outlineColor,
                              outlineBlurSigma: extraStyle.edgeBlur ?? 0,
                              textAlign: extraStyle.hAlign ?? TextAlign.center,
                            );

                      var transform = Matrix4.identity();

                      if (position != null) {
                        final para = RenderParagraph(
                          TextSpan(children: spans),
                          textDirection: TextDirection.ltr,
                          textScaleFactor: context.read<MediaQueryData>().textScaleFactor,
                        )..layout(const BoxConstraints());
                        final textWidth = para.getMaxIntrinsicWidth(double.infinity);
                        final textHeight = para.getMaxIntrinsicHeight(double.infinity);

                        late double anchorOffsetX, anchorOffsetY;
                        switch (extraStyle.hAlign) {
                          case TextAlign.left:
                            anchorOffsetX = 0;
                            break;
                          case TextAlign.right:
                            anchorOffsetX = -textWidth;
                            break;
                          case TextAlign.center:
                          default:
                            anchorOffsetX = -textWidth / 2;
                            break;
                        }
                        switch (extraStyle.vAlign) {
                          case TextAlignVertical.top:
                            anchorOffsetY = 0;
                            break;
                          case TextAlignVertical.center:
                            anchorOffsetY = -textHeight / 2;
                            break;
                          case TextAlignVertical.bottom:
                          default:
                            anchorOffsetY = -textHeight;
                            break;
                        }
                        final alignOffset = Offset(anchorOffsetX, anchorOffsetY);
                        final lineOffset = position * viewScale + viewPosition;
                        final translateOffset = viewOffset + lineOffset + alignOffset;
                        transform.translate(translateOffset.dx, translateOffset.dy);
                      }

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

                      if (position == null) {
                        child = Align(
                          alignment: toVerticalAlignment(extraStyle),
                          child: child,
                        );
                      }

                      if (clip != null) {
                        final clipOffset = viewOffset + viewPosition;
                        final matrix = Matrix4.identity()
                          ..translate(clipOffset.dx, clipOffset.dy)
                          ..scale(viewScale, viewScale);
                        final transform = matrix.storage;
                        child = ClipPath(
                          clipper: SubtitlePathClipper(
                            paths: clip.map((v) => v.transform(transform)).toList(),
                            scale: viewScale,
                          ),
                          child: child,
                        );
                      }

                      return child;
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

class SubtitlePathPainter extends CustomPainter {
  final List<Path> paths;
  final double scale;
  final Color fillColor, strokeColor;

  const SubtitlePathPainter({
    required this.paths,
    required this.scale,
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fillColor;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = strokeColor;

    canvas.scale(scale, scale);
    paths.forEach((path) {
      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, strokePaint);
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SubtitlePathClipper extends CustomClipper<Path> {
  final List<Path> paths;
  final double scale;

  const SubtitlePathClipper({
    required this.paths,
    required this.scale,
  });

  @override
  Path getClip(Size size) => paths.firstOrNull ?? Path();

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
