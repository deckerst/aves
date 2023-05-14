import 'dart:ui';

extension ExtraRect on Rect {
  bool containsIncludingBottomRight(Offset offset, {double tolerance = 0}) {
    return offset.dx >= left - tolerance && offset.dx <= right + tolerance && offset.dy >= top - tolerance && offset.dy <= bottom + tolerance;
  }
}
