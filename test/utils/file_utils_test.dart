import 'package:aves/l10n/l10n.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/widgets/aves_app.dart';
import 'package:test/test.dart';

void main() {
  test('format file size', () {
    final l10n = lookupAppLocalizations(AvesApp.supportedLocales.first);
    final localeName = l10n.localeName;
    expect(formatFileSize(localeName, 1024), '1.00 KB');
    expect(formatFileSize(localeName, 1536), '1.50 KB');
    expect(formatFileSize(localeName, 1073741824), '1.00 GB');
  });
}
