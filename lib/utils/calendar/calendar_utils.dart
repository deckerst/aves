import 'package:aves/utils/calendar/comparators.dart';
import 'package:intl4x/datetime_format.dart' as intl4x;

extension ExtraIntl4xCalendar on intl4x.Calendar {
  int get maxDaysInYear => 366;

  int get maxDaysInMonth => 31;

  int get maxMonthsInYear => 12;

  CalendarComparator getComparator() {
    switch (this) {
      case .gregorian:
        return GregorianCalendarComparator.instance;
      case .persian:
        return PersianCalendarComparator.instance;
      default:
        throw UnimplementedError();
    }
  }
}
