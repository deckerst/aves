import 'package:intl/intl.dart';

const kilo = 1024;
const mega = kilo * kilo;
const giga = mega * kilo;
const tera = giga * kilo;

String formatFileSize(String locale, int size, {int round = 2}) {
  if (size < kilo) return '$size B';

  final compactFormatter = NumberFormat('0${round > 0 ? '.${'0' * round}' : ''}', locale);
  if (size < mega) return '${compactFormatter.format(size / kilo)} KB';
  if (size < giga) return '${compactFormatter.format(size / mega)} MB';
  if (size < tera) return '${compactFormatter.format(size / giga)} GB';
  return '${compactFormatter.format(size / tera)} TB';
}
