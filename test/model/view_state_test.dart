import 'dart:ui';

import 'package:aves/model/viewer/view_state.dart';
import 'package:aves_utils/aves_utils.dart';
import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  test('scene -> viewport, original scaleFit', () {
    const viewport = Rect.fromLTWH(0, 0, 100, 200);
    const content = Rect.fromLTWH(0, 0, 200, 400);
    final state = ViewState(position: Offset.zero, scale: 1, viewportSize: viewport.size, contentSize: content.size);

    expect(_toViewportPoint(state, content.topLeft), const Offset(-50, -100));
    expect(_toViewportPoint(state, content.bottomRight), const Offset(150, 300));
  });

  test('scene -> viewport, scaled to fit .5', () {
    const viewport = Rect.fromLTWH(0, 0, 100, 200);
    const content = Rect.fromLTWH(0, 0, 200, 400);
    final state = ViewState(position: Offset.zero, scale: .5, viewportSize: viewport.size, contentSize: content.size);

    expect(_toViewportPoint(state, content.topLeft), viewport.topLeft);
    expect(_toViewportPoint(state, content.center), viewport.center);
    expect(_toViewportPoint(state, content.bottomRight), viewport.bottomRight);
  });

  test('scene -> viewport, scaled to fit .25', () {
    const viewport = Rect.fromLTWH(0, 0, 50, 100);
    const content = Rect.fromLTWH(0, 0, 200, 400);
    final state = ViewState(position: Offset.zero, scale: .25, viewportSize: viewport.size, contentSize: content.size);

    expect(_toViewportPoint(state, content.topLeft), viewport.topLeft);
    expect(_toViewportPoint(state, content.center), viewport.center);
    expect(_toViewportPoint(state, content.bottomRight), viewport.bottomRight);
  });

  test('viewport -> scene, original scaleFit', () {
    const viewport = Rect.fromLTWH(0, 0, 100, 200);
    const content = Rect.fromLTWH(0, 0, 200, 400);
    final state = ViewState(position: Offset.zero, scale: 1, viewportSize: viewport.size, contentSize: content.size);

    expect(_toContentPoint(state, viewport.topLeft), const Offset(50, 100));
    expect(_toContentPoint(state, viewport.bottomRight), const Offset(150, 300));
  });

  test('viewport -> scene, scaled to fit', () {
    const viewport = Rect.fromLTWH(0, 0, 100, 200);
    const content = Rect.fromLTWH(0, 0, 200, 400);
    final state = ViewState(position: Offset.zero, scale: .5, viewportSize: viewport.size, contentSize: content.size);

    expect(_toContentPoint(state, viewport.topLeft), content.topLeft);
    expect(_toContentPoint(state, viewport.center), content.center);
    expect(_toContentPoint(state, viewport.bottomRight), content.bottomRight);
  });

  test('viewport -> scene, translated', () {
    const viewport = Rect.fromLTWH(0, 0, 100, 200);
    const content = Rect.fromLTWH(0, 0, 200, 400);
    final state = ViewState(position: const Offset(50, 50), scale: 1, viewportSize: viewport.size, contentSize: content.size);

    _toContentPoint(state, viewport.topLeft);
    expect(_toContentPoint(state, viewport.topLeft), const Offset(0, 50));
    expect(_toContentPoint(state, viewport.bottomRight), const Offset(100, 250));
  });

  test('scene -> viewport, scaled to fit, different ratios', () {
    const viewport = Rect.fromLTWH(0, 0, 360, 521);
    const content = Rect.fromLTWH(0, 0, 2268, 4032);
    final scaleFit = viewport.height / content.height;
    final state = ViewState(position: Offset.zero, scale: scaleFit, viewportSize: viewport.size, contentSize: content.size);

    final scaledContentLeft = (viewport.width - content.width * scaleFit) / 2;
    final scaledContentRight = viewport.width - scaledContentLeft;

    expect(_toViewportPoint(state, content.topLeft), Offset(scaledContentLeft, 0));
    expect(_toViewportPoint(state, content.center), viewport.center);
    expect(_toViewportPoint(state, content.bottomRight), Offset(scaledContentRight, viewport.bottom));
  });
}

// convenience methods

Offset _toViewportPoint(ViewState state, Offset contentPoint) {
  return state.matrix.transformOffset(contentPoint);
}

Offset _toContentPoint(ViewState state, viewportPoint) {
  return Matrix4.inverted(state.matrix).transformOffset(viewportPoint);
}
