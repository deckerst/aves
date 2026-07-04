import 'package:aves/utils/calendar/aves_locale.dart';
import 'package:aves/utils/calendar/ops/base.dart';
import 'package:aves/utils/calendar/ops/gregorian.dart';
import 'package:aves/utils/calendar/ops/persian.dart';

extension ExtraIntl4xCalendar on ACalendar {
  int get maxDaysInYear => 366;

  int get maxDaysInMonth => 31;

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
