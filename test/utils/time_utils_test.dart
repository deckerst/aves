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
}
