import 'package:aves/utils/time_utils.dart';
import 'package:test/test.dart';

void main() {
  test('Comparison extension functions', () {
    expect(DateTime(1593, 7, 8).isAtSameYearAs(null), false);
    expect(DateTime(1903, 9, 25).isAtSameYearAs(DateTime(1970, 2, 25)), false);
    expect(DateTime(1929, 3, 22).isAtSameYearAs(DateTime(1929, 3, 22)), true);

    expect(DateTime(1593, 7, 8).isAtSameMonthAs(null), false);
    expect(DateTime(1903, 9, 25).isAtSameMonthAs(DateTime(1970, 2, 25)), false);
    expect(DateTime(1929, 3, 22).isAtSameMonthAs(DateTime(1929, 3, 22)), true);

    expect(DateTime(1593, 7, 8).isAtSameDayAs(null), false);
    expect(DateTime(1903, 9, 25).isAtSameDayAs(DateTime(1970, 2, 25)), false);
    expect(DateTime(1929, 3, 22).isAtSameDayAs(DateTime(1929, 3, 22)), true);
  });

  test('Parse dates', () {
    final localOffset = DateTime.now().timeZoneOffset;

    expect(parseUnknownDateFormat('1600995564713'), DateTime(2020, 09, 25, 0, 59, 24, 713).add(localOffset));
    expect(parseUnknownDateFormat('pre1600995564713suf'), DateTime(2020, 09, 25, 0, 59, 24, 713).add(localOffset));

    expect(parseUnknownDateFormat('1600995564'), DateTime(2020, 09, 25, 0, 59, 24, 0).add(localOffset));
    expect(parseUnknownDateFormat('pre1600995564suf'), DateTime(2020, 09, 25, 0, 59, 24, 0).add(localOffset));

    expect(parseUnknownDateFormat('IMG_20210901_142523_783'), DateTime(2021, 09, 1, 5, 25, 23, 783).add(localOffset));
    expect(parseUnknownDateFormat('Screenshot_20211028-115056_Aves'), DateTime(2021, 10, 28, 2, 50, 56, 0).add(localOffset));
  });
}
