import 'package:aves/utils/calendar/comparators.dart';
import 'package:test/test.dart';

void main() {
  test('Gregorian calendar comparisons', () {
    const comparator = GregorianCalendarComparator();
    expect(comparator.isSameYear(DateTime(1593, 7, 8), null), false);
    expect(comparator.isSameYear(DateTime(1903, 9, 25), DateTime(1970, 2, 25)), false);
    expect(comparator.isSameYear(DateTime(1929, 3, 22), DateTime(1929, 3, 22)), true);

    expect(comparator.isSameYearMonth(DateTime(1593, 7, 8), null), false);
    expect(comparator.isSameYearMonth(DateTime(1903, 9, 25), DateTime(1970, 2, 25)), false);
    expect(comparator.isSameYearMonth(DateTime(1929, 3, 22), DateTime(1929, 3, 22)), true);

    expect(comparator.isSameYearMonthDay(DateTime(1593, 7, 8), null), false);
    expect(comparator.isSameYearMonthDay(DateTime(1903, 9, 25), DateTime(1970, 2, 25)), false);
    expect(comparator.isSameYearMonthDay(DateTime(1929, 3, 22), DateTime(1929, 3, 22)), true);
  });
}
