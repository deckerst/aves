import 'dart:math';
import 'dart:ui';

import 'package:tuple/tuple.dart';

int highestPowerOf2(num x) => x < 1 ? 0 : pow(2, (log(x) / ln2).floor()).toInt();

int smallestPowerOf2(num x) => x < 1 ? 1 : pow(2, (log(x) / ln2).ceil()).toInt();

double roundToPrecision(final double value, {required final int decimals}) => (value * pow(10, decimals)).round() / pow(10, decimals);

// cf https://en.wikipedia.org/wiki/Intersection_(geometry)#Two_line_segments
Offset? segmentIntersection(Tuple2<Offset, Offset> s1, Tuple2<Offset, Offset> s2) {
  final x1 = s1.item1.dx;
  final y1 = s1.item1.dy;
  final x2 = s1.item2.dx;
  final y2 = s1.item2.dy;

  final x3 = s2.item1.dx;
  final y3 = s2.item1.dy;
  final x4 = s2.item2.dx;
  final y4 = s2.item2.dy;

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
