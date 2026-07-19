import 'package:aves/utils/calendar/aves_locale.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:test/test.dart';

void main() {
  test('format file size', () {
    final locale = AvesLocale.ascii;
    expect(formatFileSize(locale, 1024), '1.00 KB');
    expect(formatFileSize(locale, 1536), '1.50 KB');
    expect(formatFileSize(locale, 1073741824), '1.00 GB');
  });
}
