import 'dart:math';

int highestPowerOf2(num x) => x < 1 ? 0 : pow(2, (log(x) / ln2).floor()).toInt();

int smallestPowerOf2(num x) => x < 1 ? 1 : pow(2, (log(x) / ln2).ceil()).toInt();

double roundToPrecision(final double value, {required final int decimals}) => (value * pow(10, decimals)).round() / pow(10, decimals);
