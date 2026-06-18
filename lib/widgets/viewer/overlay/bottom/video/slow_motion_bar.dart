import 'dart:math';

import 'package:aves/model/settings/settings.dart';
import 'package:aves/ref/locales.dart';
import 'package:aves/theme/themes.dart';
import 'package:aves/widgets/common/fx/blurred.dart';
import 'package:aves/widgets/common/fx/borders.dart';
import 'package:aves/widgets/viewer/overlay/bottom/video/progress_bar.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:aves_video/aves_video.dart';
import 'package:flutter/material.dart';

class SlowMotionBar extends StatefulWidget {
  final AvesVideoController? controller;
  final Animation<double> scale;

  const SlowMotionBar({
    super.key,
    required this.controller,
    required this.scale,
  });

  @override
  State<SlowMotionBar> createState() => _SlowMotionBarState();
}

class _SlowMotionBarState extends State<SlowMotionBar> {
  final GlobalKey _slowMotionBarKey = GlobalKey(debugLabel: 'slow-motion-bar');

  static const double _radius = 123;

  AvesVideoController? get controller => widget.controller;

  bool get isSlowMotion => controller?.isSlowMotion ?? false;

  ValueNotifier<SlowMotionRange>? get slowMotionRangeNotifier => controller?.slowMotionRangeNotifier;

  @override
  Widget build(BuildContext context) {
    final blurred = settings.enableBlurEffect;
    final theme = Theme.of(context);
    return Column(
      children: [
        SizeTransition(
          sizeFactor: widget.scale,
          child: BlurredRRect.all(
            enabled: blurred,
            borderRadius: _radius,
            child: GestureDetector(
              onTapDown: (details) {
                _setEdgeFromTap(details.globalPosition);
              },
              onHorizontalDragUpdate: (details) {
                _setEdgeFromTap(details.globalPosition);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: kMinInteractiveDimension),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Themes.overlayBackgroundColor(brightness: theme.brightness, blurred: blurred),
                    border: AvesBorder.border(context),
                    borderRadius: const BorderRadius.all(Radius.circular(_radius)),
                  ),
                  child: MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.noScaling,
                    ),
                    child: NullableValueListenableBuilder<SlowMotionRange>(
                      valueListenable: slowMotionRangeNotifier,
                      builder: (context, range, child) {
                        if (range == null) return const SizedBox();
                        return ClipRRect(
                          key: _slowMotionBarKey,
                          borderRadius: const BorderRadius.all(Radius.circular(4)),
                          child: Directionality(
                            textDirection: kVideoPlaybackDirection,
                            child: CustomPaint(
                              size: const Size(double.infinity, kMinInteractiveDimension),
                              painter: _SlowMotionRangePainter(
                                range: range,
                                handleColor: theme.colorScheme.primary,
                                lineColor: theme.colorScheme.onSurface.withValues(alpha: .2),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _setEdgeFromTap(Offset globalPosition) async {
    final box = _getProgressBarRenderBox();
    final _controller = controller;
    final range = slowMotionRangeNotifier?.value;
    if (_controller == null || box == null || range == null) return;

    const padding = VideoProgressBar.padding;

    final dx = box.globalToLocal(globalPosition).dx;
    final progress = (dx - padding.left) / (box.size.width - padding.horizontal);

    if ((range.start - progress).abs() < (range.end - progress).abs()) {
      _controller.setSlowMotionStart(progress);
    } else {
      _controller.setSlowMotionEnd(progress);
    }
  }

  RenderBox? _getProgressBarRenderBox() {
    return _slowMotionBarKey.currentContext?.findRenderObject() as RenderBox?;
  }
}

class _SlowMotionRangePainter extends CustomPainter {
  final SlowMotionRange range;
  final Color handleColor, lineColor;
  final Paint _handlePaint, _linePaint;

  static const double _strokeWidth = 4;
  static const double _handleRadius = 8;
  static const double _handlePadding = 16;
  static const double _slowLinePeriod = 16;
  static const double _slowLineAmplitude = 4;

  _SlowMotionRangePainter({
    required this.range,
    required this.handleColor,
    required this.lineColor,
  }) : _handlePaint = Paint()
         ..color = handleColor
         ..strokeCap = .round
         ..strokeWidth = _strokeWidth
         ..style = .stroke,
       _linePaint = Paint()
         ..color = lineColor
         ..strokeCap = .round
         ..strokeWidth = _strokeWidth
         ..style = .stroke;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = VideoProgressBar.padding;
    final interactiveStart = padding.left;
    final interactiveWidth = size.width - padding.horizontal;
    final xStart = range.start * interactiveWidth;
    final xEnd = range.end * interactiveWidth;
    final y = size.height / 2;

    canvas.translate(interactiveStart, 0);

    const realBeforeStart = _strokeWidth / 2;
    final realBeforeEnd = xStart - _handlePadding;
    if (realBeforeStart < realBeforeEnd) {
      canvas.drawLine(Offset(realBeforeStart, y), Offset(realBeforeEnd, y), _linePaint);
    }

    final slowStart = xStart + _handlePadding;
    final slowEnd = xEnd - _handlePadding;
    if (slowStart < slowEnd) {
      final path = _computeWavyLinePath(slowStart, slowEnd, y);
      if (path != null) {
        canvas.drawPath(path, _linePaint);
      }
    }

    final realAfterStart = xEnd + _handlePadding;
    final realAfterEnd = interactiveWidth - _strokeWidth / 2;
    if (realAfterStart < realAfterEnd) {
      canvas.drawLine(Offset(realAfterStart, y), Offset(realAfterEnd, y), _linePaint);
    }

    canvas.drawCircle(Offset(xStart, y), _handleRadius, _handlePaint);
    canvas.drawCircle(Offset(xEnd, y), _handleRadius, _handlePaint);
  }

  Path? _computeWavyLinePath(double xStart, double xEnd, double yCenter) {
    final pointCount = (xEnd - xStart).round();
    const angleIncrement = 2 * pi / _slowLinePeriod;
    final points = List.generate(pointCount, (i) {
      final dx = xStart + i;
      final t = angleIncrement * dx;
      final dy = sin(t) * _slowLineAmplitude;
      return Offset(dx, yCenter + dy);
    });
    if (points.isEmpty) return null;

    final origin = points.first;
    final path = Path()..moveTo(origin.dx, origin.dy);
    points.forEach((p) {
      path.lineTo(p.dx, p.dy);
    });
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
