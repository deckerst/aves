import 'package:aves/locale/intl.dart';
import 'package:aves/model/naming_pattern.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting();
  });

  test('mixed processors', () {
    const entryCount = 42;
    final dateFormatLocale = IntlUtils.rootLocaleName;
    expect(
      NamingPattern.from(
        userPattern: 'pure literal',
        entryCount: entryCount,
        localeBcp47: dateFormatLocale,
      ).processors,
      [
        const LiteralNamingProcessor('pure literal'),
      ],
    );
    expect(
      NamingPattern.from(
        userPattern: 'prefix<date,yyyy-MM-ddTHH:mm:ss>suffix',
        entryCount: entryCount,
        localeBcp47: dateFormatLocale,
      ).processors,
      [
        const LiteralNamingProcessor('prefix'),
        DateNamingProcessor('yyyy-MM-ddTHH:mm:ss', dateFormatLocale),
        const LiteralNamingProcessor('suffix'),
      ],
    );
    expect(
      NamingPattern.from(
        userPattern: '<date,yyyy-MM-ddTHH:mm:ss> <name>',
        entryCount: entryCount,
        localeBcp47: dateFormatLocale,
      ).processors,
      [
        DateNamingProcessor('yyyy-MM-ddTHH:mm:ss', dateFormatLocale),
        const LiteralNamingProcessor(' '),
        const NameNamingProcessor(),
      ],
    );
  });

  test('insertion offset', () {
    const userPattern = '<date,yyyy-MM-ddTHH:mm:ss> infix <name>';
    expect(NamingPattern.getInsertionOffset(userPattern, -1), 0);
    expect(NamingPattern.getInsertionOffset(userPattern, 1234), userPattern.length);
    expect(NamingPattern.getInsertionOffset(userPattern, 4), 26);
    expect(NamingPattern.getInsertionOffset(userPattern, 30), 30);
  });
}
