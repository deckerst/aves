import 'dart:math';
import 'dart:ui';

int highestPowerOf2(num x) => x < 1 ? 0 : pow(2, (log(x) / ln2).floor()).toInt();

num smallestPowerOf2(num x, {bool allowNegativePower = false}) {
  return x < 1 && !allowNegativePower ? 1 : pow(2, (log(x) / ln2).ceil());
}

double roundToPrecision(final double value, {required final int decimals}) => (value * pow(10, decimals)).round() / pow(10, decimals);

// cf https://en.wikipedia.org/wiki/Intersection_(geometry)#Two_line_segments
Offset? segmentIntersection((Offset, Offset) s1, (Offset, Offset) s2) {
  final x1 = s1.$1.dx;
  final y1 = s1.$1.dy;
  final x2 = s1.$2.dx;
  final y2 = s1.$2.dy;

  final x3 = s2.$1.dx;
  final y3 = s2.$1.dy;
  final x4 = s2.$2.dx;
  final y4 = s2.$2.dy;

  final a1 = x2 - x1;
  final b1 = -(x4 - x3);
  final c1 = x3 - x1;
  final a2 = y2 - y1;
  final b2 = -(y4 - y3);
  final c2 = y3 - y1;

  final denom = a1 * b2 - a2 * b1;
  if (denom == 0) {
    // lines are parallel
    return null;
  }

  final s0 = (c1 * b2 - c2 * b1) / denom;
  final t0 = (a1 * c2 - a2 * c1) / denom;

  if (!(0 <= s0 && s0 <= 1 && 0 <= t0 && t0 <= 1)) {
    // segments do not intersect
    return null;
  }

  final x0 = x1 + s0 * (x2 - x1);
  final y0 = y1 + s0 * (y2 - y1);
  return Offset(x0, y0);
}
