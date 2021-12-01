import 'package:intl/intl.dart';

const _kiloDivider = 1024;
const _megaDivider = _kiloDivider * _kiloDivider;
const _gigaDivider = _megaDivider * _kiloDivider;
const _teraDivider = _gigaDivider * _kiloDivider;

String formatFileSize(String locale, int size, {int round = 2}) {
  if (size < _kiloDivider) return '$size B';

  final formatter = NumberFormat('0${round > 0 ? '.${'0' * round}' : ''}', locale);
  if (size < _megaDivider) return '${formatter.format(size / _kiloDivider)} KB';
  if (size < _gigaDivider) return '${formatter.format(size / _megaDivider)} MB';
  if (size < _teraDivider) return '${formatter.format(size / _gigaDivider)} GB';
  return '${formatter.format(size / _teraDivider)} TB';
}
