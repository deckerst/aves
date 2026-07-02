import 'package:aves/utils/calendar/ops/gregorian.dart';
import 'package:test/test.dart';

void main() {
  test('Same year / month / day', () {
    final calOps = GregorianCalendarOps.instance;
    expect(calOps.isSameYear(DateTime(1593, 7, 8), null), false);
    expect(calOps.isSameYear(DateTime(1903, 9, 25), DateTime(1970, 2, 25)), false);
    expect(calOps.isSameYear(DateTime(1929, 3, 22), DateTime(1929, 3, 22)), true);

    expect(calOps.isSameYearMonth(DateTime(1593, 7, 8), null), false);
    expect(calOps.isSameYearMonth(DateTime(1903, 9, 25), DateTime(1970, 2, 25)), false);
    expect(calOps.isSameYearMonth(DateTime(1929, 3, 22), DateTime(1929, 3, 22)), true);

    expect(calOps.isSameYearMonthDay(DateTime(1593, 7, 8), null), false);
    expect(calOps.isSameYearMonthDay(DateTime(1903, 9, 25), DateTime(1970, 2, 25)), false);
    expect(calOps.isSameYearMonthDay(DateTime(1929, 3, 22), DateTime(1929, 3, 22)), true);
  });
}
