import 'dart:async';
import 'dart:math';

import 'package:aves/model/viewer/view_state.dart';
import 'package:aves/theme/durations.dart';
import 'package:aves/widgets/common/extensions/geometry.dart';
import 'package:aves/widgets/common/fx/dashed_path_painter.dart';
import 'package:aves/widgets/editor/transform/controller.dart';
import 'package:aves/widgets/editor/transform/crop_region.dart';
import 'package:aves/widgets/editor/transform/handles.dart';
import 'package:aves/widgets/editor/transform/painter.dart';
import 'package:aves/widgets/editor/transform/transformation.dart';
import 'package:aves_magnifier/aves_magnifier.dart';
import 'package:aves_model/aves_model.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Cropper extends StatefulWidget {
  final AvesMagnifierController magnifierController;
  final TransformController transformController;
  final ValueNotifier<EdgeInsets> marginNotifier;

  static const double handleDimension = kMinInteractiveDimension;
  static const EdgeInsets imageMargin = EdgeInsets.all(kMinInteractiveDimension);

  const Cropper({
    super.key,
    required this.magnifierController,
    required this.transformController,
    required this.marginNotifier,
  });

  @override
  State<Cropper> createState() => _CropperState();
}

class _CropperState extends State<Cropper> with SingleTickerProviderStateMixin {
  final Set<StreamSubscription> _subscriptions = {};
  final ValueNotifier<Rect> _outlineNotifier = ValueNotifier(Rect.zero);
  final ValueNotifier<int> _gridDivisionNotifier = ValueNotifier(0);
  late AnimationController _gridAnimationController;
  late CurvedAnimation _gridOpacity;

  static const double minDimension = Cropper.handleDimension;
  static const int panResizeGridDivision = 3;
  static const int straightenGridDivision = 9;
  static const double overOutlineFactor = .25;

  AvesMagnifierController get magnifierController => widget.magnifierController;

  TransformController get transformController => widget.transformController;

  Transformation get transformation => transformController.transformation;

  CropAspectRatio get cropAspectRatio => transformController.aspectRatioNotifier.value;

  @override
  void initState() {
    super.initState();
    _gridAnimationController = AnimationController(
      duration: context.read<DurationsData>().viewerOverlayAnimation,
      vsync: this,
    );
    _gridOpacity = CurvedAnimation(
      parent: _gridAnimationController,
      curve: Curves.easeOutQuad,
    );
    _registerWidget(widget);
  }

  @override
  void didUpdateWidget(covariant Cropper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _unregisterWidget(oldWidget);
    _registerWidget(widget);
  }

  @override
  void dispose() {
    _outlineNotifier.dispose();
    _gridDivisionNotifier.dispose();
    _gridOpacity.dispose();
    _gridAnimationController.dispose();
    _unregisterWidget(widget);
    super.dispose();
  }

  void _registerWidget(Cropper widget) {
    _subscriptions.add(widget.magnifierController.stateStream.listen(_onViewStateChanged));
    _subscriptions.add(widget.magnifierController.scaleBoundariesStream.map((v) => v.viewportSize).distinct().listen(_onViewportSizeChanged));
    _subscriptions.add(widget.transformController.activityStream.listen(_onTransformActivity));
    _subscriptions.add(widget.transformController.transformationStream.map((v) => v.orientation).distinct().listen(_onOrientationChanged));
    _subscriptions.add(widget.transformController.transformationStream.map((v) => v.straightenDegrees).distinct().listen(_onStraightenDegreesChanged));
    widget.transformController.aspectRatioNotifier.addListener(_onCropAspectRatioChanged);
  }

  void _unregisterWidget(Cropper widget) {
    _subscriptions
      ..forEach((sub) => sub.cancel())
      ..clear();
    widget.transformController.aspectRatioNotifier.removeListener(_onCropAspectRatioChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ValueListenableBuilder<EdgeInsets>(
        valueListenable: widget.marginNotifier,
        builder: (context, margin, child) {
          return ValueListenableBuilder<Rect>(
            valueListenable: _outlineNotifier,
            builder: (context, outline, child) {
              if (outline.isEmpty) return const SizedBox();

              final outlineVisualRect = outline.translate(margin.left, margin.top);
              return Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: [
                          _buildDashLine([outlineVisualRect.topLeft, outlineVisualRect.topRight]),
                          _buildDashLine([outlineVisualRect.bottomLeft, outlineVisualRect.bottomRight]),
                          _buildDashLine([outlineVisualRect.topLeft, outlineVisualRect.bottomLeft]),
                          _buildDashLine([outlineVisualRect.topRight, outlineVisualRect.bottomRight]),
                          Positioned.fill(
                            child: ValueListenableBuilder<int>(
                              valueListenable: _gridDivisionNotifier,
                              builder: (context, gridDivision, child) {
                                return ValueListenableBuilder<double>(
                                  valueListenable: _gridOpacity,
                                  builder: (context, gridOpacity, child) {
                                    return CustomPaint(
                                      painter: CropperPainter(
                                        rect: outlineVisualRect,
                                        gridOpacity: gridOpacity,
                                        gridDivision: gridDivision,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildVertexHandle(
                    margin: margin,
                    getPosition: () => outline.topLeft,
                    setPosition: (v) => _handleOutline(
                      left: min(outline.right - minDimension, v.dx),
                      top: min(outline.bottom - minDimension, v.dy),
                    ),
                  ),
                  _buildVertexHandle(
                    margin: margin,
                    getPosition: () => outline.topRight,
                    setPosition: (v) => _handleOutline(
                      right: max(outline.left + minDimension, v.dx),
                      top: min(outline.bottom - minDimension, v.dy),
                    ),
                  ),
                  _buildVertexHandle(
                    margin: margin,
                    getPosition: () => outline.bottomRight,
                    setPosition: (v) => _handleOutline(
                      right: max(outline.left + minDimension, v.dx),
                      bottom: max(outline.top + minDimension, v.dy),
                    ),
                  ),
                  _buildVertexHandle(
                    margin: margin,
                    getPosition: () => outline.bottomLeft,
                    setPosition: (v) => _handleOutline(
                      left: min(outline.right - minDimension, v.dx),
                      bottom: max(outline.top + minDimension, v.dy),
                    ),
                  ),
                  _buildEdgeHandle(
                    margin: margin,
                    getEdge: () => Rect.fromPoints(outline.bottomLeft, outline.topLeft),
                    setEdge: (v) => _handleOutline(
                      left: min(outline.right - minDimension, v.left),
                    ),
                  ),
                  _buildEdgeHandle(
                    margin: margin,
                    getEdge: () => Rect.fromPoints(outline.topLeft, outline.topRight),
                    setEdge: (v) => _handleOutline(
                      top: min(outline.bottom - minDimension, v.top),
                    ),
                  ),
                  _buildEdgeHandle(
                    margin: margin,
                    getEdge: () => Rect.fromPoints(outline.bottomRight, outline.topRight),
                    setEdge: (v) => _handleOutline(
                      right: max(outline.left + minDimension, v.right),
                    ),
                  ),
                  _buildEdgeHandle(
                    margin: margin,
                    getEdge: () => Rect.fromPoints(outline.bottomLeft, outline.bottomRight),
                    setEdge: (v) => _handleOutline(
                      bottom: max(outline.top + minDimension, v.bottom),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // use 1 painter per line so that the dashes of one line
  // do not get offset depending on the previous line length
  Widget _buildDashLine(List<Offset> points) => CustomPaint(
        painter: DashedPathPainter(
          originalPath: Path()..addPolygon(points, false),
          pathColor: CropperPainter.borderColor,
          strokeWidth: CropperPainter.borderWidth,
        ),
      );

  void _handleOutline({
    double? left,
    double? top,
    double? right,
    double? bottom,
  }) {
    final currentOutline = _outlineNotifier.value;
    var targetOutline = Rect.fromLTRB(
      left ?? currentOutline.left,
      top ?? currentOutline.top,
      right ?? currentOutline.right,
      bottom ?? currentOutline.bottom,
    );

    _RatioStrategy? ratioStrategy;
    if (left != null && top != null && right != null) {
      ratioStrategy = _RatioStrategy.pinBottom;
    } else if (top != null && right != null && bottom != null) {
      ratioStrategy = _RatioStrategy.pinLeft;
    } else if (left != null && right != null && bottom != null) {
      ratioStrategy = _RatioStrategy.pinTop;
    } else if (left != null && top != null && bottom != null) {
      ratioStrategy = _RatioStrategy.pinRight;
    } else if (left != null && top != null) {
      ratioStrategy = _RatioStrategy.pinBottomRight;
    } else if (left != null) {
      ratioStrategy = _RatioStrategy.pinTopRight;
    } else if (top != null) {
      ratioStrategy = _RatioStrategy.pinBottomLeft;
    } else if (right != null) {
      ratioStrategy = _RatioStrategy.pinTopLeft;
    } else if (bottom != null) {
      ratioStrategy = _RatioStrategy.pinTopLeft;
    }
    if (ratioStrategy != null) {
      targetOutline = _applyCropRatioToOutline(targetOutline, ratioStrategy);
    }

    // do not try to coerce outline handled outside tilted image
    if (transformation.straightenDegrees != 0 && !_isOutlineContained(targetOutline)) return;

    // dismiss if we could not honour aspect ratio
    if (cropAspectRatio != CropAspectRatio.free && !_isOutlineContained(targetOutline)) return;

    final currentState = _getViewState();
    final boundaries = magnifierController.scaleBoundaries;
    if (currentState == null || boundaries == null) return;

    final gestureRegion = _regionFromOutline(currentState, targetOutline);
    final viewportSize = boundaries.viewportSize;

    final gestureOutline = _containedOutlineFromRegion(currentState, gestureRegion);
    final clampedOutline = Rect.fromLTRB(
      max(gestureOutline.left, 0),
      max(gestureOutline.top, 0),
      min(gestureOutline.right, viewportSize.width),
      min(gestureOutline.bottom, viewportSize.height),
    );
    var nextOutline = clampedOutline;

    if (max(gestureOutline.width - clampedOutline.width, gestureOutline.height - clampedOutline.height) > precisionErrorTolerance) {
      // zoom out when user gesture reaches outer edges
      final targetOutline = Rect.lerp(clampedOutline, gestureOutline, overOutlineFactor)!;
      final targetRegion = _regionFromOutline(currentState, targetOutline);

      final nextState = _viewStateForContainedRegion(boundaries, targetRegion);
      if (nextState != currentState) {
        magnifierController.update(
          position: nextState.position,
          scale: nextState.scale,
          source: ChangeSource.animation,
        );
        nextOutline = _containedOutlineFromRegion(nextState, targetRegion);
      }
    }

    _setOutline(nextOutline);
  }

  bool _isOutlineContained(Rect outline) {
    final currentState = _getViewState();
    final boundaries = magnifierController.scaleBoundaries;
    if (currentState == null || boundaries == null) return false;

    final regionToOutlineMatrix = _getRegionToOutlineMatrix(currentState);
    final outlineToRegionMatrix = Matrix4.inverted(regionToOutlineMatrix);
    final regionCorners = {
      outline.topLeft,
      outline.topRight,
      outline.bottomRight,
      outline.bottomLeft,
    }.map(outlineToRegionMatrix.transformOffset).toSet();

    final contentRect = Offset.zero & boundaries.contentSize;
    return regionCorners.every((v) => contentRect.containsIncludingBottomRight(v, tolerance: precisionErrorTolerance));
  }

  VertexHandle _buildVertexHandle({
    required EdgeInsets margin,
    required ValueGetter<Offset> getPosition,
    required ValueSetter<Offset> setPosition,
  }) {
    return VertexHandle(
      margin: margin,
      getPosition: getPosition,
      setPosition: setPosition,
      onDragStart: _onResizeStart,
      onDragEnd: _onResizeEnd,
    );
  }

  EdgeHandle _buildEdgeHandle({
    required EdgeInsets margin,
    required ValueGetter<Rect> getEdge,
    required ValueSetter<Rect> setEdge,
  }) {
    return EdgeHandle(
      margin: margin,
      getEdge: getEdge,
      setEdge: setEdge,
      onDragStart: _onResizeStart,
      onDragEnd: _onResizeEnd,
    );
  }

  void _onResizeStart() {
    transformController.activity = TransformActivity.resize;
  }

  void _onResizeEnd() {
    transformController.activity = TransformActivity.none;
    _showRegion();
  }

  void _showRegion() {
    final boundaries = magnifierController.scaleBoundaries;
    if (boundaries == null) return;

    final region = transformation.region;
    final nextState = _viewStateForContainedRegion(boundaries, region);

    magnifierController.update(
      position: nextState.position,
      scale: nextState.scale,
      source: ChangeSource.animation,
    );
    _setOutline(_containedOutlineFromRegion(nextState, region));
  }

  ViewState _viewStateForContainedRegion(ScaleBoundaries boundaries, CropRegion imageRegion) {
    final matrix = transformation.matrix;
    final displayRegion = imageRegion.corners.map(matrix.transformOffset).toSet();
    final xMin = displayRegion.map((v) => v.dx).min;
    final xMax = displayRegion.map((v) => v.dx).max;
    final yMin = displayRegion.map((v) => v.dy).min;
    final yMax = displayRegion.map((v) => v.dy).max;
    final displayRegionSize = Size(xMax - xMin, yMax - yMin);

    final nextScale = boundaries.clampScale(ScaleLevel.scaleForContained(boundaries.viewportSize, displayRegionSize));
    final nextPosition = boundaries.clampPosition(
      position: boundaries.contentToStatePosition(nextScale, imageRegion.center),
      scale: nextScale,
    );
    return ViewState(
      position: nextPosition,
      scale: nextScale,
      viewportSize: boundaries.viewportSize,
      contentSize: boundaries.contentSize,
    );
  }

  void _onTransformActivity(TransformActivity activity) {
    switch (activity) {
      case TransformActivity.none:
        _showRegion();
      case TransformActivity.pan:
      case TransformActivity.resize:
        _gridDivisionNotifier.value = panResizeGridDivision;
      case TransformActivity.straighten:
        _gridDivisionNotifier.value = straightenGridDivision;
    }
    if (activity == TransformActivity.none) {
      _gridAnimationController.reverse();
    } else {
      _gridAnimationController.forward();
    }
  }

  void _onOrientationChanged(TransformOrientation orientation) {
    _showRegion();
  }

  void _onStraightenDegreesChanged(double degrees) {
    _updateCropRegion();
  }

  void _onCropAspectRatioChanged() {
    final viewState = _getViewState();
    if (viewState == null) return;

    var targetOutline = _applyCropRatioToOutline(_outlineNotifier.value, _RatioStrategy.keepArea);
    if (!_isOutlineContained(targetOutline)) {
      targetOutline = _applyCropRatioToOutline(_outlineNotifier.value, _RatioStrategy.contain);
    }
    transformController.cropRegion = _regionFromOutline(viewState, targetOutline);
    _showRegion();
  }

  void _onViewStateChanged(MagnifierState state) {
    switch (transformController.activity) {
      case TransformActivity.none:
        break;
      case TransformActivity.straighten:
      case TransformActivity.pan:
        final currentOutline = _outlineNotifier.value;
        _setOutline(_applyCropRatioToOutline(currentOutline, _RatioStrategy.contain));
      case TransformActivity.resize:
        break;
    }
  }

  void _onViewportSizeChanged(Size viewportSize) {
    final boundaries = magnifierController.scaleBoundaries;
    if (boundaries != null) {
      magnifierController.setScaleBoundaries(
        boundaries.copyWith(
          padding: _getBoundariesPadding,
        ),
      );
    }
    _showRegion();
  }

  EdgeInsets _getBoundariesPadding(double scale) {
    // TODO TLAD handle orientation
    if (transformation.orientation != TransformOrientation.normal) {
      return const EdgeInsets.all(double.infinity);
    }
    // TODO TLAD handle straightening
    if (transformation.straightenDegrees != 0) {
      return const EdgeInsets.all(double.infinity);
    }

    final viewState = _getViewState();
    if (viewState != null) {
      final viewportSize = viewState.viewportSize;
      final contentSize = viewState.contentSize;
      if (viewportSize != null && contentSize != null) {
        final fullRegion = CropRegion.fromRect(Offset.zero & contentSize);
        final fullOutline = _containingOutlineFromRegion(viewState, fullRegion);
        final cropOutline = _outlineNotifier.value;

        final paddingWidth = max(0.0, (min(fullOutline.width, viewportSize.width) - cropOutline.width) / 2);
        final paddingHeight = max(0.0, (min(fullOutline.height, viewportSize.height) - cropOutline.height) / 2);
        return EdgeInsets.symmetric(vertical: paddingHeight, horizontal: paddingWidth);
      }
    }

    return EdgeInsets.zero;
  }

  ViewState? _getViewState() {
    final scaleBoundaries = magnifierController.scaleBoundaries;
    if (scaleBoundaries == null) return null;

    final state = magnifierController.currentState;
    return ViewState(
      position: state.position,
      scale: state.scale,
      viewportSize: scaleBoundaries.viewportSize,
      contentSize: scaleBoundaries.contentSize,
    );
  }

  void _setOutline(Rect targetOutline) {
    final viewState = _getViewState();
    final viewportSize = viewState?.viewportSize;
    if (targetOutline.isEmpty || viewState == null || viewportSize == null) return;

    // ensure outline is within content
    var targetRegion = _regionFromOutline(viewState, targetOutline);
    var newOutline = _containedOutlineFromRegion(viewState, targetRegion);
    final outlineWidthDelta = targetOutline.width - newOutline.width;
    final outlineHeightDelta = targetOutline.height - newOutline.height;
    if (outlineWidthDelta > precisionErrorTolerance || outlineHeightDelta > precisionErrorTolerance) {
      // keep outline area if possible, otherwise trim
      final regionToOutlineMatrix = _getRegionToOutlineMatrix(viewState);
      final rect = Offset.zero & viewState.contentSize!;
      final edgeRegionCorners = targetRegion.corners.where((v) => v.dx == rect.left || v.dx == rect.right || v.dy == rect.top || v.dy == rect.bottom).toSet();
      final edgeOutlineCorners = edgeRegionCorners.map(regionToOutlineMatrix.transformOffset).toSet();
      if (edgeOutlineCorners.isNotEmpty) {
        final direction = edgeOutlineCorners.map((v) => newOutline.center - v).reduce((prev, v) => prev + v);
        final movedOutline = targetOutline.shift(Offset(
          outlineWidthDelta * direction.dx.sign,
          outlineHeightDelta * direction.dy.sign,
        ));
        targetRegion = _regionFromOutline(viewState, movedOutline);
        newOutline = _containedOutlineFromRegion(viewState, targetRegion);
      }
    }

    // ensure outline is large enough to be handled
    newOutline = Rect.fromLTWH(
      newOutline.left,
      newOutline.top,
      max(newOutline.width, minDimension),
      max(newOutline.height, minDimension),
    );

    _outlineNotifier.value = newOutline;
    switch (transformController.activity) {
      case TransformActivity.pan:
      case TransformActivity.resize:
        _updateCropRegion();
        break;
      case TransformActivity.none:
      case TransformActivity.straighten:
        break;
    }
  }

  void _updateCropRegion() {
    final viewState = _getViewState();
    final outline = _outlineNotifier.value;
    if (viewState != null && !outline.isEmpty) {
      transformController.cropRegion = _regionFromOutline(viewState, outline);
    }
  }

  Matrix4 _getRegionToOutlineMatrix(ViewState viewState) {
    final magnifierMatrix = viewState.matrix;

    final viewportCenter = viewState.viewportSize!.center(Offset.zero);
    final transformOrigin = Matrix4.inverted(magnifierMatrix).transformOffset(viewportCenter);
    final transformMatrix = Matrix4.identity()
      ..translate(transformOrigin.dx, transformOrigin.dy)
      ..multiply(transformation.matrix)
      ..translate(-transformOrigin.dx, -transformOrigin.dy);

    return magnifierMatrix..multiply(transformMatrix);
  }

  CropRegion _regionFromOutline(ViewState viewState, Rect outline) {
    final regionToOutlineMatrix = _getRegionToOutlineMatrix(viewState);
    final outlineToRegionMatrix = regionToOutlineMatrix..invert();

    final rect = Offset.zero & viewState.contentSize!;
    double clampX(double dx) => dx.clamp(rect.left, rect.right);
    double clampY(double dy) => dy.clamp(rect.top, rect.bottom);
    Offset clampPoint(Offset v) => Offset(clampX(v.dx), clampY(v.dy));
    Offset transform(Offset v) => clampPoint(outlineToRegionMatrix.transformOffset(v));
    final clampedRegion = CropRegion(
      topLeft: transform(outline.topLeft),
      topRight: transform(outline.topRight),
      bottomRight: transform(outline.bottomRight),
      bottomLeft: transform(outline.bottomLeft),
    );
    return clampedRegion;
  }

  Rect _containingOutlineFromRegion(ViewState viewState, CropRegion region) {
    final regionToOutlineMatrix = _getRegionToOutlineMatrix(viewState);
    final points = region.corners.map(regionToOutlineMatrix.transformOffset).toList();
    final dxSet = points.map((v) => v.dx).toSet();
    final dySet = points.map((v) => v.dy).toSet();
    final topLeft = Offset(dxSet.reduce(min), dySet.reduce(min));
    final bottomRight = Offset(dxSet.reduce(max), dySet.reduce(max));
    return Rect.fromPoints(topLeft, bottomRight);
  }

  Rect _containedOutlineFromRegion(ViewState viewState, CropRegion region) {
    final regionToOutlineMatrix = _getRegionToOutlineMatrix(viewState);
    final points = region.corners.map(regionToOutlineMatrix.transformOffset).toList();
    final sortedX = points.map((v) => v.dx).toList()..sort();
    final sortedY = points.map((v) => v.dy).toList()..sort();
    final topLeft = Offset(sortedX[1], sortedY[1]);
    final bottomRight = Offset(sortedX[2], sortedY[2]);
    return Rect.fromPoints(topLeft, bottomRight);
  }

  Rect _applyCropRatioToOutline(Rect outline, _RatioStrategy strategy) {
    final currentState = _getViewState();
    final boundaries = magnifierController.scaleBoundaries;
    if (currentState == null || boundaries == null) return outline;

    final contentSize = boundaries.contentSize;

    late int longCoef;
    late int shortCoef;
    switch (cropAspectRatio) {
      case CropAspectRatio.free:
        return outline;
      case CropAspectRatio.original:
        longCoef = contentSize.longestSide.round();
        shortCoef = contentSize.shortestSide.round();
      case CropAspectRatio.square:
        longCoef = 1;
        shortCoef = 1;
      case CropAspectRatio.ar_16_9:
        longCoef = 16;
        shortCoef = 9;
      case CropAspectRatio.ar_4_3:
        longCoef = 4;
        shortCoef = 3;
    }

    final contentRect = Offset.zero & contentSize;
    final isLandscape = (outline.width - outline.height).abs() > precisionErrorTolerance ? outline.width > outline.height : contentSize.width > contentSize.height;
    final newRatio = isLandscape ? longCoef / shortCoef : shortCoef / longCoef;

    Size sizeToKeepArea() {
      final f = (outline.longestSide + outline.shortestSide) / (longCoef + shortCoef);
      final newLongest = f * longCoef;
      final newShortest = f * shortCoef;
      return isLandscape ? Size(newLongest, newShortest) : Size(newShortest, newLongest);
    }

    final regionToOutlineMatrix = _getRegionToOutlineMatrix(currentState);
    final outlineToRegionMatrix = Matrix4.inverted(regionToOutlineMatrix);

    Rect pinnedRect(Rect Function(Size targetSize) forSize) {
      final targetSize = sizeToKeepArea();
      final rect = forSize(targetSize);

      // do not try to coerce outline handled outside tilted image
      if (transformation.straightenDegrees != 0) return rect;

      final regionCorners = {
        rect.topLeft,
        rect.topRight,
        rect.bottomRight,
        rect.bottomLeft,
      }.map(outlineToRegionMatrix.transformOffset).toSet();

      if (regionCorners.every((v) => contentRect.containsIncludingBottomRight(v, tolerance: precisionErrorTolerance))) return rect;

      final clampedOutlineCorners = regionCorners.map((v) => regionToOutlineMatrix.transformOffset(Offset(v.dx.clamp(0, contentSize.width), v.dy.clamp(0, contentSize.height)))).toSet();
      final minX = clampedOutlineCorners.map((v) => v.dx).min;
      final maxX = clampedOutlineCorners.map((v) => v.dx).max;
      final minY = clampedOutlineCorners.map((v) => v.dy).min;
      final maxY = clampedOutlineCorners.map((v) => v.dy).max;

      var width = rect.width;
      var height = rect.height;
      if (rect.left < minX - precisionErrorTolerance) {
        width = rect.right - minX;
        height = width / newRatio;
      } else if (rect.top < minY - precisionErrorTolerance) {
        height = rect.bottom - minY;
        width = height * newRatio;
      } else if (rect.right > maxX + precisionErrorTolerance) {
        width = maxX - rect.left;
        height = width / newRatio;
      } else if (rect.bottom > maxY + precisionErrorTolerance) {
        height = maxY - rect.top;
        width = height * newRatio;
      }
      final clampedSize = Size(width, height);
      return clampedSize < targetSize ? forSize(clampedSize) : rect;
    }

    switch (strategy) {
      case _RatioStrategy.keepArea:
        final targetSize = sizeToKeepArea();
        return Rect.fromCenter(
          center: outline.center,
          width: targetSize.width,
          height: targetSize.height,
        );
      case _RatioStrategy.contain:
        final currentRatio = outline.width / outline.height;
        if ((newRatio - currentRatio).abs() < precisionErrorTolerance) {
          return outline;
        } else {
          late final Size targetSize;
          if (newRatio > currentRatio) {
            targetSize = Size(outline.width, outline.width / newRatio);
          } else {
            targetSize = Size(outline.height * newRatio, outline.height);
          }
          return Rect.fromCenter(
            center: outline.center,
            width: targetSize.width,
            height: targetSize.height,
          );
        }
      case _RatioStrategy.pinTopLeft:
        return pinnedRect((targetSize) => Rect.fromPoints(
              outline.topLeft,
              outline.topLeft.translate(targetSize.width, targetSize.height),
            ));
      case _RatioStrategy.pinTopRight:
        return pinnedRect((targetSize) => Rect.fromPoints(
              outline.topRight,
              outline.topRight.translate(-targetSize.width, targetSize.height),
            ));
      case _RatioStrategy.pinBottomRight:
        return pinnedRect((targetSize) => Rect.fromPoints(
              outline.bottomRight,
              outline.bottomRight.translate(-targetSize.width, -targetSize.height),
            ));
      case _RatioStrategy.pinBottomLeft:
        return pinnedRect((targetSize) => Rect.fromPoints(
              outline.bottomLeft,
              outline.bottomLeft.translate(targetSize.width, -targetSize.height),
            ));
      case _RatioStrategy.pinLeft:
        return pinnedRect((targetSize) => Rect.fromLTRB(
              outline.left,
              outline.center.dy - targetSize.height / 2,
              outline.left + targetSize.width,
              outline.center.dy + targetSize.height / 2,
            ));
      case _RatioStrategy.pinTop:
        return pinnedRect((targetSize) => Rect.fromLTRB(
              outline.center.dx - targetSize.width / 2,
              outline.top,
              outline.center.dx + targetSize.width / 2,
              outline.top + targetSize.height,
            ));
      case _RatioStrategy.pinRight:
        return pinnedRect((targetSize) => Rect.fromLTRB(
              outline.right - targetSize.width,
              outline.center.dy - targetSize.height / 2,
              outline.right,
              outline.center.dy + targetSize.height / 2,
            ));
      case _RatioStrategy.pinBottom:
        return pinnedRect((targetSize) => Rect.fromLTRB(
              outline.center.dx - targetSize.width / 2,
              outline.bottom - targetSize.height,
              outline.center.dx + targetSize.width / 2,
              outline.bottom,
            ));
    }
  }
}

enum _RatioStrategy { keepArea, contain, pinTopLeft, pinTopRight, pinBottomRight, pinBottomLeft, pinLeft, pinTop, pinRight, pinBottom }
