import 'package:intl/intl.dart' as intl;
import 'package:intl4x/number_format.dart' as num4x;

class ANumberFormat {
  final String Function(num number) _format;

  new _private(this._format);

  factory fromIntl(intl.NumberFormat nf) {
    return ANumberFormat._private(nf.format);
  }

  factory fromIntl4x(num4x.NumberFormat nf) {
    return ANumberFormat._private(nf.format);
  }

  String format(num number) => _format(number);
}

class ANumberParser {
  final num Function(String text) _parse;

  new _private(this._parse);

  factory fromIntl(intl.NumberFormat nf) {
    return ANumberParser._private(nf.parse);
  }

  num parse(String text) => _parse(text);
}

