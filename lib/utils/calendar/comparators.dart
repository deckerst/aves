import 'package:shamsi_date/shamsi_date.dart';

abstract class CalendarComparator {
  const CalendarComparator();

  bool isSameYear(DateTime? dateA, DateTime? dateB);

  bool isSameYearMonth(DateTime? dateA, DateTime? dateB);

  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB);
}

class GregorianCalendarComparator extends CalendarComparator {
  const GregorianCalendarComparator();

  @override
  bool isSameYear(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year;
  }

  @override
  bool isSameYearMonth(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year && dateA?.month == dateB?.month;
  }

  @override
  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB) {
    return dateA?.year == dateB?.year && dateA?.month == dateB?.month && dateA?.day == dateB?.day;
  }
}

class PersianCalendarComparator extends CalendarComparator {
  const PersianCalendarComparator();

  @override
  bool isSameYear(DateTime? dateA, DateTime? dateB) {
    final jA = dateA?.toJalali();
    final jB = dateB?.toJalali();
    return jA?.year == jB?.year;
  }

  @override
  bool isSameYearMonth(DateTime? dateA, DateTime? dateB) {
    final jA = dateA?.toJalali();
    final jB = dateB?.toJalali();
    return jA?.year == jB?.year && jA?.month == jB?.month;
  }

  @override
  bool isSameYearMonthDay(DateTime? dateA, DateTime? dateB) {
    final jA = dateA?.toJalali();
    final jB = dateB?.toJalali();
    return jA?.year == jB?.year && jA?.month == jB?.month && jA?.day == jB?.day;
  }
}
