import 'dart:math';

import 'package:aves/utils/math_utils.dart';
import 'package:test/test.dart';

void main() {
  test('convert angles in radians to degrees', () {
    expect(toDegrees(pi), 180);
    expect(toDegrees(-pi / 2), -90);
  });

  test('convert angles in degrees to radians', () {
    expect(toRadians(180), pi);
    expect(toRadians(-270), pi * -3 / 2);
  });

  test('highest power of 2 that is smaller than or equal to the number', () {
    expect(highestPowerOf2(1024), 1024);
    expect(highestPowerOf2(42), 32);
    expect(highestPowerOf2(0), 0);
    expect(highestPowerOf2(-42), 0);
  });

  test('rounding to a given precision after the decimal', () {
    expect(roundToPrecision(1.2345678, decimals: 3), 1.235);
    expect(roundToPrecision(0, decimals: 3), 0);
  });
}
