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

    expect(parseUnknownDateFormat('1600995564713'), DateTime(2020, 9, 25, 0, 59, 24, 713).add(localOffset));
    expect(parseUnknownDateFormat('pre1600995564713suf'), DateTime(2020, 9, 25, 0, 59, 24, 713).add(localOffset));

    expect(parseUnknownDateFormat('1600995564'), DateTime(2020, 9, 25, 0, 59, 24, 0).add(localOffset));
    expect(parseUnknownDateFormat('pre1600995564suf'), DateTime(2020, 9, 25, 0, 59, 24, 0).add(localOffset));

    expect(parseUnknownDateFormat('IMG_20210901_142523_783'), DateTime(2021, 9, 1, 14, 25, 23, 783));
    expect(parseUnknownDateFormat('Screenshot_20211028-115056_Aves'), DateTime(2021, 10, 28, 11, 50, 56, 0));

    expect(parseUnknownDateFormat('Screenshot_2022-05-14-15-40-29-164_uri'), DateTime(2022, 5, 14, 15, 40, 29, 164));
    expect(parseUnknownDateFormat('2019-02-18 16.00.12-DCM'), DateTime(2019, 2, 18, 16, 0, 12, 0));
    expect(parseUnknownDateFormat('2019-10-31 135703'), DateTime(2019, 10, 31, 13, 57, 3, 0));
  });
}
