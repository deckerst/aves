import 'package:aves/model/settings/coordinate_format.dart';
import 'package:aves/utils/file_utils.dart';
import 'package:aves/utils/geo_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'package:test/test.dart';

void main() {
  test('format file size', () {
    final l10n = lookupAppLocalizations(AppLocalizations.supportedLocales.first);
    final locale = l10n.localeName;
    expect(formatFileSize(locale, 1024), '1.00 KB');
    expect(formatFileSize(locale, 1536), '1.50 KB');
    expect(formatFileSize(locale, 1073741824), '1.00 GB');
  });
}
