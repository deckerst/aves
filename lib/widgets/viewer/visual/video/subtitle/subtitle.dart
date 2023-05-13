import 'package:aves/model/entry/entry.dart';
import 'package:aves/model/entry/extensions/props.dart';
import 'package:aves/model/settings/enums/subtitle_position.dart';
import 'package:aves/model/settings/settings.dart';
import 'package:aves/widgets/common/basic/text/background_painter.dart';
import 'package:aves/widgets/common/basic/text/outlined.dart';
import 'package:aves/widgets/viewer/visual/state.dart';
import 'package:aves/widgets/viewer/visual/video/subtitle/ass_parser.dart';
import 'package:aves/widgets/viewer/visual/video/subtitle/span.dart';
import 'package:aves/widgets/viewer/visual/video/subtitle/style.dart';
import 'package:aves_video/aves_video.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:latlong2/latlong.dart' as angles;
import 'package:provider/provider.dart';

class VideoSubtitles extends StatelessWidget {
  final AvesEntry entry;
  final AvesVideoController controller;
  final ValueNotifier<ViewState> viewStateNotifier;
  final bool debugMode;

  static const baseShadowOffset = Offset(1, 1);

  const VideoSubtitles({
    super.key,
    required this.entry,
    required this.controller,
    required this.viewStateNotifier,
    this.debugMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final videoDisplaySize = entry.videoDisplaySize(controller.sarNotifier.value);
    return IgnorePointer(
      child: Consumer<Settings>(
        builder: (context, settings, child) {
          final baseTextAlign = settings.subtitleTextAlignment;
          final baseTextAlignY = settings.subtitleTextPosition.toTextAlignVertical();
          final baseOutlineWidth = settings.subtitleShowOutline ? 1 : 0;
          final baseOutlineColor = Colors.black.withOpacity(settings.subtitleTextColor.opacity);
          final baseShadows = [
            Shadow(
              color: baseOutlineColor,
              offset: baseShadowOffset,
            ),
          ];
          final baseStyle = TextStyle(
            color: settings.subtitleTextColor,
            fontSize: settings.subtitleFontSize,
            shadows: settings.subtitleShowOutline ? baseShadows : null,
          );

          final viewportSize = MediaQuery.sizeOf(context);
          final isPortrait = MediaQuery.orientationOf(context) == Orientation.portrait;
          final bottom = isPortrait ? .5 : .8;
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 100.0),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: OutlinedText(
                          textSpans: [
                            TextSpan(
                              text: text,
                              style: const TextStyle(fontSize: 14),
                            )
                          ],
                          outlineWidth: 1,
                          outlineColor: Colors.black,
                        ),
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
                      final spans = kv.value.map((v) {
                        final span = v.textSpan;
                        final style = span.style;
                        if (position == null || style == null) return span;

                        final letterSpacing = style.letterSpacing;
                        final shadows = style.shadows;
                        return TextSpan(
                          text: span.text,
                          style: style.copyWith(
                            letterSpacing: letterSpacing != null ? letterSpacing * viewScale : null,
                            shadows: shadows
                                ?.map((v) => Shadow(
                                      color: v.color,
                                      offset: v.offset * viewScale,
                                      blurRadius: v.blurRadius * viewScale,
                                    ))
                                .toList(),
                          ),
                        );
                      }).toList();
                      final drawingPaths = extraStyle.drawingPaths;
                      final textHAlign = extraStyle.hAlign ?? (position != null ? TextAlign.center : baseTextAlign);
                      final textVAlign = extraStyle.vAlign ?? (position != null ? TextAlignVertical.bottom : baseTextAlignY);

                      Widget child;
                      if (drawingPaths != null) {
                        child = CustomPaint(
                          painter: SubtitlePathPainter(
                            paths: drawingPaths,
                            scale: viewScale,
                            fillColor: spans.firstOrNull?.style?.color ?? Colors.white,
                            strokeColor: extraStyle.borderColor,
                          ),
                        );
                      } else {
                        final outlineWidth = extraStyle.borderWidth ?? (extraStyle.edgeBlur != null ? 2 : 1);
                        child = OutlinedText(
                          textSpans: spans,
                          outlineWidth: outlineWidth * (position != null ? viewScale : baseOutlineWidth),
                          outlineColor: extraStyle.borderColor ?? baseOutlineColor,
                          outlineBlurSigma: extraStyle.edgeBlur ?? 0,
                          textAlign: textHAlign,
                        );
                      }

                      var transform = Matrix4.identity();

                      if (position != null) {
                        final para = RenderParagraph(
                          TextSpan(children: spans),
                          textDirection: TextDirection.ltr,
                          textScaleFactor: MediaQuery.textScaleFactorOf(context),
                        )..layout(const BoxConstraints());
                        final textWidth = para.getMaxIntrinsicWidth(double.infinity);
                        final textHeight = para.getMaxIntrinsicHeight(double.infinity);

                        late double anchorOffsetX, anchorOffsetY;
                        switch (textHAlign) {
                          case TextAlign.left:
                            anchorOffsetX = 0;
                          case TextAlign.right:
                            anchorOffsetX = -textWidth;
                          case TextAlign.center:
                          default:
                            anchorOffsetX = -textWidth / 2;
                        }
                        switch (textVAlign) {
                          case TextAlignVertical.top:
                            anchorOffsetY = 0;
                          case TextAlignVertical.center:
                            anchorOffsetY = -textHeight / 2;
                          case TextAlignVertical.bottom:
                            anchorOffsetY = -textHeight;
                        }
                        final alignOffset = Offset(anchorOffsetX, anchorOffsetY);
                        final lineOffset = position * viewScale + viewPosition;
                        final translateOffset = viewOffset + lineOffset + alignOffset;
                        transform.translate(translateOffset.dx, translateOffset.dy);
                      }

                      if (extraStyle.rotating) {
                        // for perspective
                        transform.setEntry(3, 2, 0.001);
                        final x = -angles.degToRadian(extraStyle.rotationX ?? 0);
                        final y = -angles.degToRadian(extraStyle.rotationY ?? 0);
                        final z = -angles.degToRadian(extraStyle.rotationZ ?? 0);
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
                        late double alignX;
                        switch (textHAlign) {
                          case TextAlign.left:
                            alignX = -1;
                          case TextAlign.right:
                            alignX = 1;
                          case TextAlign.center:
                          default:
                            alignX = 0;
                        }
                        late double alignY;
                        switch (textVAlign) {
                          case TextAlignVertical.top:
                            alignY = -bottom;
                          case TextAlignVertical.center:
                            alignY = 0;
                          case TextAlignVertical.bottom:
                          default:
                            alignY = bottom;
                        }
                        child = Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Align(
                            alignment: Alignment(alignX, alignY),
                            child: TextBackgroundPainter(
                              spans: spans,
                              style: DefaultTextStyle.of(context).style.merge(spans.first.style!.copyWith(
                                    backgroundColor: settings.subtitleBackgroundColor,
                                  )),
                              textAlign: textHAlign,
                              child: child,
                            ),
                          ),
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
  final Paint? fillPaint, strokePaint;

  SubtitlePathPainter({
    required this.paths,
    required this.scale,
    required Color? fillColor,
    required Color? strokeColor,
  })  : fillPaint = fillColor != null
            ? (Paint()
              ..style = PaintingStyle.fill
              ..color = fillColor)
            : null,
        strokePaint = strokeColor != null
            ? (Paint()
              ..style = PaintingStyle.stroke
              ..color = strokeColor)
            : null;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scale, scale);
    paths.forEach((path) {
      if (fillPaint != null) {
        canvas.drawPath(path, fillPaint!);
      }
      if (strokePaint != null) {
        canvas.drawPath(path, strokePaint!);
      }
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
