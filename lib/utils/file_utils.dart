import 'package:intl/intl.dart';

const kilo = 1024;
const mega = kilo * kilo;
const giga = mega * kilo;
const tera = giga * kilo;

String formatFileSize(String locale, int size, {int round = 2}) {
  if (size < kilo) return '$size B';

  final formatter = NumberFormat('0${round > 0 ? '.${'0' * round}' : ''}', locale);
  if (size < mega) return '${formatter.format(size / kilo)} KB';
  if (size < giga) return '${formatter.format(size / mega)} MB';
  if (size < tera) return '${formatter.format(size / giga)} GB';
  return '${formatter.format(size / tera)} TB';
}
