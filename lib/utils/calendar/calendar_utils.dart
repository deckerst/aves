import 'package:aves/utils/calendar/ops/base.dart';
import 'package:aves/utils/calendar/ops/gregorian.dart';
import 'package:aves/utils/calendar/ops/persian.dart';
import 'package:intl4x/datetime_format.dart' as intl4x;

extension ExtraIntl4xCalendar on intl4x.Calendar {
  int get maxDaysInYear => 366;

  int get maxDaysInMonth => 31;

  int get maxMonthsInYear => 12;

  CalendarOps get ops {
    switch (this) {
      case .gregorian:
        return GregorianCalendarOps.instance;
      case .persian:
        return PersianCalendarOps.instance;
      default:
        throw UnimplementedError();
    }
  }
}
