import 'dart:ui';

import 'package:aves/utils/math_utils.dart';
import 'package:test/test.dart';

void main() {
  test('highest power of 2 that is smaller than or equal to the number', () {
    expect(highestPowerOf2(1024), 1024);
    expect(highestPowerOf2(42), 32);
    expect(highestPowerOf2(0), 0);
    expect(highestPowerOf2(-42), 0);
    expect(highestPowerOf2(.5), 0);
    expect(highestPowerOf2(1.5), 1);
  });

  test('smallest power of 2 that is larger than or equal to the number', () {
    expect(smallestPowerOf2(1024), 1024);
    expect(smallestPowerOf2(42), 64);
    expect(smallestPowerOf2(0), 1);
    expect(smallestPowerOf2(-42), 1);
    expect(smallestPowerOf2(.5), 1);
    expect(smallestPowerOf2(1.5), 2);
    expect(smallestPowerOf2(0.5, allowNegativePower: true), 0.5);
    expect(smallestPowerOf2(0.1, allowNegativePower: true), 0.125);
    expect(smallestPowerOf2(0, allowNegativePower: true), 1);
  });

  test('rounding to a given precision after the decimal', () {
    expect(roundToPrecision(1.2345678, decimals: 3), 1.235);
    expect(roundToPrecision(0, decimals: 3), 0);
  });

  test('segment intersection', () {
    const s1 = (Offset(1, 1), Offset(3, 2));
    const s2 = (Offset(1, 4), Offset(2, -1));
    expect(segmentIntersection(s1, s2), const Offset(17 / 11, 14 / 11));
  });
}
