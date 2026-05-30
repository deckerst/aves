import 'package:intl/intl.dart';

const int _kilo = 1024;
const int _mega = _kilo * _kilo;
const int _giga = _mega * _kilo;
const int _tera = _giga * _kilo;

int applyFileSizeSuffix(String? suffix, int bytes) {
  switch (suffix) {
    case 'K':
      bytes *= _kilo;
    case 'M':
      bytes *= _mega;
    case 'G':
      bytes *= _giga;
  }
  return bytes;
}

String formatFileSize(String locale, int size, {int round = 2}) {
  if (size < _kilo) return '$size B';

  final compactFormatter = NumberFormat('0${round > 0 ? '.${'0' * round}' : ''}', locale);
  if (size < _mega) return '${compactFormatter.format(size / _kilo)} KB';
  if (size < _giga) return '${compactFormatter.format(size / _mega)} MB';
  if (size < _tera) return '${compactFormatter.format(size / _giga)} GB';
  return '${compactFormatter.format(size / _tera)} TB';
}
